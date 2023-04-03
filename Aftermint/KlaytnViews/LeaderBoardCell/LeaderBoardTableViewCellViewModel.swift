//
//  LeaderBoardTableViewCellViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit.UIImage



final class LeaderBoardTableViewCellListViewModel {
    
    var firstSectionVMList: Box<[LeaderBoardTableViewCellViewModel]> = Box([])
    var secondSectionVMList: Box<[LeaderBoardTableViewCellViewModel]> = Box([])
    var touchCount: Box<Int> = Box(0)
    
    let fireStoreRepository = FirestoreRepository.shared
    
    func numberOfSections() -> Int {
        return 2
    }
    
    func numberOfRowsInSection(at section: Int) -> Int {
        if section == 0 {
            return self.firstSectionVMList.value?.count ?? 0
        }
        return self.secondSectionVMList.value?.count ?? 0
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardTableViewCellViewModel? {
        var viewModel: LeaderBoardTableViewCellViewModel?
        if indexPath.section == 0 {
            viewModel = self.firstSectionVMList.value?[indexPath.row]
        } else {
            viewModel = self.secondSectionVMList.value?[indexPath.row]
        }
        return viewModel
    }
    
    func currentUserViewModel() -> LeaderBoardTableViewCellViewModel? {
        let currentUserViewModel = self.secondSectionVMList.value?.filter({ viewModel in
            //TODO: Change mock user address to currently logged in user
            let mockUser = MoonoMockUserData().getOneUserData()
            return viewModel.topLabelText == mockUser.address.cutOfRange(length: 10)
        })
        return currentUserViewModel?.first
    }
    
    /// Build ViewModels for first section
    func getFirstSectionViewModel(completion: @escaping (Result<LeaderBoardTableViewCellViewModel, Error>) -> ()) {
        self.fireStoreRepository.getNftCollection { collection in
            guard let collection = collection else {
                completion(.failure(LeaderBoardTableViewCellListError.collectionFetchError))
                return
            }
            guard let rankImage = UIImage(named: LeaderBoard.firstPlace.rawValue) else { return }
            let initialRank = 1
            
            let viewModel = LeaderBoardTableViewCellViewModel(rankImage: rankImage,
                                                              rank: initialRank,
                                                              userProfileImage: "game_moono_mock", //TODO: change to `collection.imageUrl`
                                                              topLabelText: collection.name,
                                                              bottomLabelText: "Ation count \(collection.totalActionCount)",
                                                              actionCount: collection.totalActionCount,
                                                              popScore: collection.totalPopCount)
            completion(.success(viewModel))
            return
        }
        
    }
    
    /// Build ViewModels for second section
    func getAddressSectionViewModel(completion: @escaping (Result<[LeaderBoardTableViewCellViewModel], Error>) -> ()) {
        self.fireStoreRepository.getAllAddress2 { addressList in
            guard let addressList = addressList else {
                completion(.failure(LeaderBoardTableViewCellListError.addressFetchError))
                return
            }
            guard let rankImage = UIImage(named: LeaderBoard.firstPlace.rawValue) else { return }
            let initialRank = 1
            
            let viewModels = addressList.map { address in
                let viewModel = LeaderBoardTableViewCellViewModel(rankImage: rankImage,
                                                                  rank: initialRank,
                                                                  userProfileImage: address.profileImageUrl,
                                                                  topLabelText: address.ownerAddress.cutOfRange(length: 10),
                                                                  bottomLabelText: "Nfts 17", //Total nft 개수는 어디에서 가져올 것인지?
                                                                  actionCount: address.actionCount,
                                                                  popScore: address.popScore)
                return viewModel
            }
            completion(.success(viewModels))
            return
        }
        completion(.failure(LeaderBoardTableViewCellListError.addressFetchError))
    }
    
    //TODO: Need to add error handler
    func getAllNftRankCellViewModels(completion: @escaping (Result<[LeaderBoardTableViewCellViewModel], Error>) -> ()) {
        
        let userList: [AfterMintUserTest] = MoonoMockUserData().getAllUserData()
        guard let rankImage = UIImage(named: LeaderBoard.firstPlace.rawValue) else { return }
        let initialRank = 1
        
        let viewModels = userList.map { user in
            let viewModel: LeaderBoardTableViewCellViewModel =
            LeaderBoardTableViewCellViewModel(rankImage: rankImage,
                                              rank: initialRank,
                                              userProfileImage: user.imageUrl,
                                              topLabelText: user.address,
                                              bottomLabelText: "NFTs \(user.totalNfts)",
                                              actionCount: user.actionCount,
                                              popScore: user.popCount)
            return viewModel
        }
        completion(.success(viewModels))
        return
    }
    
    func saveCountNumber(collectionAddress: String,
                         collectionImageUrl: String,
                         popScore: Int64,
                         actionCount: Int64,
                         ownerAddress: String,
                         ownerProfileImage: String,
                         nftImageUrl: String,
                         nftTokenId: String,
                         totalNfts: Int,
                         ofCollectionType collectionType: CollectionType) {
        
        fireStoreRepository.save(actionCount: actionCount,
                                 popScore: popScore,
                                 collectionImageUrl: collectionImageUrl,
                                 nftImageUrl: nftImageUrl,
                                 nftTokenId: nftTokenId,
                                 ownerAddress: ownerAddress,
                                 ownerProfileImage: ownerProfileImage,
                                 collectionType: collectionType)
     
    }
    
    
    ///TEMP: Using mock data
//    let randomMoonoData: Card = MoonoMockMetaData().getOneMockData()
    
    /// Save increase touch count of a certain card to Firestore
    
    
//    func increaseTouchCount(_ number: Int64) {
//        saveCountNumberOfCard(imageUri: randomMoonoData.imageUri,
//                              collectionId: randomMoonoData.collectionId,
//                              tokenId: randomMoonoData.tokenId,
//                              count: number)
//    }
    
}

// MARK: - Custom Error type
extension LeaderBoardTableViewCellListViewModel {
    
    enum LeaderBoardTableViewCellListError: Error {
        case addressFetchError
        case nftFetchError
        case collectionFetchError
    }
    
}

//MARK: - LeaderBoardTableViewCellViewModel
final class LeaderBoardTableViewCellViewModel {
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

