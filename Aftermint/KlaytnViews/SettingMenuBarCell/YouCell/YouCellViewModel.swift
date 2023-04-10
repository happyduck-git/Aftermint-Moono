//
//  YouCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit.UIImage

final class YouCellViewModel {
    
    enum YouCellViewModelError: Error {
        case rankCellFetchError
    }
    
    let fireStoreRepository = FirestoreRepository.shared
    
    var currentUser: Box<Address?> = Box(nil)
    var nftRankViewModels: Box<[NftRankCellViewModel]> = Box([])
    
}
