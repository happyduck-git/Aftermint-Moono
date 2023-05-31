//
//  CollectionType.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/30.
//

import Foundation

enum CollectionType: String {
    case bellyGom = "bellygom"
    case moono = "moono"
    
    var displayName: String {
        switch self {
        case .bellyGom:
            return "BellyGom"
        case .moono:
            return "Moono Week"
        }
    }
}
