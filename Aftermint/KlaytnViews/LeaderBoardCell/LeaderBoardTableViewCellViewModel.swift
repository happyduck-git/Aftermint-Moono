//
//  LeaderBoardTableViewCellViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit.UIImage

final class LeaderBoardTableViewCellListViewModel {
    
    var firstSectionVMList: Box<[LeaderBoardTableViewCellViewModel]>  = Box([])
    var viewModelList: Box<[LeaderBoardTableViewCellViewModel]>  = Box([])
    var touchCount: Box<Int> = Box(0)
    private let numberOfSection: Int = 2
    
    let fireStoreRepository = FirestoreRepository.shared
    
    func numberOfSections() -> Int {
        return self.numberOfSection
    }
    
    func numberOfRowsInSection(at section: Int) -> Int {
        if section == 0 {
            return self.firstSectionVMList.value?.count ?? 0
        }
        return self.viewModelList.value?.count ?? 0
    }
    
    func modelAt(_ index: Int) -> LeaderBoardTableViewCellViewModel? {
        guard let viewModel: LeaderBoardTableViewCellViewModel = self.viewModelList.value?[index] else { return nil }
        return viewModel
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardTableViewCellViewModel? {
        var viewModel: LeaderBoardTableViewCellViewModel?
        if indexPath.section == 0 {
            viewModel = self.firstSectionVMList.value?[indexPath.row]
        } else {
            viewModel = self.viewModelList.value?[indexPath.row]
        }
        return viewModel
    }
    
    func getNftProjectScoreViewModels(completion: @escaping (Result<[LeaderBoardTableViewCellViewModel], Error>) -> ()) {
        
    }
    
    //TODO: Need to add error handler
    func getAllNftRankCellViewModels(completion: @escaping (Result<[LeaderBoardTableViewCellViewModel], Error>) -> ()) {
        
        let userList: [AftermintUser] = MoonoMockUserData().getAllUserData()
        guard let rankImage = UIImage(named: LeaderBoard.firstPlace.rawValue) else { return }
        let initialRank = 1
        
        let viewModels = userList.map { user in
            let viewModel: LeaderBoardTableViewCellViewModel = LeaderBoardTableViewCellViewModel(rankImage: rankImage,
                                                                                                 rank: initialRank,
                                                                                                 userProfileImage: user.userProfileImageUrl,
                                                                                                 topLabelText: user.walletAddress,
                                                                                                 bottomLabelText: "NFTs \(user.totalOwned)",
                                                                                                 touchScore: user.popScore)
            return viewModel
        }
        completion(.success(viewModels))
        return
    }
    
    
    ///TEMP: Using mock data
    let randomMoonoData: Card = MoonoMockMetaData().getOneMockData()
    
    /// Save increase touch count of a certain card to Firestore
    func increaseTouchCount(_ number: Int64) {
        saveCountNumberOfCard(imageUri: randomMoonoData.imageUri,
                              collectionId: randomMoonoData.collectionId,
                              tokenId: randomMoonoData.tokenId,
                              count: number)
    }
    
    func saveCountNumberOfCard(imageUri: String,
                               collectionId: String,
                               tokenId: String,
                               count: Int64)
    {
        
        let card: Card = Card(imageUri: imageUri,
                              collectionId: collectionId,
                              tokenId: tokenId,
                              count: count)
        let collection: NftCollection = NftCollection(collectionId: K.ContractAddress.moono,
                                                      collectionLogoImage: "N/A",
                                                      count: count)
        fireStoreRepository.saveCard(card)
        fireStoreRepository.saveCollection(collection)
        
    }
}

// MARK: - Custom Error type
extension LeaderBoardTableViewCellListViewModel {
    
    enum LeaderBoardTableViewCellListError: Error {
        case nftFetchError
        case collectionFetchError
    }
    
}

final class LeaderBoardTableViewCellViewModel {
    var rankImage: UIImage
    var rank: Int
    let userProfileImage: String
    let topLabelText: String
    let bottomLabelText: String
    let touchScore: Int64
    
    //MARK: - Initializer
    init(rankImage: UIImage,
         rank: Int,
         userProfileImage: String,
         topLabelText: String,
         bottomLabelText: String,
         touchScore: Int64) {
        self.rankImage = rankImage
        self.rank = rank
        self.userProfileImage = userProfileImage
        self.topLabelText = topLabelText
        self.bottomLabelText = bottomLabelText
        self.touchScore = touchScore
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

