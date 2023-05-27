//
//  KASCacheManager.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/05/25.
//

import Foundation

protocol CacheManagerProtocol {
    func getDataCache(url: URL?) -> Data?
    func setCache(url: URL?, data: Data, response: URLResponse?)
}

final class KASCacheManager: CacheManagerProtocol {
    
    private let collectionType: CollectionType
    private var cacheDictionary: [CollectionType: NSCache<NSString, NSData>] = [:]
    private var urlResponseCacheDictionary: [CollectionType: NSCache<NSString, URLResponse>] = [:]
    
    init(type: CollectionType) {
        self.collectionType = type
        setInitialCache()
    }

    func getDataCache(url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[collectionType],
              let url = url
        else { return nil }
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }
    
    func getResponseCache(url: URL?) -> URLResponse? {
        guard let urlResponseCache = urlResponseCacheDictionary[collectionType],
              let url = url
        else { return nil }
        let key = url.absoluteString as NSString
        return urlResponseCache.object(forKey: key)
    }
    
    func setCache(url: URL?, data: Data, response: URLResponse?) {
        guard let targetCache = cacheDictionary[collectionType],
              let urlResponseCache = urlResponseCacheDictionary[collectionType],
              let response = response,
              let url = url
        else { return }
        let key = url.absoluteString as NSString
        let data = data as NSData
        targetCache.setObject(data, forKey: key)
        urlResponseCache.setObject(response, forKey: key)
    }
    
    private func setInitialCache() {
        cacheDictionary[collectionType] = NSCache<NSString, NSData>()
        urlResponseCacheDictionary[collectionType] = NSCache<NSString, URLResponse>()
    }
    
}
