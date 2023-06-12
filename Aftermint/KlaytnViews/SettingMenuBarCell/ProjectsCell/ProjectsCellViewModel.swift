//
//  ProjectsCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/05.
//

import Foundation

final class ProjectsCellViewModel {
    
    let nftCollectionList: Box<[ProjectPopScoreCellViewModel]> = Box([])
    let currentNftCollection: Box<ProjectPopScoreCellViewModel?> = Box(nil)
    
    func numberOfRowsAt() -> Int {
        return nftCollectionList.value?.count ?? 0
    }

    func viewModelAt(_ indexPath: IndexPath) -> ProjectPopScoreCellViewModel? {
        return nftCollectionList.value?[indexPath.row]
    }
    
    func getCurrentNftCollection(ofType collectionType: CollectionType) {
        let filteredCollections = self.nftCollectionList.value?.filter({ vm in
            vm.nftCollectionName == collectionType.displayName
        })
        currentNftCollection.value = filteredCollections?.first
    }
    
}
