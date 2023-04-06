//
//  ProjectPopScoreCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/06.
//

import UIKit.UIImage

final class ProjectPopScoreCellViewModel {
    var rankImage: UIImage?
    var rank: Int
    let nftImageUrl: String
    let nftCollectionName: String
    let totalNfts: Int
    let totalHolders: Int
    let popScore: Int64
    let actioncount: Int64
    
    init(rankImage: UIImage? = nil, rank: Int, nftImageUrl: String, nftCollectionName: String, totalNfts: Int, totalHolders: Int, popScore: Int64, actioncount: Int64) {
        self.rankImage = rankImage
        self.rank = rank
        self.nftImageUrl = nftImageUrl
        self.nftCollectionName = nftCollectionName
        self.totalNfts = totalNfts
        self.totalHolders = totalHolders
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
