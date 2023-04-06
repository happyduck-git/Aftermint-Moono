//
//  SettingViewControllerViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/03.
//

import Foundation

final class SettingViewControllerViewModel {
    
    enum SettingVMError: Error {
        case fetchUserError
        case fetchCardError
    }
    
    
    let fireStoreRepository = FirestoreRepository.shared
    
    /* Cell ViewModels */
    var youCellViewModel: YouCellViewModel
    var usersCellViewModel: UsersCellViewModel
    
    var addressList: Box<[AddressTest]> = Box([]) {
        didSet {
            self.youCellViewModel.addressList = self.addressList
        }
    }
    
    let mockUser = MoonoMockUserData().getOneUserData()
    var currentUserData: Box<AddressTest?> {
        let filteredUsers = self.addressList.value?.filter { address in
            address.ownerAddress == self.mockUser.address
        }
        let currentUser = filteredUsers?.first
        let result: Box<AddressTest?> = Box(nil)
        result.value = currentUser
        return result
    }

    init(
        youCellVM: YouCellViewModel,
        usersCellVM: UsersCellViewModel
    ) {
        self.youCellViewModel = youCellVM
        self.usersCellViewModel = usersCellVM
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
    
    func getAllUserData(completion: @escaping (Result<[AddressTest], Error>) -> Void) {
        self.fireStoreRepository.getAllAddress { addressList in
            guard let addressList = addressList else { return }
            completion(.success(addressList))
            return
        }
        completion(.failure(SettingVMError.fetchUserError))
        return
    }
    
    func getAllNftsData(ofCollection collectionType: CollectionType, completion: @escaping (Result<[CardTest],Error>) -> Void) {
        self.fireStoreRepository.getAllOwnedCardData(ofCollectionType: collectionType) { cardList in
            guard let cardList = cardList else { return }
            completion(.success(cardList))
            return
        }
        completion(.failure(SettingVMError.fetchCardError))
    }
    
}
