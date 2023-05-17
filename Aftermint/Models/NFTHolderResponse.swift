//
//  NFTHolderResponse.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/12.
//

import Foundation

struct NFTHolderResponse: Decodable {
    let address: String
    let totalHolder: Int
}
