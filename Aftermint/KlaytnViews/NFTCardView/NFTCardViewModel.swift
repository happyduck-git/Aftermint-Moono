//
//  NFTCardViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/02/25.
//

import UIKit.UIImage

class NFTCardViewModel {
    
    var nftCardCellViewModel: Box<[NftCardCellViewModel]> = Box([])
    var nftSelected: [Bool] = []
    
    func numberOfItemsInSection() -> Int {
        guard let numberOfItems = self.nftCardCellViewModel.value?.count else {
            return 0
        }
        self.nftSelected = Array(repeating: false, count: numberOfItems)
        print("numberofNfts: \(numberOfItems)")
        return numberOfItems
    }
    
    func itemAtIndex(_ index: Int) -> NftCardCellViewModel? {
        guard let viewModel: NftCardCellViewModel = self.nftCardCellViewModel.value?[index] else { return nil }
        return viewModel
    }
    
    
    func getNftCardCellViewModels(of wallet: String,
                                  completion: @escaping (Result<[NftCardCellViewModel], Error>) ->()) {
        
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
    
    //Demo:
    func getNftCardCellViewModelsDemo(of wallet: String,
                                      ofType: NftDataStorage,
                                      completion: @escaping (Result<[NftCardCellViewModel], Error>) -> ()) {
        
        _ = KlaytnNftRequester.requestToGetMoonoNftsDemo(storageType: ofType,
                                                         walletAddress: wallet,
                                                         completion: {
            
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
