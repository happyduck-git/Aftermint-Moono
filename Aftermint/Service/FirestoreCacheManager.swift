//
//  FirestoreCacheManager.swift
//  Aftermint
//
//  Created by Platfarm on 2023/06/07.
//

import Foundation

enum FirestoreRequestType {
    case getAllAddress
}

protocol FirestoreProtocol {
    func setAddressCache(for type: FirestoreRequestType, data: [Address])
}

final class FirestoreCacheManager: FirestoreProtocol {
    
    private var cacheDictionary: [FirestoreRequestType: NSCache<NSString, NSArray>] = [:]
    
    func setAddressCache(for type: FirestoreRequestType, data: [Address]) {
        cacheDictionary[type] = NSCache<NSString, NSArray>()
        cacheDictionary[type]?.setObject(data as NSArray, forKey: "AddressList")
    }
    
    func getAddressCache(for type: FirestoreRequestType, key: NSString) -> [Address]? {
        let addressList = cacheDictionary[type]?.object(forKey: key) as? [Address]
        return addressList
    }

}
