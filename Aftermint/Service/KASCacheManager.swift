//
//  KASCacheManager.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/05/25.
//

import Foundation

enum KASRequestType: CaseIterable {
    case allNFTsInfo
    case singleNFTInfo
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
    
    init() {
        setInitialCache()
    }

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
        guard let targetCache = cacheDictionary[type],
              let urlResponseCache = urlResponseCacheDictionary[type],
              let response = response,
              let url = url
        else { return }
        let key = url.absoluteString as NSString
        let data = data as NSData
        targetCache.setObject(data, forKey: key)
        urlResponseCache.setObject(response, forKey: key)
    }
    
    private func setInitialCache() {
        KASRequestType.allCases.forEach { type in
            cacheDictionary[type] = NSCache<NSString, NSData>()
            urlResponseCacheDictionary[type] = NSCache<NSString, URLResponse>()
        }
    }
    
}
