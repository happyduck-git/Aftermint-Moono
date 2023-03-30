//
//  NftCollection.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation

struct NftCollection: Storable {
    let collectionName: String
    let collectionId: String
    let collectionLogoImage: String
    let totalPopCount: Int64
    let totalActionCount: Int64
}
