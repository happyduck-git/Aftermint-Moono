//
//  Card.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/12.
//

import Foundation

struct Card: Storable {
    let tokenId: String
    let ownerAddress: String
    let popScore: Int64
    let actionCount: Int64
    let imageUrl: String
}
