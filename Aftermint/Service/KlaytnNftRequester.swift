//
//  KlaytnNftRequester.swift
//  mship__sample__klip_nft
//
//  Created by Hank on 2023/01/25.
//

import Foundation

enum NftDataStorage {
    case https
    case ipfs
}

class KlaytnNftRequester {
    private static let TOKEN_URL__GET_NFTS_BY_OWNER_ADDRESS__PARAMS_2 = "https://th-api.klaytnapi.com/v2/contract/nft/%@/owner/%@"
    private static let TOKEN_HEADER__KEY__CHAIN_ID = "x-chain-id"
    private static let TOKEN_HEADER__VALUE__CHAIN_ID = "8217"
    private static let TOKEN_HEADER__KEY__AUTHORIZATION = "Authorization"
    private static let TOKEN_HEADER__VALUE__AUTHORIZATION = "Basic S0FTSzEyQ1JKNTNZTk9GQkUwMzM0TUJFOkwwUUpYTHJNam43cUNDWXVJUG05OWZ5Rko5MnJtNjRlaWxGMTJwdkQ="
    private static let TOKEN_PARAMS__KEY__SIZE = "size"
    private static let TOKEN_PARAMS__VALUE__SIZE_MAX = "1000"
    private static let CONTRACT_ADDRESS__BELLY_GOM = "0xce70eef5adac126c37c8bc0c1228d48b70066d03"
    private static let CONTRACT_ADDRESS__MOONO = "0x29421a3c92075348fcbcb04de965e802ed187302"
    
    // MARK: Commons
    public static func requestSimple(
        urlToken: String,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> Bool {
        let urlSession = URLSession(configuration: .default)
        
        guard let url = URL(string: urlToken) else {
            let errorMessage = "Url is nil : urlToken: \(urlToken)."
            completionHandler(nil, nil, NSError(domain: errorMessage, code: -1))
            LLog.w(errorMessage)
            return false
        }
        
        let dataTask = urlSession.dataTask(with: url, completionHandler: completionHandler)
        dataTask.resume()
        return true
    }
    
    public static func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        guard error == nil else {
            LLog.w("error: \(String(describing: error)).")
            return false
        }
        
        guard let _ = data,
              let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            LLog.w("Invalid result : data: \(String(describing: data)), response: \(String(describing: response)).")
            return false
        }
        return true
    }
    
    public static func convertTo<T>(type: T.Type, data: Data) -> T? where T: Decodable {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            LLog.w("error: \(error), type: \(type).")
            return nil
        }
    }
    
    public static func convertToJson(data: Data, showLog: Bool = false) -> Any? {
        guard let jsonData = try? JSONSerialization.jsonObject(with: data) else {
            LLog.w("Json-serializing is failed.")
            return nil
        }
        
        if showLog {
            LLog.i("jsonData: \(jsonData).")
        }
        return jsonData
    }
    
    //MARK: - Get Nfts
    public static func requestToGetNfts(
        contractAddress: String,
        walletAddress: String,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> Bool {
        let urlSession = URLSession(configuration: .default)
        let urlToken = String(format: KlaytnNftRequester.TOKEN_URL__GET_NFTS_BY_OWNER_ADDRESS__PARAMS_2, contractAddress, walletAddress)
        var urlComponents = URLComponents(string: urlToken)
        urlComponents?.queryItems = [URLQueryItem(name: TOKEN_PARAMS__KEY__SIZE, value: TOKEN_PARAMS__VALUE__SIZE_MAX)]
        
        guard let url = urlComponents?.url else {
            let errorMessage = "Url is nil : urlToken: \(urlToken), contractAddress: \(contractAddress), walletAddress: \(walletAddress)."
            completionHandler(nil, nil, NSError(domain: errorMessage, code: -1))
            LLog.w(errorMessage)
            return false
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(
            KlaytnNftRequester.TOKEN_HEADER__VALUE__CHAIN_ID,
            forHTTPHeaderField: KlaytnNftRequester.TOKEN_HEADER__KEY__CHAIN_ID
        )
        urlRequest.addValue(
            KlaytnNftRequester.TOKEN_HEADER__VALUE__AUTHORIZATION,
            forHTTPHeaderField: KlaytnNftRequester.TOKEN_HEADER__KEY__AUTHORIZATION
        )
        
        let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: completionHandler)
        dataTask.resume()
        return true
    }
    
    public static func requestToGetNfts(
        contractAddress: String,
        walletAddress: String,
        nftsHandler: @escaping (KlaytnNfts?, Error?) -> Void
    ) -> Bool {
        return requestToGetNfts(contractAddress: contractAddress, walletAddress: walletAddress) { data, response, error in
            let result = KlaytnNftRequester.processResponse(data: data, response: response, error: error)
            guard let data = data, result else {
                let errorMessage = "Invalid result : contractAddress: \(contractAddress), walletAddress: \(walletAddress)."
                nftsHandler(nil, NSError(domain: errorMessage, code: -1))
                LLog.w(errorMessage)
                return
            }
            
            guard let nfts = convertTo(type: KlaytnNfts.self, data: data) else {
                let errorMessage = "Converting result data is failed : contractAddress: \(contractAddress), walletAddress: \(walletAddress)."
                nftsHandler(nil, NSError(domain: errorMessage, code: -1))
                LLog.w(errorMessage)
                return
            }
            
            nftsHandler(nfts, nil)
        }
    }
    
    // MARK: - for Moono
    public static func requestToGetMoonoNftsDemo(storageType: NftDataStorage,
                                                 walletAddress: String,
                                                 completion: @escaping ([MoonoNft]) -> Void
    ) -> Bool {
        return requestToGetNfts(
            contractAddress: KlaytnNftRequester.CONTRACT_ADDRESS__MOONO,
            walletAddress: walletAddress
        ) { nfts, error in
            guard let rawNfts = nfts else {
                LLog.w("rawNfts is nil : error: \(String(describing: error)).")
                return
            }
            
            var moonoNft: [MoonoNft] = []
            
            requestToGetMoonoNftsDemo(storageType: storageType, rawNfts: rawNfts) { lists in
              
                lists.forEach { (item, metadata: MoonoNftMetadata) in
                  
                    moonoNft.append(createMoonoNft(rawNft: item, metadata: metadata))
                }

            }
            completion(moonoNft)
        }
    }
    
    public static func requestToGetMoonoNftsDemo<T:Decodable>(
        storageType: NftDataStorage,
        rawNfts: KlaytnNfts,
        completion: @escaping ([(KlaytnNft, T)]) -> Void
    ) {
        var taskCount = rawNfts.items.count - 1 //TODO: <WARNING!> Change Hardcoded Number (1)
        var moonoNfts: [(KlaytnNft, T)] = []
        
        let taskLock = NSRecursiveLock()
        let dispatchQueue = DispatchQueue.global(qos: .utility)
        
        func discountTaskSafely() {
            taskLock.lock()
            taskCount -= 1
            taskLock.unlock()
        }
     
        rawNfts.items.forEach { rawItem in
            
            self.requestToGetData(storageType: storageType,
                                  rawNft: rawItem) { data in
                dispatchQueue.async {
                    guard let metadata = convertTo(type: T.self, data: data) else { return }
                    taskLock.lock()
                    moonoNfts.append((rawItem, metadata))
                    discountTaskSafely()
                    taskLock.unlock()
                }
            }
        }
        
        while true {
            taskLock.lock()
            if taskCount == 0 {
                break
            }
            taskLock.unlock()
        }
        
        completion(moonoNfts)
        taskLock.unlock()
    }
    
    private static func requestToGetData(
        storageType: NftDataStorage,
        rawNft: KlaytnNft,
        completion: @escaping (Data) -> Void
    ) {
        
            guard var tokenUri = rawNft.tokenUri, !tokenUri.isEmpty else {
                LLog.w("Token uri found to be nil")
                return
            }
            
            switch storageType {
            case .https:
                break
            case .ipfs:
                tokenUri = tokenUri.replace(target: "ipfs://", withString: "https://ipfs.io/ipfs/")
            }
            
            _ = requestSimple(urlToken: tokenUri, completionHandler: { data, response, error in

                    guard processResponse(data: data, response: response, error: error),
                          let data = data else {
                        LLog.w("Invalid result.")
                        return
                    }
                    completion(data)
            })

    }

    private static func createMoonoNft(rawNft: KlaytnNft, metadata: MoonoNftMetadata) -> MoonoNft {
        
        let imageMetadata = metadata.image
        
        /* when using original gateway */
        let lastIndex = imageMetadata.lastIndex(of: "/")!
        let startIndex = imageMetadata.index(after: lastIndex)
        let endIndex = imageMetadata.lastIndex(of: ".")!
        let imageNumber = imageMetadata[startIndex..<endIndex]

        let convertedImageUrl: String =  "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23" + "\(imageNumber)" + ".jpeg?alt=media"
    
        return MoonoNft(
            name: metadata.name,
            description: metadata.description,
            imageUrl: convertedImageUrl,
            tokenId: rawNft.tokenId,
            updateAt: rawNft.updatedAt,
            previousOwnerAddress: rawNft.previousOwner,
            traits: createMoonoTraits(metadata: metadata)
        )
    }
    
    private static func createMoonoTraits(metadata: MoonoNftMetadata) -> MoonoNft.Traits {
        var attributeMap: [String:Any] = [:]
        attributeMap = metadata.attributes
            .reduce(into: attributeMap) { result, attribute in
                result[attribute.trait_type] = attribute.value
            }
        
        // We expect a error with app-crash if wrong key-value exists.
        return MoonoNft.Traits(
            background: attributeMap[MoonoNft.TraitType.background_string.rawValue] as! String,
            effect: attributeMap[MoonoNft.TraitType.effect_string.rawValue] as! String,
            body: attributeMap[MoonoNft.TraitType.body_string.rawValue] as! String,
            day: attributeMap[MoonoNft.TraitType.day_string.rawValue] as! String,
            expression: attributeMap[MoonoNft.TraitType.expression_string.rawValue] as! String,
            accessories: attributeMap[MoonoNft.TraitType.accessories_string.rawValue] as! String,
            hair: attributeMap[MoonoNft.TraitType.hair_string.rawValue] as! String
        )
    }
}
