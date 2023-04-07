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
    var addressList: Box<[Address]> = Box([]) /// SettingVM 테스트!
    
    /// Find a user who has the same wallet address
    func getCurrentUserData(completion: @escaping (Result<Address, Error>) -> Void) {
        let mockUser = MoonoMockUserData().getOneUserData()
        
        self.fireStoreRepository.getAllAddress { addressList in
            guard let currentUser = addressList?.filter({ address in
                return address.ownerAddress == mockUser.address
            }).first else { return }
            completion(.success(currentUser))
        }
    }
    
    func getAllOwnedNft(collectionType: CollectionType, completion: @escaping (Result<[NftRankCellViewModel], Error>) -> Void) {
        self.fireStoreRepository.getAllNftData(ofCollectionType: collectionType) { cardList in
            guard let cardList = cardList else { return }
            let result = cardList.map { card in
                return NftRankCellViewModel(
                    rank: 0,
                    nftImageUrl: card.imageUrl,
                    nftName: card.nftName,
                    score: card.popScore,
                    ownerAddress: card.ownerAddress
                )
            }
            completion(.success(result))
            return
        }
        completion(.failure(YouCellViewModelError.rankCellFetchError))
        return
    }
    
}
