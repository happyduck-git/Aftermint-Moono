//
//  APICacheManager.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/11.
//

import Foundation

final class APICacheManager {
    
    /// 1. Cache per Owner address [Address]
    private var cachedObject: NSCache<NSString, NSObject> = NSCache()
    
    
    /// Set cache
    /// - Parameters:
    ///   - ownerAddress: wallet address of the owner
    ///   - object: object that needs to be saved
    public func setCache(ownerAddress: String, object: NSObject) {
        self.cachedObject.setObject(object, forKey: ownerAddress as NSString)
    }
    
    public func getCache(ownerAddress: String) -> NSObject? {
        let key = ownerAddress as NSString
        return self.cachedObject.object(forKey: key)
    }
    
    
    
    /// 2. Cache per Moono tokenId
    
}
