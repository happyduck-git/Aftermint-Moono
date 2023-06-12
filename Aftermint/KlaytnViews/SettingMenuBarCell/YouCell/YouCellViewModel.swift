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
    
    func getCurrentUserCards(
        address: String,
        gameType: GameType,
        nftsOwned: [String: String]
    ) async {
        
        do {
            guard let cards = try await FirestoreRepository.shared.getCurrentUserCards(
                address: address,
                gameType: gameType,
                nftsOwned: nftsOwned
            ) else {
                return
            }
            
            let vmList = cards.map { card in
                
                let vm = NftRankCellViewModel(
                    rank: 0,
                    rankImage: UIImage(contentsOfFile: LeaderBoardAsset.firstPlace.rawValue),
                    nftImageUrl: card.imageUrl,
                    nftName: "Moono #\(card.tokenId)",
                    score: card.popScore,
                    ownerAddress: card.ownerAddress
                )
                return vm
            }
            nftRankViewModels.value = vmList
            isLoaded.value = true
        }
        catch {
            print("Error getting current users cards --- \(error.localizedDescription)")
        }
     
    }
    
}
