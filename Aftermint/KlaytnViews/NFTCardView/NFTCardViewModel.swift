//
//  NFTCardViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/02/25.
//

import Foundation

class NFTCardViewModel {
    
    var nftCardCellViewModel: Box<[NftCardCellViewModel]> = Box([])
    var isLoaded: Box<Bool> = Box(false)
    var nftSelected: [Bool] = []
    let fireStoreRepository = FirestoreRepository.shared
    
    func numberOfItemsInSection() -> Int {
        guard let numberOfItems = self.nftCardCellViewModel.value?.count else {
            return 0
        }
        self.nftSelected = Array(repeating: false, count: numberOfItems)
    
        /// Save total number of nfts an owner has
        let mockUser = MoonoMockUserData().getOneUserData()
        
        /// TEMP: Only for demo purpose
        self.fireStoreRepository.saveAddressBaseFields(
            ownerAddress: mockUser.address,
            username: mockUser.username
        ) { [weak self] _ in
            self?.fireStoreRepository.saveTotalNumbersOfNFTs(
    //            ofOwner: K.Wallet.temporaryAddress, /// Use temporary wallet address for demo purpose
                ofOwner: mockUser.address,
                ownedNFTs: Int64(numberOfItems)
            )
        }

        return numberOfItems
    }
    
    func itemAtIndex(_ index: Int) -> NftCardCellViewModel? {
        guard let viewModel: NftCardCellViewModel = self.nftCardCellViewModel.value?[index] else { return nil }
        return viewModel
    }
    
    func getNftCardCellViewModels(of wallet: String) {
        
        _ = KlaytnNftRequester.requestToGetMoonoNfts(walletAddress: wallet,
                                                     nftsHandler: { [weak self] in
            guard let `self` = self else { return }
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
            self.nftCardCellViewModel.value = viewModels
            self.isLoaded.value = true
        })
        
    }
    
}

extension NFTCardViewModel {
    
    enum NFTCardError: Error {
        case cardFetchError
        case urlError
    }
}
