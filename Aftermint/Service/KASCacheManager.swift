//
//  KASCacheManager.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/05/25.
//

import Foundation

enum KASRequestType: CaseIterable, Hashable {
    static var allCases: [KASRequestType] {
        return [.allNFTsInfo(""), singleNFTInfo]
    }
    
    case allNFTsInfo(String)
    case singleNFTInfo
    case numberOfNfts
    case numberOfHolders
}

protocol CacheManagerProtocol {
    func getDataCache(for type: KASRequestType, url: URL?) -> Data?
    func setCache(for type: KASRequestType, url: URL?, data: Data, response: URLResponse?)
}

final class KASCacheManager: CacheManagerProtocol {
    
    private var cacheDictionary: [KASRequestType: NSCache<NSString, NSData>] = [:]
    private var urlResponseCacheDictionary: [KASRequestType: NSCache<NSString, URLResponse>] = [:]
    
//    private let collectionType: CollectionType
//    private var cacheDictionary: [CollectionType: NSCache<NSString, NSData>] = [:]
//    private var urlResponseCacheDictionary: [CollectionType: NSCache<NSString, URLResponse>] = [:]
    
    init() {}

    func getDataCache(for type: KASRequestType, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[type],
              let url = url
        else { return nil }
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }
    
    func getResponseCache(for type: KASRequestType, url: URL?) -> URLResponse? {
        guard let urlResponseCache = urlResponseCacheDictionary[type],
              let url = url
        else { return nil }
        let key = url.absoluteString as NSString
        return urlResponseCache.object(forKey: key)
    }
    
    func setCache(for type: KASRequestType, url: URL?, data: Data, response: URLResponse?) {
        guard let response = response,
              let url = url
        else { return }
        let key = url.absoluteString as NSString
        let data = data as NSData
        cacheDictionary[type] = NSCache<NSString, NSData>()
        cacheDictionary[type]?.setObject(data, forKey: key)
        urlResponseCacheDictionary[type] = NSCache<NSString, URLResponse>()
        urlResponseCacheDictionary[type]?.setObject(response, forKey: key)
    }

}
