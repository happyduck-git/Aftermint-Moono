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
    var leaderBoardFirstSectionVMList: Box<[LeaderBoardFirstSectionCellViewModel]> = Box([]) {
        didSet {
            guard let vmList = self.leaderBoardFirstSectionVMList.value else { return }
            self.typeErasedVMList = vmList.map {
                AnyDifferentiable($0)
            }
        }
    }
    var typeErasedVMList: [AnyDifferentiable] = []
    var firstSection: ArraySection<SectionID, AnyDifferentiable> = ArraySection(model: .first, elements: [])
    
    //MARK: - Internal
    func numberOfRowsInSection() -> Int {
        return self.leaderBoardFirstSectionVMList.value?.count ?? 0
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardFirstSectionCellViewModel? {
        return self.leaderBoardFirstSectionVMList.value?[indexPath.row]
    }
    
    func getFirstSectionVM(ofCollection collectionType: CollectionType) {
        self.fireStoreRepository.getNftCollection(ofType: collectionType) { collection in
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
                    self.firstSection.elements.removeFirst()
                }
                self.leaderBoardFirstSectionVMList.value?.append(viewModel)
                self.firstSection.elements.append(AnyDifferentiable(viewModel))
                
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
