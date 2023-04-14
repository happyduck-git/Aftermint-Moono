//
//  BellyGomFont.swift
//  Aftermint
//
//  Created by Platfarm on 2023/02/03.
//

import UIKit

struct BellyGomFont {
    
    enum NanumFont: String {
        case Light = "NanumSquareRoundOTFL"
        case Regular = "NanumSquareRoundOTFR"
        case Bold = "NanumSquareRoundOTFB"
        case ExtraBold = "NanumSquareRoundOTFEB"
    }
    
    static let header01 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 36)
    static let header02 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 28)
    static let header03 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 20)
    static let header04 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 16)
    static let header05 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 12)
    static let header06 = UIFont(name: NanumFont.Regular.rawValue, size: 12)
    static let header07 = UIFont(name: NanumFont.Regular.rawValue, size: 14)
    static let header08 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 18)
    static let header09 = UIFont(name: NanumFont.ExtraBold.rawValue, size: 22)
    
    static let tag = UIFont(name: NanumFont.ExtraBold.rawValue, size: 10)
    
}

