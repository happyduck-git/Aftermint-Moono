//
//  Card.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation

struct Card: Storable, Codable {
    let ownerAddress: String
    let imageUrl: String
    let collectionAddress: String
    let tokenId: String
    let actionCount: Int64
    let popScore: Int64
}

