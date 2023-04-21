//
//  UsersCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class UsersCellViewModel {
    
    let currentNft: Box<NftCollection?> = Box(nil)
    var usersList: Box<[PopScoreRankCellViewModel]> = Box([])

}
