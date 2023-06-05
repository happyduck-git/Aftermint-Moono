//
//  KlaytnNftRequester.swift
//  mship__sample__klip_nft
//
//  Created by Hank on 2023/01/25.
//

import Foundation

class KlaytnNftRequester {
    
    private static let cacheManager = KASCacheManager()
    private static var requestToNftsURL: URL?
    // URLs
    private static let TOKEN_URL__GET_NFT_CONTRACT_INFO = "https://th-api.klaytnapi.com/v2/contract/nft/%@"
    private static let TOKEN_URL__GET_NUMBER_OF_HOLDERS = "https://th-api.klaytnapi.com/v2/contract/nft/%@/holder"
    private static let TOKEN_URL__GET_NFTS_BY_OWNER_ADDRESS__PARAMS_2 = "https://th-api.klaytnapi.com/v2/contract/nft/%@/owner/%@"
    private static let TOKEN_URL__GET_NFT_TOKEN_INFO = "https://th-api.klaytnapi.com/v2/contract/nft/%@/token/%@"
    // Headers
    private static let TOKEN_HEADER__KEY__CHAIN_ID = "x-chain-id"
    private static let TOKEN_HEADER__VALUE__CHAIN_ID = "8217"
    private static let TOKEN_HEADER__KEY__AUTHORIZATION = "Authorization"
    private static let TOKEN_HEADER__VALUE__AUTHORIZATION = "Basic S0FTSzEyQ1JKNTNZTk9GQkUwMzM0TUJFOkwwUUpYTHJNam43cUNDWXVJUG05OWZ5Rko5MnJtNjRlaWxGMTJwdkQ="
    // Params
    private static let TOKEN_PARAMS__KEY__SIZE = "size"
    private static let TOKEN_PARAMS__VALUE__SIZE_MAX = "1000"
    // Contract Address
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

    private static func addUrlHeaders(url: URL, headers: [String: String]) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        headers.forEach { header in
            urlRequest.addValue(
                header.key,
                forHTTPHeaderField: header.value
            )
        }
        return urlRequest
    }
    
    private static func addKlaytnBasicHeaders(url: URL) -> URLRequest {
        let urlRequest = addUrlHeaders(url: url, headers: [
            KlaytnNftRequester.TOKEN_HEADER__VALUE__CHAIN_ID: KlaytnNftRequester.TOKEN_HEADER__KEY__CHAIN_ID,
            KlaytnNftRequester.TOKEN_HEADER__VALUE__AUTHORIZATION: KlaytnNftRequester.TOKEN_HEADER__KEY__AUTHORIZATION
        ])
        return urlRequest
    }
    
    // MARK: - Get Total Number of Issued NFTs

    public static func getNumberOfIssuedNFTs(ofCollection nftAddress: String) async throws -> NFTContractInfoResponse? {
        let urlString = String(format: TOKEN_URL__GET_NFT_CONTRACT_INFO, nftAddress)
        guard let url = URL(string: urlString) else {
            throw(KlaytnRequestError.convertUrlError(urlString))
        }
        
        var dataToProcess: Data?
        var responseToProcess: URLResponse?
        if let cachedData = cacheManager.getDataCache(for: .numberOfNfts, url: url),
           let cachedResponse = cacheManager.getResponseCache(for: .numberOfNfts, url: url)
        {
            dataToProcess = cachedData
            responseToProcess = cachedResponse
            guard let result = self.convertTo(type: NFTContractInfoResponse.self, data: cachedData) else {
                throw URLError(.cannotParseResponse)
            }
            return result
        } else {
            let urlRequest = addKlaytnBasicHeaders(url: url)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            dataToProcess = data
            responseToProcess = response
            cacheManager.setCache(for: .numberOfNfts, url: url, data: data, response: response)
        }
        
        if self.processResponse(data: dataToProcess, response: responseToProcess, error: nil) {
            guard let data = dataToProcess else {
                throw KlaytnRequestError.badData
            }
            guard let result = self.convertTo(type: NFTContractInfoResponse.self, data: data) else {
                throw URLError(.cannotParseResponse)
            }
            return result
        } else {
            throw URLError(.cannotParseResponse)
        }
        
    }
    
    // MARK: - Get Number of Holders
    public static func getNumberOfHolders(ofCollection nftAddress: String) async throws -> NFTHolderResponse? {
        let urlString = String(format: TOKEN_URL__GET_NUMBER_OF_HOLDERS, nftAddress)
        guard let url = URL(string: urlString) else {
            throw(KlaytnRequestError.convertUrlError(urlString))
        }
        let urlRequest = addKlaytnBasicHeaders(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if self.processResponse(data: data, response: response, error: nil) {
            guard let result = self.convertTo(type: NFTHolderResponse.self, data: data) else {
                throw URLError(.cannotParseResponse)
            }
            return result
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    
    //MARK: - Get Nfts
    
    public static func requestMoonoNftImageUrl(contractAddress: String, tokenId: String) async -> String? {
        
        do {
            let urlSession = URLSession(configuration: .default)
            guard let nft = try await requestToGetNftInfo(contractAddress: contractAddress, tokenId: tokenId),
                  let tokenUri = nft.tokenUri else {
                return nil
            }
            
            let convertedTokenUri = tokenUri.replace(target: "ipfs://", withString: "https://ipfs.io/ipfs/")
            guard let url = URL(string: convertedTokenUri) else { return nil }
            
            let (data, response) = try await urlSession.data(from: url)
            if processResponse(data: data, response: response, error: nil) {
                guard let metaData = convertTo(type: MoonoNftMetadata.self, data: data) else { return nil }
                let imageUrl = metaData.image.replace(target: "ipfs://", withString: "https://ipfs.io/ipfs/")
                return imageUrl
            } else {
                return nil
            }
            
        }
        catch {
            print("Error requesting moono nft image url: \(error)")
            return nil
        }

    }
    
    /// Request to retrieve a single nft's information
    /// - Parameters:
    ///   - contractAddress: Contract adress of the collection
    ///   - tokenId: NFT token id
    ///   - completion: Call back
    // TODO: private으로 변경하기
    public static func requestToGetNftInfo(
        contractAddress: String,
        tokenId: String
    ) async throws -> KlaytnNft? {
        
        let urlSession = URLSession(configuration: .default)
        let urlToken = String(format: KlaytnNftRequester.TOKEN_URL__GET_NFT_TOKEN_INFO, contractAddress, tokenId)
        guard let url = URL(string: urlToken) else {
            throw(KlaytnRequestError.urlError(urlToken))
        }
        let urlRequest = addKlaytnBasicHeaders(url: url)
        
        // Check cache.
        if let cachedData = cacheManager.getDataCache(for: .singleNFTInfo, url: url) {
            guard let nft = convertTo(type: KlaytnNft.self, data: cachedData) else {
                throw(KlaytnRequestError.convertUrlError(urlToken))
            }
            return nft
        } else {
            let (data, response) = try await urlSession.data(for: urlRequest)
            // Set cache.
            cacheManager.setCache(for: .singleNFTInfo, url: url, data: data, response: response)
            
            if KlaytnNftRequester.processResponse(data: data, response: response, error: nil) {
                guard let nft = convertTo(type: KlaytnNft.self, data: data) else {
//                    throw(KlaytnRequestError.convertUrlError(urlToken))
                    return nil
                }
                return nft
            } else {
                return nil
//                throw(KlaytnRequestError.badUrlResponse(response.description))
            }
        }
        
        
    }
    
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
        
        requestToNftsURL = url
        
        if let cachedData = cacheManager.getDataCache(for: .allNFTsInfo(walletAddress), url: url),
           let cachedUrlResponse = cacheManager.getResponseCache(for: .allNFTsInfo(walletAddress), url: url)
        {
            print("Using cached API Response")
            completionHandler(cachedData, cachedUrlResponse, nil)
            return true
        }
        print("Using Network Response")
        let urlRequest = addKlaytnBasicHeaders(url: url)
        
        let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: completionHandler)
        dataTask.resume()
        return true
    }
    
    // TODO: Leverage this function to get numbers of NFTs owned by a particular wallet address!
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
            
            cacheManager.setCache(for: .allNFTsInfo(walletAddress), url: requestToNftsURL, data: data, response: response) //TODO: setting cache is occurring everytime this method is called. Need to find another way to avoid unnecessary set.
            
            nftsHandler(nfts, nil)
        }
    }
    
    // MARK: - for Moono
    public static func requestToGetMoonoNfts(
        walletAddress: String,
        nftsHandler: @escaping ([MoonoNft]) -> Void
    ) -> Bool {
        return requestToGetNfts(
            contractAddress: KlaytnNftRequester.CONTRACT_ADDRESS__MOONO,
            walletAddress: walletAddress
        ) { nfts, error in
            guard let rawNfts = nfts else {
                LLog.w("rawNfts is nil : error: \(String(describing: error)).")
                return
            }
            
            requestToGetMoonoNfts(rawNfts: rawNfts) { moonoNfts in
                return nftsHandler(moonoNfts)
            }
        }
    }
    
    public static func requestToGetMoonoNfts(
        rawNfts: KlaytnNfts,
        nftsHandler: @escaping ([MoonoNft]) -> Void
    ) {
        var moonoNfts: [MoonoNft] = []
        var taskCount = rawNfts.items.count
        
        let taskLock = NSRecursiveLock()
        let dispatchQueue = DispatchQueue.global(qos: .utility)
        
        func discountTaskSafely() {
            taskLock.lock()
            taskCount -= 1
            taskLock.unlock()
        }
        
        rawNfts.items.forEach { rawItem in
            
            guard let tokenUri = rawItem.tokenUri, !tokenUri.isEmpty else {
                discountTaskSafely()
                LLog.w("Token uri found to be nil")
                return
            }
            
            let convertedTokenUri = tokenUri.replace(target: "ipfs://", withString: "https://ipfs.io/ipfs/")
     
            _ = requestSimple(urlToken: convertedTokenUri) { data, response, error in
                dispatchQueue.async {
                    guard processResponse(data: data, response: response, error: error),
                          let data = data else {
                        discountTaskSafely()
                        LLog.w("Invalid result.")
                        return
                    }
                    
                    guard let metadata = convertTo(type: MoonoNftMetadata.self, data: data) else {
                        discountTaskSafely()
                        LLog.w("metadata is nil.")
                        return
                    }
                    
                    taskLock.lock()
                    moonoNfts.append(createMoonoNft(rawNft: rawItem, metadata: metadata))
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
        
        nftsHandler(moonoNfts)
        taskLock.unlock()
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

extension KlaytnNftRequester {
    
    enum KlaytnRequestError: Error {
        case urlError(String)
        case convertUrlError(String)
        case badUrlResponse(String)
        case badData
        
        var description: String {
            switch self {
            case .urlError(let urlToken):
                return "Url is nil : urlToken: \(urlToken)."
            case .convertUrlError(let urlToken):
                return "Converting result data is failed : urlToken: \(urlToken)."
            case .badUrlResponse(let response):
                return "Bad URL Response - \(response)."
            case .badData:
                return self.description
            }
        }
    }
    
}
