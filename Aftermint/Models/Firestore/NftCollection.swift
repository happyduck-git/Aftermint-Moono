//
//  NftCollection.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation

struct NftCollection: Storable {
    let collectionId: String
    let collectionLogoImage: String
    let count: Int64
}
