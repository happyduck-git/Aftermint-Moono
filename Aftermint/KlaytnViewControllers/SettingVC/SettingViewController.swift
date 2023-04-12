//
//  SettingsViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/20.
//

import UIKit

final class SettingViewController: UIViewController {
    
    let mockUser = MoonoMockUserData().getOneUserData()
    var vm: SettingViewControllerViewModel
    
    private let gameLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: SettingAsset.gameLogo.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dashBoardStackView: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelFont = BellyGomFont.header04
        stack.topLabelText = SettingAsset.dashBoardTitle.rawValue
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let menuBar: SettingMenuBar = {
        let menuBar = SettingMenuBar()
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        return menuBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(YouCell.self, forCellWithReuseIdentifier: YouCell.identifier)
        collection.register(UsersCell.self, forCellWithReuseIdentifier: UsersCell.identifier)
        collection.register(DashBoardNftCell.self, forCellWithReuseIdentifier: DashBoardNftCell.identifier)
        collection.register(ProjectsCell.self, forCellWithReuseIdentifier: ProjectsCell.identifier)
        
        collection.backgroundColor = AftermintColor.backgroundNavy
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
      
        return collection
    }()
    
    //MARK: - Initializer
    init(
        ofCollectionType collectionType: CollectionType,
        vm: SettingViewControllerViewModel
    ) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        dashBoardStackView.bottomLabelText = collectionType.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setDelegate()
        
        getHolderAndNumberOfNFTs()
        getAllUserData()
        getNftData()
        getAllNftData()
        getAllNftDocument(ofCollectionType: .moono)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.collectionView.frame.height)
        }
    }
    
    //MARK: - Set UI & Layout
    private func setUI() {
        view.backgroundColor = .black
        
        view.addSubview(gameLogoImageView)
        view.addSubview(dashBoardStackView)
        view.addSubview(menuBar)
        view.addSubview(collectionView)
    }
    
    private func setLayout() {
        let tabBarHeight = view.frame.size.height / 8.2
        
        NSLayoutConstraint.activate([
            self.gameLogoImageView.centerYAnchor.constraint(equalTo: self.dashBoardStackView.centerYAnchor),
            self.gameLogoImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            self.dashBoardStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            self.dashBoardStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.gameLogoImageView.trailingAnchor, multiplier: 2),
            
            self.menuBar.topAnchor.constraint(equalToSystemSpacingBelow: self.dashBoardStackView.bottomAnchor, multiplier: 1),
            self.menuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.menuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.menuBar.heightAnchor.constraint(equalToConstant: 50),
            
            self.collectionView.topAnchor.constraint(equalTo: self.menuBar.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: tabBarHeight)
        ])
    }
    
    private func setDelegate() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.menuBar.delegate = self
    }
    
    private func getAllUserData() {
        let mockUser = MoonoMockUserData().getOneUserData()
        
        self.vm.getAllUserData { result in
            switch result {
            case .success(let addressList):

                /// Users list of UsersCellVM
                let popScoreVMList = addressList.map { address in
                    /// Check if address is the same as current (mock) user's
                    if address.ownerAddress == mockUser.address {
                        self.vm.youCellViewModel.currentUser.value = address
                    }
                    
                    return PopScoreRankCellViewModel(
                        rankImage: UIImage(contentsOfFile: LeaderBoardAsset.firstPlace.rawValue),
                        rank: 0,
                        profileImageUrl: address.profileImageUrl,
                        owerAddress: address.ownerAddress,
                        totalNfts: 17, //NEED TO CHANGE
                        popScore: address.popScore,
                        actioncount: address.actionCount
                    )
                }
                self.vm.usersCellViewModel.usersList.value = popScoreVMList
            case .failure(let failure):
                print("Failed from SettingVC: \(failure.localizedDescription)")
            }
        }
    }
    
    private func getNftData() {
        self.vm.getNftData(ofCollection: .moono) { result in
            switch result {
            case .success(let collection):
                self.vm.usersCellViewModel.currentNft.value = collection
            case .failure(let failure):
                print("Failed from SettingVC: \(failure.localizedDescription)")
            }
        }
    }
    
    private func getAllNftData() {
        /// Get all the moono nft card data saved in firestore
        self.vm.getAllNftData(ofCollection: .moono) { result in
            switch result {
            case .success(let cardList):
                let nftRankCellVMList = cardList.map { card in
                    return NftRankCellViewModel(
                        rank: 0,
                        rankImage: UIImage(contentsOfFile: LeaderBoardAsset.firstPlace.rawValue),
                        nftImageUrl: card.imageUrl,
                        nftName: card.tokenId,
                        score: card.popScore,
                        ownerAddress: card.ownerAddress
                    )
                }
                self.vm.youCellViewModel.nftRankViewModels.value = nftRankCellVMList
                self.vm.nftsCellViewModel.nftsList.value = nftRankCellVMList
            case .failure(let failure):
                print("Failed from SettingVC: \(failure.localizedDescription)")
            }
        }
    }
    
    private func getAllNftDocument(ofCollectionType collectionType: CollectionType) {
        /// Get all the `NFT collection` documents from firestore
        self.vm.getAllCollectionDataTest(ofCollectionType: collectionType) { result in
            switch result {
            case .success(let collections):
                let nftCollectionList = collections.map { collection in
                    return ProjectPopScoreCellViewModel(
                        rank: 0,
                        nftImageUrl: collection.imageUrl,
                        nftCollectionName: collectionType.rawValue,
                        totalNfts: collection.totalNfts, //TODO: NEED TO CHANGE
                        totalHolders: collection.totalHolders, //TODO: NEED TO CHANGE
                        popScore: collection.totalPopCount,
                        actioncount: collection.totalActionCount
                    )
                }
                self.vm.projectsCellViewModel.nftCollectionList.value = nftCollectionList
            case .failure(let failure):
                print("Failed from SettingVC: \(failure.localizedDescription)")
            }
        }
//        self.vm.getAllNftDocument(ofCollectionType: collectionType) { result in
//            switch result {
//            case .success(let cardList):
//                let nftCollectionList = cardList.map { card in
//                    return ProjectPopScoreCellViewModel(
//                        rank: 0,
//                        nftImageUrl: card.imageUrl,
//                        nftCollectionName: collectionType.rawValue,
//                        totalNfts: 1000, //TODO: NEED TO CHANGE
//                        totalHolders: 200, //TODO: NEED TO CHANGE
//                        popScore: card.popScore,
//                        actioncount: card.actionCount
//                    )
//                }
//                self.vm.projectsCellViewModel.nftCollectionList.value = nftCollectionList
//            case .failure(let failure):
//                print("Failed from SettingVC: \(failure.localizedDescription)")
//            }
//        }
    }
    
    private func getHolderAndNumberOfNFTs() {
        /// =======
        Task {
            do {
                let holders = try await KlaytnNftRequester.getNumberOfHolders(ofCollection: K.ContractAddress.moono)
                vm.projectsCellViewModel.totalNumberOfHolders.value = holders?.totalHolder
                
                let contractInfoResult = try await KlaytnNftRequester.getNumberOfIssuedNFTs(ofCollection: K.ContractAddress.moono)
                guard let mintedNFTs = contractInfoResult?.totalSupply.dropFirst(2) else { return }
                let convertedNumber = Int(mintedNFTs, radix: 16)
                vm.projectsCellViewModel.totalNumberOfMintedNFTs.value = convertedNumber

                FirestoreRepository.shared.saveNumberOfHoldersAndMintedNfts(collectionType: .moono,
                                                                            totalHolders: Int64(holders?.totalHolder ?? 0),
                                                                            totalMintedNFTs: Int64(convertedNumber ?? 0))
            } catch {
                print(error.localizedDescription)
            }
         
        }
        /// =======
    }
    
}

extension SettingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.vm.numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = self.vm.cells[indexPath.item]
        
        switch cellType {
        case .you:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YouCell.identifier, for: indexPath) as? YouCell else { return UICollectionViewCell() }
            
            cell.bind(with: vm.youCellViewModel)
            cell.configure(vm: vm.youCellViewModel)
            return cell
            
        case .users:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsersCell.identifier, for: indexPath) as? UsersCell else { return UICollectionViewCell() }
            
            cell.bind(with: vm.usersCellViewModel)
            cell.configure(vm: vm.usersCellViewModel)
            return cell
            
        case .nfts:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashBoardNftCell.identifier, for: indexPath) as? DashBoardNftCell else { return UICollectionViewCell() }
            
            cell.bind(with: vm.nftsCellViewModel)
            cell.configure(vm: vm.nftsCellViewModel)
            return cell
            
        case .projects:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectsCell.identifier, for: indexPath) as? ProjectsCell else { return UICollectionViewCell() }
            
            cell.bind(with: vm.projectsCellViewModel)
            cell.configure(vm: vm.projectsCellViewModel)
            return cell
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        menuBar.selectItem(at: Int(index))
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: collectionView.frame.height)
//    }

}

extension SettingViewController: SettingMenuBarDelegate {
    func didSelectItemAt(index: Int) {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        menuBar.selectItem(at: index)
        collectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }
}

