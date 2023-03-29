//
//  TwitterLoginUtility.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/27.
//

import Foundation
import CryptoKit
import CommonCrypto

final class TwitterUtility {
    
    static let shared = TwitterUtility()
    
    private init() {}
    
    func authorizationHeader(params: [String: Any]) -> String {
        var parts: [String] = []
        for param in params {
            let key = param.key.urlEncoded
            let val = "\(param.value)".urlEncoded
            parts.append("\(key)=\"\(val)\"")
        }
        return "OAuth " + parts.sorted().joined(separator: ", ")
    }
    
    func oauthSignature(httpMethod: String = "POST", url: String, params: [String: Any], consumerSecret: String, oauthTokenSecret: String? = nil) -> String {
        let signingKey = signatureKey(consumerSecret, oauthTokenSecret)
        let signatureBase = signatureBaseString(httpMethod, url, params)
        print("signingKey: \(signingKey)")
        print("signatureBase:\n \(signatureBase)\n---")
        return hmac_sha1(signingKey: signingKey, signatureBase: signatureBase)
    }
    
    private func signatureKey(_ consumerSecret: String, _ oauthTokenSecret: String?) -> String {
        guard let oauthSecret = oauthTokenSecret?.urlEncoded else {
            return consumerSecret.urlEncoded + "&"
        }
        return consumerSecret.urlEncoded + "&" + oauthSecret
    }
    
    private func signatureParameterString(params: [String: Any]) -> String {
        var result: [String] = []
        for param in params {
            let key = param.key.urlEncoded
            let val = "\(param.value)".urlEncoded
            result.append("\(key)=\(val)")
        }
        return result.sorted().joined(separator: "&")
    }
    
    private func signatureBaseString(_ httpMethod: String = "POST", _ url: String, _ params: [String:Any]) -> String {
        let param = params
        let parameterString = signatureParameterString(params: param)
        return httpMethod + "&" + url.urlEncoded + "&" + parameterString.urlEncoded
    }
    
    private func hmac_sha1(signingKey: String, signatureBase: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, signatureBase, signatureBase.count, &digest)
        let data = Data(digest)
        return data.base64EncodedString(options: .lineLength64Characters)
    }
}
