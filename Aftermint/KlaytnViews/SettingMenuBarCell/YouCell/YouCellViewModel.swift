//
//  YouCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit.UIImage

final class YouCellViewModel {

    let currentUser: Box<Address?> = Box(nil)
    let nftRankViewModels: Box<[NftRankCellViewModel]> = Box([])
    let isLoaded: Box<Bool> = Box(false)
    
    func numberOfRowsAt() -> Int {
        return nftRankViewModels.value?.count ?? 0
    }

    func viewModelAt(_ indexPath: IndexPath) -> NftRankCellViewModel? {
        return nftRankViewModels.value?[indexPath.row]
    }
    
}
