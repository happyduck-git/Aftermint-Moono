//
//  DashBoardNftCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit.UIImage

final class DashBoardNftCellViewModel {
    
    let mockUser = MoonoMockUserData().getOneUserData()
    
    var nftsList: Box<[NftRankCellViewModel]> = Box([])
    
    /// Among nftsList, filter and return current user's nfts
    func getCurrentUsersNfts() -> [NftRankCellViewModel] {
        let currentUsersNfts = self.nftsList.value?.filter({ vm in
            vm.ownerAddress == mockUser.address
        })
        
        guard let currentUsersNfts = currentUsersNfts else { return [] }
        return currentUsersNfts
    }
    
    /// Among current user's nfts, get the nft which has the highest score
    func getTheHighestScoreNftOfCurrentUser() -> NftRankCellViewModel? {
        return self.getCurrentUsersNfts().first
    }
    
}
