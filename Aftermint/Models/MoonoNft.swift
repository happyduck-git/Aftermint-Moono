//
//  MoonoNft.swift
//  Aftermint
//
//  Created by Hank on 2023/03/08.
//

import Foundation

struct MoonoNft {
    let name: String
    let description: String
    let imageUrl: String
    let tokenId: String
    let updateAt: Int64
    let previousOwnerAddress: String
    let traits: Traits
    
    var tokenIdInteger: UInt32 {
        get {
            return UInt32(tokenId.dropFirst(2), radix: 16) ?? 0
        }
    }
    
    struct Traits {
        let background: String
        let effect: String
        let body: String
        let day: String
        let expression: String
        let accessories: String
        let hair: String
    }
    
    enum TraitType: String {
        case background_string = "Background"
        case effect_string = "Effect"
        case body_string = "Body"
        case day_string = "Day"
        case expression_string = "Expression"
        case accessories_string = "Accessories"
        case hair_string = "Hair"
    }
}
