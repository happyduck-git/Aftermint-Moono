//
//  LeaderBoardFirstSectionCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/06.
//

import Foundation

enum LeaderBoardError: Error {
    case FirstSectionFetchError
    case CollectionDataNotFound
    case AddressFetchError
    case NftFetchError
    case CollectionFetchError
}

final class LeaderBoardFirstSectionCellViewModel {
    
    private let fireStoreRepository = FirestoreRepository.shared
    
    var nftImage: String
    var nftCollectionName: String
    var totalActionCount: Int64
    var totalPopScore: Int64
    
    //MARK: - Initializer
    convenience init() {
        self.init(nftImage: "",
                  nftCollectionName: "",
                  totalActionCount: 0,
                  totalPopScore: 0)
    }
    
    init(nftImage: String, nftCollectionName: String, totalActionCount: Int64, totalPopScore: Int64) {
        self.nftImage = nftImage
        self.nftCollectionName = nftCollectionName
        self.totalActionCount = totalActionCount
        self.totalPopScore = totalPopScore
    }
    
    func getFirstSectionViewModel(ofCollection collectionType: CollectionType,
                                  completion: @escaping (Result<LeaderBoardFirstSectionCellViewModel, Error>) -> ()) {
        self.fireStoreRepository.getNftCollection(ofType: collectionType) { collection in
            guard let collection = collection else {
                completion(.failure(LeaderBoardError.FirstSectionFetchError))
                return
            }
            if collection.address == K.ContractAddress.moono {
                let viewModel = LeaderBoardFirstSectionCellViewModel(nftImage: LeaderBoardAsset.moonoImage.rawValue, //실제 url로 변경된 이후에는 collection.imageUrl로 바꾸어주기
                                                                     nftCollectionName: collection.name,
                                                                     totalActionCount: collection.totalActionCount,
                                                                     totalPopScore: collection.totalPopCount)
                completion(.success(viewModel))
            } else {
                completion(.failure(LeaderBoardError.CollectionDataNotFound))
                return
            }
        }
        
    }
}
