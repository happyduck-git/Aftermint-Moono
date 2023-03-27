//
//  Constants.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/02/25.
//

import Foundation

struct K {
    
    struct ContractAddress {
        static let moono = "0x29421a3c92075348fcbcb04de965e802ed187302"
    }
    
    /// Wallet related constants
    struct Wallet {
        static let temporaryAddress = "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB"
    }
    
    /// Firebase firestore related constants
    struct FStore {
        static let nftCardCollectionName: String = "NFT"
        static let nftCollectionCollectionName: String = "Collection"
        static let nftCollectionDocumentName: String = "Moono"
        static let collectionIdFieldKey: String = "collectionId"
        static let imageUriFieldKey: String = "imageUrl"
        static let collectionLogoImageFieldKey: String = "collectionLogoImage"
        static let tokenIdFieldKey: String = "tokenId"
        static let countFieldKey: String = "touchCount"
        ///Currently not in use
        static let totalDocumentName: String = "Total Count"
    }
    
}

/// GameViewController Bottom LeaderBoard related constants
enum LeaderBoard: String {
    case title = "Leader board"
    case markImageName = "leader-board-mark"
    case firstPlace = "1st_place_medal"
    case secondPlace = "2nd_place_medal"
    case thirdPlace = "3rd_place_medal"
}

/// GameScene related constants
enum GameSceneAsset: String {
    case particles = "SparkParticle.sks"
    case moonoImage = "game_moono_mock"
}

/// TabBarController related constants
enum TabBarAsset: String {
    case mainOn = "main_on"
    case mainOff = "main_off"
    case giftOn = "gift_on"
    case giftOff = "gift_off"
    case marketOff = "market_off"
    case marketOn = "market_on"
    case gameOn = "game_on"
    case gameOff = "game_off"
    case settingOn = "setting_on"
    case settingOff = "setting_off"
}

enum NavigationBarAsset: String {
    case gameVCLogo = "game_logo"
}
