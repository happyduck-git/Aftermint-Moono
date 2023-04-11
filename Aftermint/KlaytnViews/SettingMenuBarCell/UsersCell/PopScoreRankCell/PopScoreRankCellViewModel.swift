//
//  PopScoreRankCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit.UIImage

final class PopScoreRankCellViewModel {
    var rankImage: UIImage?
    var rank: Int
    let profileImageUrl: String
    let ownerAddress: String
    let totalNfts: Int
    let popScore: Int64
    let actioncount: Int64
    
    init(rankImage: UIImage?, rank: Int, profileImageUrl: String, owerAddress: String, totalNfts: Int, popScore: Int64, actioncount: Int64) {
        self.rankImage = rankImage
        self.rank = rank
        self.profileImageUrl = profileImageUrl
        self.ownerAddress = owerAddress
        self.totalNfts = totalNfts
        self.popScore = popScore
        self.actioncount = actioncount
    }
    
    //MARK: - Internal function
    func setRankImage(with image: UIImage?) {
        guard let image = image else { return }
        self.rankImage = image
    }
    
    func setRankNumberWithIndexPath(_ indexPathRow: Int) {
        self.rank = indexPathRow
    }
}
