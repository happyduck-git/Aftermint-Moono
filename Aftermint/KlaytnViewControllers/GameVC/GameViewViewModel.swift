//
//  GameViewViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/05/26.
//

import Foundation

protocol GameViewViewModelProtocol {
    func getOwnedNfts()
}

final class GameViewViewModel: GameViewViewModelProtocol {
    
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
        nftTokenId: [String],
        ownerAddress: String
    ) {
        firestoreRepository.saveToNewDB(
            popScore: popScore,
            nftTokenId: nftTokenId,
            ownerAddress: ownerAddress
        )
    }
    
}
