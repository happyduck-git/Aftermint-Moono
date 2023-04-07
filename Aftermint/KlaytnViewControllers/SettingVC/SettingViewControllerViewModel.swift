//
//  SettingViewControllerViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/03.
//

import Foundation

final class SettingViewControllerViewModel {
    
    enum SettingVMError: Error {
        case FetchUserError
        case FetchCardError
        case FetchCollectionError
    }
    
    let fireStoreRepository = FirestoreRepository.shared
    
    /* Cell ViewModels */
    var youCellViewModel: YouCellViewModel
    var usersCellViewModel: UsersCellViewModel
    var nftsCellViewModel: DashBoardNftCellViewModel
    var projectsCellViewModel: ProjectsCellViewModel
    
    var addressList: Box<[Address]> = Box([]) {
        didSet {
            self.youCellViewModel.addressList = self.addressList
        }
    }
    
    let mockUser = MoonoMockUserData().getOneUserData()
    var currentUserData: Box<Address?> {
        let filteredUsers = self.addressList.value?.filter { address in
            address.ownerAddress == self.mockUser.address
        }
        let currentUser = filteredUsers?.first
        let result: Box<Address?> = Box(nil)
        result.value = currentUser
        return result
    }

    init(
        youCellVM: YouCellViewModel,
        usersCellVM: UsersCellViewModel,
        nftsCellVM: DashBoardNftCellViewModel,
        projectCellVM: ProjectsCellViewModel
    ) {
        self.youCellViewModel = youCellVM
        self.usersCellViewModel = usersCellVM
        self.nftsCellViewModel = nftsCellVM
        self.projectsCellViewModel = projectCellVM
    }
    
    /// Cell type used in SettingVC collectionView
    enum CellType: CaseIterable {
        case you
        case users
        case nfts
        case projects
    }
    
    let cells: [CellType] = CellType.allCases
    
    /// Number of items in section
    func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return cells.count
        } else {
            return 0
        }
    }
    
    func getAllUserData(completion: @escaping (Result<[Address], Error>) -> Void) {
        self.fireStoreRepository.getAllAddress { addressList in
            guard let addressList = addressList else { return }
            completion(.success(addressList))
            return
        }
        completion(.failure(SettingVMError.FetchUserError))
        return
    }
    
    func getNftData(ofCollection collectionType: CollectionType, completion: @escaping (Result<NftCollectionTest,Error>) -> Void) {
        self.fireStoreRepository.getNftCollection(ofType: collectionType) { collection in
            guard let collection = collection else { return }
            completion(.success(collection))
            return
        }
        completion(.failure(SettingVMError.FetchCollectionError))
        return
    }
    
    func getAllNftData(ofCollection collectionType: CollectionType, completion: @escaping (Result<[CardTest], Error>) -> Void) {
        self.fireStoreRepository.getAllNftData(ofCollectionType: collectionType) { cardList in
            guard let cardList = cardList else { return }
            completion(.success(cardList))
            return
        }
        completion(.failure(SettingVMError.FetchCardError))
        return
    }
    
    func getAllNftDocument(completion: @escaping (Result<[CardTest], Error>) -> Void) {
        self.fireStoreRepository.getAllNftData { cardList in
            guard let cardList = cardList else { return }
            completion(.success(cardList))
            return
        }
        completion(.failure(SettingVMError.FetchCardError))
        return
    }
    
}
