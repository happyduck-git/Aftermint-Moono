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
    
    var address: String {
        switch self {
        case .bellyGom:
            return "0xce70eef5adac126c37c8bc0c1228d48b70066d03"
        case .moono:
            return "0x29421a3c92075348fcbcb04de965e802ed187302"
        }
    }
}
