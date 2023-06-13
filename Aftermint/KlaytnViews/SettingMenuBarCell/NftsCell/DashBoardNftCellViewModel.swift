//
//  DashBoardNftCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit.UIImage
import FirebaseFirestore

final class DashBoardNftCellViewModel {
    
    let mockUser = MoonoMockUserData().getOneUserData()
    
    var highestNft: Box<NftRankCellViewModel?> = Box(nil)
    var nftsList: Box<[NftRankCellViewModel]> = Box([])
    
    var lastDoc: QueryDocumentSnapshot?
    var isLoadingMorePosts: Bool = false
    
    func numberOfRowsAt(_ section: Int) -> Int {
        if section == 0 {
            guard let value = highestNft.value,
                  value != nil else {
                return 0
            }
            return 1
        } else {
            return nftsList.value?.count ?? 0
        }
    }
    
    func viewModelAt(_ indexPath: IndexPath) -> NftRankCellViewModel? {
        if indexPath.section == 0 {
            return highestNft.value ?? nil
        } else {
            return nftsList.value?[indexPath.row]
        }
    }
    
    /// Among current user's nfts, get the nft which has the highest score
    func getTheHighestScoreNftOfCurrentUser() {
        self.highestNft.value = self.nftsList.value?
            .filter({ vm in
            return vm.ownerAddress == mockUser.address
        })
            .first
        
        guard let value = highestNft.value,
              let result = value else {
            return
        }
        print("Highest: \(result.rank)")
    }
    
}
