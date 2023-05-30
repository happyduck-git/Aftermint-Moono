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
    func saveToNewDB(popScore: Int64, actionCount: Int64, nftTokenId: [String], ownerAddress: String, completion: @escaping (() -> Void))
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
    
    func saveToNewDB(
        popScore: Int64,
        actionCount: Int64,
        nftTokenId: [String],
        ownerAddress: String,
        completion: @escaping (() -> Void)
    ) {
        firestoreRepository.saveToNewDB(
            popScore: popScore,
            actionCount: actionCount,
            nftTokenId: nftTokenId,
            ownerAddress: ownerAddress,
            completion: completion
        )
    }
    
    // new db get data test
    func getAllScore() {
        firestoreRepository.getAllAddress { _ in
            
        }
    }
    
}
