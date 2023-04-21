//
//  NftRankCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit.UIImage

final class NftRankCellViewModel {
    var rank: Int
    var rankImage: UIImage?
    let nftImageUrl: String
    let nftName: String
    let score: Int64
    let ownerAddress: String
    
    init(rank: Int, rankImage: UIImage?, nftImageUrl: String, nftName: String, score: Int64, ownerAddress: String) {
        self.rank = rank
        self.rankImage = rankImage
        self.nftImageUrl = nftImageUrl
        self.nftName = nftName
        self.score = score
        self.ownerAddress = ownerAddress
    }
    
    //MARK: - Internal Function
    
    func setRankNumberWithIndexPath(_ indexPathRow: Int) {
        self.rank = indexPathRow
    }
    
    func setRankImage(with image: UIImage?) {
        guard let image = image else { return }
        self.rankImage = image
    }
    
}
