//
//  MoonoMockImageData.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/28.
//

import UIKit.UIImage

struct MoonoMockImageData {
    
     private let dummyImageList: [UIImage?] = [
         UIImage(named: "nftimage1"),
         UIImage(named: "nftimage2"),
         UIImage(named: "nftimage3"),
         UIImage(named: "nftimage4"),
         UIImage(named: "nftimage5"),
         UIImage(named: "nftimage6"),
         UIImage(named: "nftimage7"),
         UIImage(named: "nftimage8")
     ]
    
    public var moonoDummyImages: [UIImage?] {
        get {
            return dummyImageList
        }
    }
    
}
