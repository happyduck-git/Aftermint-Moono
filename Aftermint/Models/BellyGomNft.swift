//
//  BellyGomNft.swift
//  Aftermint
//
//  Created by Hank on 2023/01/27.
//

import Foundation

struct BellyGomNft {
    
    let name: String
    let description: String
    let imageUrl: String
    let score: Int
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
        let body: String
        let clothes: String
        let head: String
        let acc: String
        let special: String
        let rank: Int
        let grade: GradeType
    }
    
    enum TraitType: String {
        case background_string = "Background"
        case body_string = "Body"
        case clothes_string = "Clothes"
        case head_string = "Head"
        case acc_string = "Acc"
        case special_string = "Special"
        case rank_int = "Rank"
        case grade_gradeType = "Grade"
    }
    
    enum GradeType: String {
        case belly = "Belly"
        case holic = "Holic"
        case mega = "Mega"
        case `super` = "Super"
        case surprise = "Surprise"
        case friends = "Friends"
    }
}
