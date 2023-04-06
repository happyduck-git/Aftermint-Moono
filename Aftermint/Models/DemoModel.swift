//
//  DemoModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/03/31.
//

import Foundation

struct NftCollectionTest: Storable {
    let name: String
    let address: String
    let imageUrl: String
    let totalPopCount: Int64
    let totalActionCount: Int64
    let totalNfts: Int
    let totalHolders: Int
}

struct AfterMintUserTest: Storable {
    let username: String
    let address: String
    let imageUrl: String
    let popCount: Int64
    let actionCount: Int64
    let totalNfts: Int
}

struct CardTest: Storable {
//    let tokenId: String
//    let collectionAddress: String
    let ownerAddress: String
    let popScore: Int64
    let actionCount: Int64
    let imageUrl: String
}

struct AddressTest: Storable {
    let ownerAddress: String
    let actionCount: Int64
    let popScore: Int64
    let profileImageUrl: String
    let username: String
    let card: [CardGameData]
}

struct CardGameData {
    let tokenId: String
    let imageUrl: String
    let actionCount: Int64
    let popScore: Int64
}
