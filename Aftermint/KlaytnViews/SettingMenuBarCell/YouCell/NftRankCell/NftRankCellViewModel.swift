//
//  NftRankCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class NftRankCellViewModel {
    var rank: Int
    let nftImageUrl: String
    let nftName: String
    let score: Int64
    let ownerAddress: String
    
    init(rank: Int, nftImageUrl: String, nftName: String, score: Int64, ownerAddress: String) {
        self.rank = rank
        self.nftImageUrl = nftImageUrl
        self.nftName = nftName
        self.score = score
        self.ownerAddress = ownerAddress
    }
    
    //MARK: - Internal Function
    
    func setRankNumberWithIndexPath(_ indexPathRow: Int) {
        self.rank = indexPathRow
    }
}
