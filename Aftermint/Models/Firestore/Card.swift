//
//  Card.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation

struct Card: Storable, Codable {
    let imageUri: String
    let collectionId: String
    let tokenId: String
    let count: Int64
}

