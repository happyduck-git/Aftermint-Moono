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
        
        vm.getHolderAndNumberOfNFTs()
        
        vm.getAllAddressFields()
        vm.getNftData(ofCollectionType: .moono)
        vm.getAllCards(ofCollectionType: .moono)
        vm.getAllCollectionFields(ofCollectionType: .moono)
        
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

}

extension SettingViewController: SettingMenuBarDelegate {
    func didSelectItemAt(index: Int) {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        menuBar.selectItem(at: index)
        collectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }
}

