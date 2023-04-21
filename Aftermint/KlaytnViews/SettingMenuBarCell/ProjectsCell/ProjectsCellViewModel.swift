//
//  ProjectsCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/05.
//

import Foundation

final class ProjectsCellViewModel {
    
    let nftCollectionList: Box<[ProjectPopScoreCellViewModel]> = Box([])
    let totalNumberOfHolders: Box<Int> = Box(0)
    let totalNumberOfMintedNFTs: Box<Int> = Box(0)
    
    func getCurrentNftCollection(ofType collectionType: CollectionType) -> ProjectPopScoreCellViewModel? {
        let filteredCollections = self.nftCollectionList.value?.filter({ vm in
            vm.nftCollectionName == collectionType.rawValue
        })
        return filteredCollections?.first
    }
    
}
