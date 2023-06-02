//
//  GameViewViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/05/26.
//

import Foundation

protocol GameViewViewModelDelegate: AnyObject {
    func dataSaved()
}

protocol GameViewViewModelProtocol {
    func getOwnedNfts()
    func saveScoreCache(popScore: Int64, actionCount: Int64, ownerAddress: String, completion: @escaping (() -> Void))
}

final class GameViewViewModel: GameViewViewModelProtocol {
    
    weak var delegate: GameViewViewModelDelegate?
    
    private let firestoreRepository = FirestoreRepository.shared
    
    public private(set) var ownedNftTokenIds: Box<[String]> = Box([])
    private let mockUser: AfterMintUser = MoonoMockUserData().getOneUserData()
    
    func getOwnedNfts() {
        _ = KlaytnNftRequester
            .requestToGetMoonoNfts(walletAddress: mockUser.address)
        { [weak self] nfts in
            guard let `self` = self else { return }
            self.ownedNftTokenIds.value = nfts.compactMap { nft in
                nft.tokenId
            }
        }
    }
    
    /// Save game scores during the game.
    /// - Parameters:
    ///   - popScore: Numbers of touch counted multiplied by numbers of nfts that the owner holds.
    ///   - actionCount: Numbers of touch counted.
    ///   - ownerAddress: The owner's wallet address.
    ///   - completion: Call back.
    func saveScoreCache(
        popScore: Int64,
        actionCount: Int64,
        ownerAddress: String,
        completion: @escaping (() -> Void)
    ) {
        firestoreRepository.saveScoreCache(
            popScore: popScore,
            actionCount: actionCount,
            ownerAddress: ownerAddress,
            completion: completion)
    }
    
    /// Save touch count to each of NFT that an owner holds.
    /// Especially when the game ends.
    /// - Parameters:
    ///   - actionCount: Numbers of touch counted during the game.
    ///   - nftTokenId: NFT token ids that the owner holds.
    ///   - ownerAddress: The owner's wallet address.
    ///   - completion: Call back.
    func saveNFTScores(
        actionCount: Int64,
        nftTokenId: [String],
        ownerAddress: String,
        completion: @escaping (() -> Void)
    ) {
        firestoreRepository.saveNFTScores(
            actionCount: actionCount,
            nftTokenId: nftTokenId,
            ownerAddress: ownerAddress,
            completion: completion
        )
    }
    
    // new db get data test
    func getAllScore() {
//        firestoreRepository.getAllAddress { adressList in
//            guard let list = adressList else { return }
//            print(list)
//        }
    }
    
}
