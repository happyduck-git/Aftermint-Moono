//
//  LeaderBoardTableViewCellViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit.UIImage
import DifferenceKit

protocol LeaderBoardSecondSectionCellListViewModelDelegate: AnyObject {
    func dataFetched2()
}

final class LeaderBoardSecondSectionCellListViewModel {
    
    weak var delegate: LeaderBoardSecondSectionCellListViewModelDelegate?
    
    private let fireStoreRepository = FirestoreRepository.shared
    var leaderBoardVMList: Box<[LeaderBoardSecondSectionCellViewModel]> = Box([])
    var touchCount: Box<Int> = Box(0)

    var changedIndicies: Box<[UInt]> = Box([])
    
    // MARK: - Init
    init() {
        self.fireStoreRepository.delegate = self
    }
    
    // MARK: - Public
    func numberOfRowsInSection() -> Int {
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
    
    func getAddressSectionVM() {
        let oldVms: [LeaderBoardSecondSectionCellViewModel]? = self.leaderBoardVMList.value
        
        self.fireStoreRepository.getAllAddress { addressList in
            guard let addressList = addressList else {
                return
            }
            guard let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue) else { return }
            let initialRank = 1
            
            let viewModels = addressList.map { address in
                let viewModel = LeaderBoardSecondSectionCellViewModel(
                    ownerAddress: address.ownerAddress,
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
            self.leaderBoardVMList.value = viewModels
            self.delegate?.dataFetched2()
        }
    }
    
    //TODO: Need to add error handler
    func getAllNftRankCellViewModels(completion: @escaping (Result<[LeaderBoardSecondSectionCellViewModel], Error>) -> ()) {
        
        let userList: [AfterMintUser] = MoonoMockUserData().getAllUserData()
        guard let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue) else { return }
        let initialRank = 1
        
        let viewModels = userList.map { user in
            let viewModel: LeaderBoardSecondSectionCellViewModel =
            LeaderBoardSecondSectionCellViewModel(
                ownerAddress: user.address,
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
            nftImageUrl: nftImageUrl,
            nftTokenId: nftTokenId,
            ownerAddress: ownerAddress,
            collectionType: collectionType
        )
    }
    
}

extension LeaderBoardSecondSectionCellListViewModel: FirestoreRepositoryDelegate {
    
    func dataChangedIndex(indices: [UInt]) {
        self.changedIndicies.value = indices
//        print("Changed indices: \(indices)")
    }
    
}

//MARK: - LeaderBoardTableViewCellViewModel
final class LeaderBoardSecondSectionCellViewModel {
    let ownerAddress: String
    var rankImage: UIImage
    var rank: Int
    let userProfileImage: String
    let topLabelText: String
    let bottomLabelText: String
    let actionCount: Int64
    let popScore: Int64
    
    //MARK: - Initializer
    init(ownerAddress: String,
         rankImage: UIImage,
         rank: Int,
         userProfileImage: String,
         topLabelText: String,
         bottomLabelText: String,
         actionCount: Int64,
         popScore: Int64
    ) {
        self.ownerAddress = ownerAddress
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

