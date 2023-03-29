//
//  OpenSeaApiRequester.swift
//  Aftermint
//
//  Created by Hank on 2023/03/09.
//

import Foundation

class OpenSeaApiRequester {
    private static let url__retrieve_an_asset__params_2 = "https://api.opensea.io/api/v1/asset/%@/%@/"
    private static let header_key__api_key = "X-API-KEY"
    private static let header_value__api_key = "ed2e41d7243b46758eb27e035fdbd134"
    
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
    
    // MARK: Get result from OpenSea
    public static func requestToGetOpenSeaAsset(
        contractAddress: String,
        tokenId: String,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> Bool {
        let urlSession = URLSession(configuration: .default)
        
        let urlToken = String(
            format: OpenSeaApiRequester.url__retrieve_an_asset__params_2,
            contractAddress,
            UInt32(tokenId.dropFirst(2), radix: 16) ?? 0
        )
        let urlComponents = URLComponents(string: urlToken)
        
        guard let url = urlComponents?.url else {
            let errorMessage = "Url is nil : urlToken: \(urlToken), contractAddress: \(contractAddress), tokenId: \(tokenId)."
            completionHandler(nil, nil, NSError(domain: errorMessage, code: -1))
            LLog.w(errorMessage)
            return false
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(
            OpenSeaApiRequester.header_value__api_key,
            forHTTPHeaderField: OpenSeaApiRequester.header_value__api_key
        )
        
        let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: completionHandler)
        dataTask.resume()
        return true
    }
    
    public static func requestToGetOpenSeaAssetImageUrl(
        contractAddress: String,
        tokenId: String,
        imageUrlHandler: @escaping (String?, Error?) -> Void
    ) -> Bool {
        return requestToGetOpenSeaAsset(contractAddress: contractAddress, tokenId: tokenId) { data, response, error in
            let result = OpenSeaApiRequester.processResponse(data: data, response: response, error: error)
            guard let data = data, result else {
                let errorMessage = "Invalid result : contractAddress: \(contractAddress), tokenId: \(tokenId)."
                imageUrlHandler(nil, NSError(domain: errorMessage, code: -1))
                LLog.w(errorMessage)
                return
            }
            
            guard let imageUrl = getPreviewImageUrlFromOpenSeaAsset(data: data) else {
                let errorMessage = "getPreviewImageUrlFromOpenSeaAsset() is failed : contractAddress: \(contractAddress), tokenId: \(tokenId)."
                imageUrlHandler(nil, NSError(domain: errorMessage, code: -1))
                LLog.w(errorMessage)
                return
            }
            
            imageUrlHandler(imageUrl, nil)
        }
    }
    
    private static func getPreviewImageUrlFromOpenSeaAsset(data: Data) -> String? {
        guard let jsonData = convertToJson(data: data, showLog: false) as? [String: Any?] else {
            LLog.w("jsonData is nil.")
            return nil
        }
        
        guard let imageUrl = jsonData["image_url"] as? String else {
            LLog.w("imageUrl is nil. jsonData: \(jsonData).")
            return nil
        }
        return imageUrl
    }
}
