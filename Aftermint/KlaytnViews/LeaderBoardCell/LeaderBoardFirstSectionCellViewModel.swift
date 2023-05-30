//
//  LeaderBoardFirstSectionCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/06.
//

import Foundation
import DifferenceKit

enum LeaderBoardError: Error {
    case FirstSectionFetchError
    case CollectionDataNotFound
    case AddressFetchError
    case NftFetchError
    case CollectionFetchError
}

final class LeaderBoardFirstSectionCellListViewModel {
    private let fireStoreRepository = FirestoreRepository.shared
    var leaderBoardFirstSectionVMList: Box<[LeaderBoardFirstSectionCellViewModel]> = Box([])
    var typeErasedVMList: [AnyDifferentiable] = []
    var firstSection: ArraySection<SectionID, AnyDifferentiable> = ArraySection(model: .first, elements: [])
    
    //MARK: - Internal
    func numberOfRowsInSection() -> Int {
        return self.leaderBoardFirstSectionVMList.value?.count ?? 0
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardFirstSectionCellViewModel? {
        return self.leaderBoardFirstSectionVMList.value?[indexPath.row]
    }
    
    /// Currently NOT in use.
    func getFirstSectionVM(ofCollection collectionType: CollectionType) {
        self.fireStoreRepository.getNftCollectionFromOldScheme(ofType: collectionType) { collection in
            guard let collection = collection else {
                return
            }
            if collection.address == K.ContractAddress.moono {
                let viewModel = LeaderBoardFirstSectionCellViewModel(
                    nftImage: collection.imageUrl,
                    nftCollectionName: collection.name,
                    totalActionCount: collection.totalActionCount,
                    totalPopScore: collection.totalPopCount
                )
                
                if !(self.leaderBoardFirstSectionVMList.value?.isEmpty ?? true) {
                    self.leaderBoardFirstSectionVMList.value?.removeFirst()
                }
                self.leaderBoardFirstSectionVMList.value?.append(viewModel)
            } else {
                return
            }
        }
    }
    
    // TODO: NO3. 현재 앱에서 사용되고 있는 Collection의 점수 받아오기
    /// For using DifferenceKit
    func getFirstSectionVM(ofCollection collectionType: CollectionType, completion: @escaping ((LeaderBoardFirstSectionCellViewModel) -> Void)) {
        self.fireStoreRepository.getNftCollectionFromOldScheme(ofType: collectionType) { collection in
            guard let collection = collection else {
                return
            }
            if collection.address == K.ContractAddress.moono {
                let viewModel = LeaderBoardFirstSectionCellViewModel(
                    nftImage: collection.imageUrl,
                    nftCollectionName: collection.name,
                    totalActionCount: collection.totalActionCount,
                    totalPopScore: collection.totalPopCount
                )
                
                if !(self.leaderBoardFirstSectionVMList.value?.isEmpty ?? true) {
                    self.leaderBoardFirstSectionVMList.value?.removeFirst()
                }
                self.leaderBoardFirstSectionVMList.value?.append(viewModel)
                completion(viewModel)
            } else {
                return
            }
        }
    }
    
}

final class LeaderBoardFirstSectionCellViewModel {
    
    var nftImage: String
    var nftCollectionName: String
    var totalActionCount: Int64
    var totalPopScore: Int64
    
    init(nftImage: String, nftCollectionName: String, totalActionCount: Int64, totalPopScore: Int64) {
        self.nftImage = nftImage
        self.nftCollectionName = nftCollectionName
        self.totalActionCount = totalActionCount
        self.totalPopScore = totalPopScore
    }
}

extension LeaderBoardFirstSectionCellViewModel: Differentiable {
    var differenceIdentifier: String {
        return self.nftCollectionName
    }
    
    func isContentEqual(to source: LeaderBoardFirstSectionCellViewModel) -> Bool {
        return self.totalActionCount == source.totalActionCount
    }
}
