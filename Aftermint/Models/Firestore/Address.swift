//
//  Address.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/30.
//

import Foundation

class Address: NSObject, Storable {
    let ownerAddress: String
    let actionCount: Int64
    let popScore: Int64
    let profileImageUrl: String
    let username: String
    
    init(ownerAddress: String, actionCount: Int64, popScore: Int64, profileImageUrl: String, username: String) {
        self.ownerAddress = ownerAddress
        self.actionCount = actionCount
        self.popScore = popScore
        self.profileImageUrl = profileImageUrl
        self.username = username
    }
}
