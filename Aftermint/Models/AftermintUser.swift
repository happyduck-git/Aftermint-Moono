//
//  AftermintUser.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/29.
//

import Foundation

struct AfterMintUser: Storable {
    let username: String
    let address: String
    let imageUrl: String
    let popCount: Int64
    let actionCount: Int64
    let totalNfts: Int
}
