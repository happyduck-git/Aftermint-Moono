//
//  SettingViewControllerViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/03.
//

import UIKit.UIImage

final class SettingViewControllerViewModel {
    
    // MARK: - Custom Error
    enum SettingVMError: Error {
        case FetchUserError
        case FetchCardError
        case FetchCollectionError
    }
    
    let fireStoreRepository = FirestoreRepository.shared
    let mockUser = MoonoMockUserData().getOneUserData()
    
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

    func getAllAddressFields() {
        
        self.fireStoreRepository.getAllAddress(
            collectionType: .moono,
            gameType: .popgame
        ) { addressList in
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
        }
    }
    
    func getNftData(ofCollectionType collectionType: CollectionType) {
        self.fireStoreRepository.getNftCollection(ofType: collectionType) { collection in
            guard let collection = collection else { return }
            self.usersCellViewModel.currentNft.value = collection
        }
    }
    
    func getAllCards(ofCollectionType collectionType: CollectionType) {
        
        Task {
         
            let results = try await self.fireStoreRepository.getAllCards(
                ofCollectionType: collectionType,
                gameType: .popgame
            )

            guard let cards = results else { return }
            var currentUserCardList: [NftRankCellViewModel] = []
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
            self.youCellViewModel.nftRankViewModels.value = currentUserCardList
            self.nftsCellViewModel.nftsList.value = vmList
        }
        
    }
    
    func getAllCollectionFields(ofCollectionType collectionType: CollectionType) {
        
        Task {
            let results = try await self.fireStoreRepository.getAllCollectionFields(ofCollectionType: collectionType)
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
    
    func getHolderAndNumberOfNFTs() {
        Task {
            do {
                let holders = try await KlaytnNftRequester.getNumberOfHolders(ofCollection: K.ContractAddress.moono)
                projectsCellViewModel.totalNumberOfHolders.value = holders?.totalHolder
                
                let contractInfoResult = try await KlaytnNftRequester.getNumberOfIssuedNFTs(ofCollection: K.ContractAddress.moono)
                guard let totalNumberOfNFTs = contractInfoResult?.totalSupply.convertToDecimal() else { return }
                projectsCellViewModel.totalNumberOfMintedNFTs.value = totalNumberOfNFTs

                FirestoreRepository.shared.saveNumberOfHoldersAndMintedNfts(
                    collectionType: .moono,
                    totalHolders: Int64(holders?.totalHolder ?? 0),
                    totalMintedNFTs: Int64(totalNumberOfNFTs)
                )
            } catch {
                print(error.localizedDescription)
            }
         
        }
    }
    
}
