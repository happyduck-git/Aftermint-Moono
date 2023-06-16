//
//  DashBoardNftCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

protocol DashBoardNftCellDelegate: AnyObject {
    func loadMoreCards()
}

final class DashBoardNftCell: UICollectionViewCell {
    
//    private var highestScoreVM: NftRankCellViewModel?
    private let mockUser = MoonoMockUserData().getOneUserData()
    
    private var viewModel: DashBoardNftCellViewModel? {
        didSet {
            self.bind()
        }
    }
    
    weak var delegate: DashBoardNftCellDelegate?
    
    //MARK: - UI Elements
    private let nftScoreTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .black
        table.register(NftRankCell.self, forCellReuseIdentifier: NftRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func setUI() {
        self.contentView.addSubview(self.nftScoreTableView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftScoreTableView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nftScoreTableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftScoreTableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.nftScoreTableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.nftScoreTableView.delegate = self
        self.nftScoreTableView.dataSource = self
    }
    
    //MARK: - Public
    
    private func bind() {
        guard let vm = viewModel else {
            return
        }
        
        vm.getAllCards()
        
        vm.nftsList.bind { [weak self] nfts in
            guard let `self` = self else { return }
            
            vm.getTheHighestScoreNftOfCurrentUser()
            
            DispatchQueue.main.async {
                self.nftScoreTableView.reloadData()
            }
        }
        
//        vm.highestNft.bind { [weak self] rankCellVM in
//            guard let `self` = self,
//                  let vm = rankCellVM
//            else { return }
//
//            self.highestScoreVM = vm
//        }
    }

    public func configure(with vm: DashBoardNftCellViewModel) {
        self.viewModel = vm
    }
    
}

extension DashBoardNftCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.textColor = .lightGray
        label.font = BellyGomFont.header04
        
        if section == 0 {
            label.text = SettingAsset.nftsFirstSectionHeader.rawValue
        } else {
            label.text = SettingAsset.nftsSecondSectionHeader.rawValue
        }
        
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else {
            return 0
        }
        
        return vm.numberOfRowsAt(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NftRankCell.identifier) as? NftRankCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.resetCell()
        cell.switchRankImageToLabel()
        
        guard let vm = viewModel,
              let cellVM = vm.viewModelAt(indexPath)
        else {
            return UITableViewCell()
        }
        
        /// Find current user owned nfts and highlight those cells
        if self.checkCurrentUserOwnedNfts(vm: cellVM) {
            cell.showStarBadge()
            cell.nftImageBorderColor = AftermintColor.moonoBlue.cgColor
            cell.nftNameLabelColor = AftermintColor.moonoBlue
            cell.rankLabelColor = AftermintColor.moonoBlue
            cell.contentView.backgroundColor = AftermintColor.moonoYellow.withAlphaComponent(0.2)
        }
        
        if indexPath.section != 0 {
            cellVM.setRankNumberWithIndexPath(indexPath.row + 1)
        }
        
//        print("Section#\(indexPath.section) row no.\(indexPath.row) rank: \(cellVM.rank)")
        
        cell.configure(vm: cellVM)
        
        return cell
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func checkCurrentUserOwnedNfts(vm: NftRankCellViewModel) -> Bool {

        if vm.ownerAddress == mockUser.address {
            return true
        }
        return false
    }
    
}

extension DashBoardNftCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
        
        let loadMore = viewModel?.isLoadingMorePosts ?? false
        
        if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) &&
            viewModel?.lastDoc != nil &&
            !loadMore
        {
            delegate?.loadMoreCards()
        }
    }
    
}
