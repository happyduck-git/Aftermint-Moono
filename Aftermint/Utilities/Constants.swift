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
//        static let temporaryAddress = "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB"
        static let temporaryAddress = "0x015a997c4CA73F9170AE60B1e89ddF703Aa3E2a1"
    }
    
    /// Firebase firestore related constants
    struct FStore {
        /// Collection names
        static let nftCardCollectionName: String = "NFT"
        static let nftAddressCollectionName: String = "Address"
        static let secondDepthCollectionName: String = "to"
        /// Document names
        static let nftCollectionDocumentName: String = "Moono"
        /// Field keys
        static let collectionIdFieldKey: String = "collectionId"
        static let actionCountFieldKey: String = "actionCount"
        static let imageUrlFieldKey: String = "imageUrl"
        static let popScoreFieldKey: String = "popScore"
        static let ownerAddressFieldKey: String = "ownerAddress"
        static let collectionLogoImageFieldKey: String = "collectionLogoImage"
        static let tokenIdFieldKey: String = "tokenId"
        static let countFieldKey: String = "touchCount"
        static let usernameFieldKey: String = "userName"
        static let profileImageUrlFieldKey: String = "profileImageUrl"
        static let totalHolderFieldKey: String = "totalHolder"
        static let totalMintedNFTsFieldKey: String = "totalMintedNFTs"
        static let ownedNFTsFieldKey: String = "ownedNFTs"
        ///Currently not in use
        static let totalDocumentName: String = "Total Count"
    }
    
}

/// LoginController related constants
enum LoginAsset: String {
    case backgroundImage = "moono_login_image"
    case loginDescription =  "멤버십 서비스 이용을 위해 NFT 지갑을 연결해주세요."
    case favorletButton = "favorletbutton"
    case kaikasButton = "kaikasbutton"
    case userPlaceHolderImage = "user_place_holder"
}

/// LottieController related constants
enum LottieAsset: String {
    case description =  """
    월요병아리님의 NFT를 가장 중요한 정보와 함께 자랑하세요!
    모두가 주목할 거에요. 🗝️
    """
    case refreshButton = "refresh"
    case redoButton = "redo"
    case undoButton = "undo"
    case sharedButton = "share_button"
    case backButton = "back"
}

/// GameController related constants
enum GameAsset: String {
    case gameVCLogo = "game_logo"
    case popRankLabel = "Pop Rank"
    case popScoreLabel = "Pop Score"
    case nftsLabel = "NFTs"
    case actionCountLabel = "Action Count"
}

/// GameViewController Bottom LeaderBoard related constants
enum LeaderBoardAsset: String {
    case title = "Leader board"
    case markImageName = "leader-board-mark"
    case firstPlace = "1st_place_medal"
    case secondPlace = "2nd_place_medal"
    case thirdPlace = "3rd_place_medal"
    case moonoImage = "game_moono_mock"
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

/// MarketController related constants
enum MarketAsset: String {
    case dropDown = "dropdown_image"
    case marketVCLogo = "marketplace_logo"
}

/// SettingController related constants
enum SettingAsset: String {
    case gameLogo = "gamecontroller"
    case dashBoardTitle = "POP DASHBOARD"
    case youButtonTitle = "You"
    case usersButtonTitle = "Users"
    case nftsButtonTitle = "NFTs"
    case projectsButtonTitle = "Projects"
    case walletAddressTitle = "Wallet Address"
    case usernameTitle = "Nickname"
    case popScoreTitle = "Total Pop Score"
    case actionCountTitle = "Action Count"
    case tableHeaderTitle = "Owned NFTs"
    case pointLabel = "point"
    case usersPopScoreTitle = "Project Pop Score"
    case usersActionScoreTitle = "Project Action Score"
    case usersPopScoreFirstSectionHeader = "Your Pop Score"
    case usersPopScoreSecondSectionHeader = "Users Pop Score Rank"
    case usersActionCountFirstSectionHeader = "Your Action Count"
    case usersActionCountSecondSectionHeader = "Users Action Count Rank"
    case nftsFirstSectionHeader = "Your Top NFT Pop Score"
    case nftsSecondSectionHeader = "NFT Pop Score"
    case projectsPopScoreTitle = "Pop Score"
    case totalNftsTitle = "Total NFTs"
    case totalHoldersTitle = "Total Holders"
    case emptyTitle = " "
}
