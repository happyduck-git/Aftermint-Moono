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

struct Card: Storable {
    let tokenId: String
    let ownerAddress: String
    let popScore: Int64
    let actionCount: Int64
    let imageUrl: String
}
