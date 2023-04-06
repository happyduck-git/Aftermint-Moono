//
//  NftRankCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class NftRankCellViewModel {
    let rank: Int
    let nftImageUrl: String
    let nftName: String
    let score: Int64
    
    init(rank: Int, nftImageUrl: String, nftName: String, score: Int64) {
        self.rank = rank
        self.nftImageUrl = nftImageUrl
        self.nftName = nftName
        self.score = score
    }
}
