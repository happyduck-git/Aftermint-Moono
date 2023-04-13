//
//  NFTCardViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/02/25.
//

import Foundation

class NFTCardViewModel {
    
    var nftCardCellViewModel: Box<[NftCardCellViewModel]> = Box([])
    var nftSelected: [Bool] = []
    let fireStoreRepository = FirestoreRepository.shared
    
    func numberOfItemsInSection() -> Int {
        guard let numberOfItems = self.nftCardCellViewModel.value?.count else {
            return 0
        }
        self.nftSelected = Array(repeating: false, count: numberOfItems)
        print("numberofNfts: \(numberOfItems)")
        
        /// Save total number of nfts an owner has
        self.fireStoreRepository.saveTotalNumbersOfNFTs(
//            ofOwner: K.Wallet.temporaryAddress, /// Use temporary wallet address for demo purpose
            ofOwner: MoonoMockUserData().getOneUserData().address,
            ownedNFTs: Int64(numberOfItems)
        )
        
        return numberOfItems
    }
    
    func itemAtIndex(_ index: Int) -> NftCardCellViewModel? {
        guard let viewModel: NftCardCellViewModel = self.nftCardCellViewModel.value?[index] else { return nil }
        return viewModel
    }
    
    
    func getNftCardCellViewModels(of wallet: String, completion: @escaping (Result<[NftCardCellViewModel], Error>) ->()) {
        
        _ = KlaytnNftRequester.requestToGetMoonoNfts(walletAddress: wallet,
                                                     nftsHandler: {
            let viewModels = $0.map { nft in

                let viewModel: NftCardCellViewModel = NftCardCellViewModel(accDesc: nft.traits.accessories,
                                                                           backgroundDesc: nft.traits.background,
                                                                           bodyDesc: nft.traits.body,
                                                                           dayDesc: nft.traits.day,
                                                                           effectDesc: nft.traits.accessories,
                                                                           expressionDesc: nft.traits.expression,
                                                                           hairDesc: nft.traits.hair,
                                                                           name: nft.name,
                                                                           updatedAt: nft.updateAt,
                                                                           imageUrl: nft.imageUrl)
                return viewModel
            }
            completion(.success(viewModels))
            return
        })
        
        completion(.failure(NFTCardError.cardFetchError))
    }
    
    
}

extension NFTCardViewModel {
    
    enum NFTCardError: Error {
        case cardFetchError
        case urlError
    }
}
