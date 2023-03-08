//
//  KASConnectService.swift
//  Aftermint
//
//  Created by Platfarm on 2023/02/01.
//

import Foundation
class KASConnectService {
    
    // MARK: - Singleton init
    static let shared: KASConnectService = KASConnectService()
    private init() {}
    private let session = URLSession(configuration: .default)
    
    // MARK: - Wallet Connect Servcies
    
    func getTokenID() async throws -> String? {
        
        let urlString: String = "https://api.kaikas.io/api/v1/k/prepare"
        
        
        //URL
        guard let url = URL(string: urlString) else {
            print("URL not available")
            return nil
        }
        
        //Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      
        
        let body: [String: Any] = [
            "type": "auth",
            "bapp": [
                "name": "test app",
                "callback": [
                    "success": "kaikas://",
                    "fail": "kaikas://"
                ]
            ]
        ]
        var bodyData: Data = Data()
        do {
            bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error JSON Serializastion HTTP Body Data \(error.localizedDescription)")
        }
        
        request.httpBody = bodyData
        
        //Data Task
        let (data, response) = try await session.data(for: request)
        let sucessRange = 200..<300
        guard let httpResponse = response as? HTTPURLResponse,
              sucessRange.contains(httpResponse.statusCode) else {
            print("Error http response")
            return nil
            
        }
        
        let output = try JSONDecoder().decode(KlaytnPrepareResponse.self, from: data)
        
        return output.requestKey
    }
    
    
    
    func getWalletAddress(requestKey: String) async throws -> String? {

        let urlString = "https://api.kaikas.io/api/v1/k/result/\(requestKey)"

        guard let url = URL(string: urlString) else {
            print("URL not available")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        //Data Task
        let (data, response) = try await session.data(for: request)
        let sucessRange = 200..<300
        guard let httpResponse = response as? HTTPURLResponse,
              sucessRange.contains(httpResponse.statusCode) else {
            print("Error http response")
            return nil
            
        }
        
        let output = try JSONDecoder().decode(KlaytnAuthResult.self, from: data)
        
        return output.result?.klaytnAddress
        
    }
    
}
