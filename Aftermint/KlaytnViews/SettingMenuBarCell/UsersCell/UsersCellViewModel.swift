//
//  UsersCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class UsersCellViewModel {
    
    let currentNft: Box<CardTest?> = Box(nil)
    let usersList: Box<[PopScoreRankCellViewModel]> = Box([])
    
}
