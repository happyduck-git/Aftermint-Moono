//
//  NftCollection.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/12.
//

import Foundation

struct NftCollection: Storable {
    let name: String
    let address: String
    let imageUrl: String
    let totalPopCount: Int64
    let totalActionCount: Int64
    let totalNfts: Int64
    let totalHolders: Int64
}
