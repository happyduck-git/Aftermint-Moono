//
//  NFTContractInfoResponse.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/12.
//

import Foundation

struct NFTContractInfoResponse: Decodable {
    let address: String
    let name: String
    let totalSupply: String
}
