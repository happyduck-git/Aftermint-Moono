//
//  LeaderBoardTableViewCellViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit.UIImage
import DifferenceKit

protocol LeaderBoardSecondSectionCellListViewModelDelegate: AnyObject {
    func currentUserDataFetched(_ vm: LeaderBoardSecondSectionCellViewModel)
    func differentFunction()
}

final class LeaderBoardSecondSectionCellListViewModel {
    
    weak var delegate: LeaderBoardSecondSectionCellListViewModelDelegate?
    
    let mockUser = MoonoMockUserData().getOneUserData()
    
    private let fireStoreRepository = FirestoreRepository.shared
    let leaderBoardVMList: Box<[LeaderBoardSecondSectionCellViewModel]> = Box([])
    
    // MARK: - Init
    init() {}
    
    // MARK: - Public
    func numberOfRowsInSection() -> Int {
        return self.leaderBoardVMList.value?.count ?? 0
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardSecondSectionCellViewModel? {
        return self.leaderBoardVMList.value?[indexPath.row]
    }
    
    /// Get initial address section view model.
    func getInitialAddressSectionVM(of collectionType: CollectionType, gameType: GameType) async throws -> [LeaderBoardSecondSectionCellViewModel]? {
        
        let addressList = try await self.fireStoreRepository
            .getAllInitialAddress(
                gameType: .popgame,
                currentUserAddress: mockUser.address
            )
        
        guard let addressList = addressList,
              let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue)
        else {
            return nil
        }
        let initialRank = 1
        
        let viewModels = addressList.map { address in
            let viewModel = LeaderBoardSecondSectionCellViewModel(
                ownerAddress: address.ownerAddress,
                rankImage: rankImage,
                rank: initialRank,
                userProfileImage: address.profileImageUrl,
                topLabelText: address.ownerAddress,
                bottomLabelText: "\(address.ownedNFTs)",
                actionCount: address.actionCount,
                popScore: address.popScore
            )
            
            if address.ownerAddress == mockUser.address {
                self.delegate?.currentUserDataFetched(viewModel)
            }
      
            return viewModel
        }
       
        self.leaderBoardVMList.value = viewModels
        
        return viewModels
    }
    
    /// For using DifferenceKit
    func getCachedAddressSectionVM(
        of collectionType: CollectionType,
        gameType: GameType
    ) async throws -> [LeaderBoardSecondSectionCellViewModel]? {
        
        let addressList = try await self.fireStoreRepository
            .getAllCachedAddress(gameType: .popgame)
        
        guard let addressList = addressList,
              let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue)
        else {
            return nil
        }
        let initialRank = 1
        
        let viewModels = addressList.map { address in
            let viewModel = LeaderBoardSecondSectionCellViewModel(
                ownerAddress: address.ownerAddress,
                rankImage: rankImage,
                rank: initialRank,
                userProfileImage: address.profileImageUrl,
                topLabelText: address.ownerAddress,
                bottomLabelText: "\(address.ownedNFTs)",
                actionCount: address.actionCount,
                popScore: address.popScore
            )
            return viewModel
        }
       
        self.leaderBoardVMList.value = viewModels
        
        return viewModels
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
    
}

//MARK: - LeaderBoardTableViewCellViewModel
final class LeaderBoardSecondSectionCellViewModel {
    let ownerAddress: String
    var rankImage: UIImage
    var rank: Int
    let userProfileImage: String
    let topLabelText: String
    let numberOfNfts: String
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
        self.topLabelText = topLabelText // TODO: username 으로 변경
        self.numberOfNfts = bottomLabelText
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

extension LeaderBoardSecondSectionCellViewModel: Differentiable {
    
    var differenceIdentifier: String {
        return self.ownerAddress
    }
    
    func isContentEqual(to source: LeaderBoardSecondSectionCellViewModel) -> Bool {
        return self.actionCount == source.actionCount
    }
    
}

extension LeaderBoardSecondSectionCellViewModel: Equatable {
    static func == (lhs: LeaderBoardSecondSectionCellViewModel, rhs: LeaderBoardSecondSectionCellViewModel) -> Bool {
        if (lhs.ownerAddress == rhs.ownerAddress) && (lhs.actionCount == rhs.actionCount) {
            return true
        } else {
            return false
        }
    }
}
