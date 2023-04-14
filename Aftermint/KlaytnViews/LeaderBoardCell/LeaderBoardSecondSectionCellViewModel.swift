//
//  LeaderBoardTableViewCellViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit.UIImage

final class LeaderBoardSecondSectionCellListViewModel {
    
    private let fireStoreRepository = FirestoreRepository.shared
    var leaderBoardVMList: Box<[LeaderBoardSecondSectionCellViewModel]> = Box([])
    var touchCount: Box<Int> = Box(0)

    func numberOfRowsInSection(at section: Int) -> Int {
        return self.leaderBoardVMList.value?.count ?? 0
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardSecondSectionCellViewModel? {
        return self.leaderBoardVMList.value?[indexPath.row]
    }
    
    func currentUserViewModel() -> LeaderBoardSecondSectionCellViewModel? {
        let currentUserViewModel = self.leaderBoardVMList.value?.filter({ viewModel in
            //TODO: Change mock user address to currently logged in user
            let mockUser = MoonoMockUserData().getOneUserData()
            return viewModel.topLabelText == mockUser.address
        })
        return currentUserViewModel?.first
    }
 
    /// Build ViewModels for second section
    func getAddressSectionViewModel(completion: @escaping (Result<[LeaderBoardSecondSectionCellViewModel], Error>) -> ()) {
        self.fireStoreRepository.getAllAddress { addressList in
            guard let addressList = addressList else {
                completion(.failure(LeaderBoardError.AddressFetchError))
                return
            }
            guard let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue) else { return }
            let initialRank = 1
            
            let viewModels = addressList.map { address in
                let viewModel = LeaderBoardSecondSectionCellViewModel(
                    rankImage: rankImage,
                    rank: initialRank,
                    userProfileImage: address.profileImageUrl,
                    topLabelText: address.ownerAddress,
                    bottomLabelText: "NFTs \(address.ownedNFTs)",
                    actionCount: address.actionCount,
                    popScore: address.popScore
                )
                return viewModel
            }
            completion(.success(viewModels))
            return
        }
        completion(.failure(LeaderBoardError.AddressFetchError))
    }
    
    //TODO: Need to add error handler
    func getAllNftRankCellViewModels(completion: @escaping (Result<[LeaderBoardSecondSectionCellViewModel], Error>) -> ()) {
        
        let userList: [AfterMintUser] = MoonoMockUserData().getAllUserData()
        guard let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue) else { return }
        let initialRank = 1
        
        let viewModels = userList.map { user in
            let viewModel: LeaderBoardSecondSectionCellViewModel =
            LeaderBoardSecondSectionCellViewModel(
                rankImage: rankImage,
                rank: initialRank,
                userProfileImage: user.imageUrl,
                topLabelText: user.username,
                bottomLabelText: "NFTs \(user.totalNfts)",
                actionCount: user.actionCount,
                popScore: user.popCount
            )
            return viewModel
        }
        completion(.success(viewModels))
        return
    }
    
    func saveCountNumber(
        collectionImageUrl: String,
        popScore: Int64,
        actionCount: Int64,
        ownerAddress: String,
        nftImageUrl: String,
        nftTokenId: String,
        totalNfts: Int,
        ofCollectionType collectionType: CollectionType
    ) {
        
        fireStoreRepository.save(
            actionCount: actionCount,
            popScore: popScore,
            collectionImageUrl: collectionImageUrl,
            nftImageUrl: nftImageUrl,
            nftTokenId: nftTokenId,
            ownerAddress: ownerAddress,
            collectionType: collectionType
        )
    }
    
}

//MARK: - LeaderBoardTableViewCellViewModel
final class LeaderBoardSecondSectionCellViewModel {
    var rankImage: UIImage
    var rank: Int
    let userProfileImage: String
    let topLabelText: String
    let bottomLabelText: String
    let actionCount: Int64
    let popScore: Int64
    
    //MARK: - Initializer
    init(rankImage: UIImage,
         rank: Int,
         userProfileImage: String,
         topLabelText: String,
         bottomLabelText: String,
         actionCount: Int64,
         popScore: Int64
    ) {
        self.rankImage = rankImage
        self.rank = rank
        self.userProfileImage = userProfileImage
        self.topLabelText = topLabelText
        self.bottomLabelText = bottomLabelText
        self.actionCount = actionCount
        self.popScore = popScore
    }
    
    //MARK: - Internal function
    func setRankImage(with image: UIImage?) {
        guard let image = image else { return }
        self.rankImage = image
    }
    
    func setRankNumberWithIndexPath(_ indexPathRow: Int) {
        self.rank = indexPathRow
    }
    
}

