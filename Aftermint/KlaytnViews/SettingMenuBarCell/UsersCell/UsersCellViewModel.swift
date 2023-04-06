//
//  UsersCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class UsersCellViewModel {
    
    let currentNft: Box<NftCollectionTest?> = Box(nil)
    let usersList: Box<[PopScoreRankCellViewModel]> = Box([])
    var currentUserVM: PopScoreRankCellViewModel? {
        let filteredList = self.usersList.value?.filter({ vm in
            vm.owerAddress == MoonoMockUserData().getOneUserData().address
        })
        return filteredList?.first
    }
}
