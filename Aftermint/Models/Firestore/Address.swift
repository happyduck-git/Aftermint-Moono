//
//  Address.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/30.
//

import Foundation

struct Address: Storable {
    let ownerAddress: String
    let actionCount: Int64
    let popScore: Int64
    let profileImageUrl: String
    let username: String
}
