//
//  UsersCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class UsersCellViewModel {
    
    let currentNft: Box<NftCollection?> = Box(nil)
    let usersList: Box<[PopScoreRankCellViewModel]> = Box([])
    let currentUserInfo: Box<PopScoreRankCellViewModel?> = Box(nil)
    let isLoaded: Box<Bool> = Box(false)
    
    func numberOfRowsAt(_ section: Int) -> Int {
        if section == 0 {
            guard currentUserInfo.value! != nil else {
                return 0
            }
            return 1
        } else {
            return usersList.value?.count ?? 0
        }
    }

    func viewModelAt(_ indexPath: IndexPath) -> PopScoreRankCellViewModel? {
        if indexPath.section == 0 {
            return currentUserInfo.value ?? nil
        } else {
            return usersList.value?[indexPath.row]
        }
    }
}
