//
//  SettingViewControllerViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/03.
//

import UIKit.UIImage
import FirebaseFirestore

final class SettingViewControllerViewModel {
    
    // MARK: - Custom Error
    enum SettingVMError: Error {
        case FetchUserError
        case FetchCardError
        case FetchCollectionError
    }
    
    let fireStoreRepository = FirestoreRepository.shared
    let mockUser = MoonoMockUserData().getOneUserData()
    
    var lastDoc: QueryDocumentSnapshot?
    
    // MARK: - Cell ViewModels
    var youCellViewModel: YouCellViewModel
    var usersCellViewModel: UsersCellViewModel
    var nftsCellViewModel: DashBoardNftCellViewModel
    var projectsCellViewModel: ProjectsCellViewModel
    
    /// Cell type used in SettingVC collectionView
    enum CellType: CaseIterable {
        case you
        case users
        case nfts
        case projects
    }
    
    let cells: [CellType] = CellType.allCases
    
    // MARK: - Init
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

    // MARK: - Internal functions
    
    /// Number of items in section
    func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return cells.count
        } else {
            return 0
        }
    }

    func getAllAddressFields(gameType: GameType) {
        
        Task {
            let addressList = try await self.fireStoreRepository
                .getAllInitialAddress(
                    gameType: gameType,
                    currentUserAddress: mockUser.address
                )
            guard let addressList = addressList else { return }
            let vmList = addressList.map { address in
                /// Check if address is the same as current (mock) user's
                if address.ownerAddress == self.mockUser.address {
                    self.youCellViewModel.currentUser.value = address
                }
          
                return PopScoreRankCellViewModel(
                    rankImage: UIImage(contentsOfFile: LeaderBoardAsset.firstPlace.rawValue),
                    rank: 0,
                    profileImageUrl: address.profileImageUrl,
                    owerAddress: address.ownerAddress,
                    totalNfts: address.ownedNFTs,
                    popScore: address.popScore,
                    actioncount: address.actionCount
                )
            }
            self.usersCellViewModel.usersList.value = vmList
            self.usersCellViewModel.isLoaded.value = true
        }
        
    }
    
    func getNftData(gameType: GameType) {

        Task {
            let collection = try await self.fireStoreRepository.getCurrentNftCollection(gameType: gameType)
            self.usersCellViewModel.currentNft.value = collection
        }
        
    }
    
    func getAllCards() {
        
        Task {
         
            let results = try await self.fireStoreRepository
                .getPaginatedCards(
                    gameType: .popgame
                )

            var currentUserCardList: [NftRankCellViewModel] = []
            guard let cards = results.cards,
            let lastDoc = results.lastDoc
            else {
                return
            }
            
            self.lastDoc = lastDoc // Might not be needed.
            self.nftsCellViewModel.lastDoc = lastDoc
            
            let vmList = cards.map { card in
                
                let vm = NftRankCellViewModel(
                    rank: 0,
                    rankImage: UIImage(contentsOfFile: LeaderBoardAsset.firstPlace.rawValue),
                    nftImageUrl: card.imageUrl,
                    nftName: "Moono #\(card.tokenId)",
                    score: card.popScore,
                    ownerAddress: card.ownerAddress
                )
                
                if card.ownerAddress == self.mockUser.address {
                    currentUserCardList.append(vm)
                }
                
                return vm
            }
//            self.youCellViewModel.nftRankViewModels.value = currentUserCardList
//            self.youCellViewModel.isLoaded.value = true
            self.nftsCellViewModel.nftsList.value = vmList
        }
        
    }
    
    func getAdditionalCards() {
        
        nftsCellViewModel.isLoadingMorePosts = true
        
        Task {
            do {
                let results = try await self.fireStoreRepository
                    .getAdditionalCards(
                        after: nftsCellViewModel.lastDoc,
                        gameType: .popgame
                    )
                
                var currentUserCardList: [NftRankCellViewModel] = []
                guard let cards = results.cards,
                let lastDoc = results.lastDoc
                else {
                    return
                }
                
                self.lastDoc = lastDoc // Might not be needed.
                self.nftsCellViewModel.lastDoc = lastDoc
                
                let vmList = cards.map { card in
                    
                    let vm = NftRankCellViewModel(
                        rank: 0,
                        rankImage: UIImage(contentsOfFile: LeaderBoardAsset.firstPlace.rawValue),
                        nftImageUrl: card.imageUrl,
                        nftName: "Moono #\(card.tokenId)",
                        score: card.popScore,
                        ownerAddress: card.ownerAddress
                    )
                    
                    if card.ownerAddress == self.mockUser.address {
                        currentUserCardList.append(vm)
                    }
                    
                    return vm
                }
                self.youCellViewModel.nftRankViewModels.value?.append(contentsOf: currentUserCardList)
                self.youCellViewModel.isLoaded.value = true
                
                self.nftsCellViewModel.nftsList.value?.append(contentsOf: vmList)
                nftsCellViewModel.isLoadingMorePosts = false
            }
            catch (let error) {
                print("Error getting additional cards - \(error.localizedDescription)")
            }
        }
        
    }
    
    func getAllCollectionFields() {
        
        Task {
            let results = try await self.fireStoreRepository
                .getAllCollections(gameType: .popgame)
            guard let nftCollectionList = results else { return }
            let vmList = nftCollectionList.map { collection in
                return ProjectPopScoreCellViewModel(
                    rank: 0,
                    nftImageUrl: collection.imageUrl,
                    nftCollectionName: collection.name,
                    totalNfts: collection.totalNfts,
                    totalHolders: collection.totalHolders,
                    popScore: collection.totalPopCount,
                    actioncount: collection.totalActionCount
                )
            }
            self.projectsCellViewModel.nftCollectionList.value = vmList
        }
 
    }
    
}

