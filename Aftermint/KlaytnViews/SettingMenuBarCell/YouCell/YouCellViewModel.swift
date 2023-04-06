//
//  YouCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import Foundation

final class YouCellViewModel {
    
    enum YouCellViewModelError: Error {
        case rankCellFetchError
    }
    
    let fireStoreRepository = FirestoreRepository.shared
    var currentUser: Box<AddressTest?> = Box(nil)
    var nftRankViewModels: Box<[NftRankCellViewModel]> = Box([])
    var addressList: Box<[AddressTest]> = Box([]) /// SettingVM 테스트!
    
    /// Find a user who has the same wallet address
    func getCurrentUserData(completion: @escaping (Result<AddressTest, Error>) -> Void) {
        let mockUser = MoonoMockUserData().getOneUserData()
        
        self.fireStoreRepository.getAllAddress { addressList in
            guard let currentUser = addressList?.filter({ address in
                return address.ownerAddress == mockUser.address
            }).first else { return }
            completion(.success(currentUser))
        }
    }
    
    func getAllOwnedNft(collectionType: CollectionType, completion: @escaping (Result<[NftRankCellViewModel], Error>) -> Void) {
        self.fireStoreRepository.getAllOwnedCardData(ofCollectionType: collectionType) { cardList in
            guard let cardList = cardList else { return }
            let result = cardList.map { card in
                return NftRankCellViewModel(rank: 0,
                                            nftImageUrl: card.imageUrl,
                                            nftName: "Moono #123", //TODO: nft name 수정필요
                                            score: card.popCount)
            }
            completion(.success(result))
            return
        }
        completion(.failure(YouCellViewModelError.rankCellFetchError))
        return
    }
    
}
