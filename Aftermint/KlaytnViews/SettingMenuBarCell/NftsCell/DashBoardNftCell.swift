//
//  DashBoardNftCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class DashBoardNftCell: UICollectionViewCell {
    
    private var nftsList: [NftRankCellViewModel] = []
    private var highestScoreVM: NftRankCellViewModel?
    private let mockUser = MoonoMockUserData().getOneUserData()
    
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
    
    /// Bind function - Test
    public func configure(with vm: DashBoardNftCellViewModel) {
        
        vm.nftsList.bind { [weak self] nfts in
            guard let `self` = self else { return }
            self.nftsList = nfts ?? []
            vm.getTheHighestScoreNftOfCurrentUser()
            DispatchQueue.main.async {
                self.nftScoreTableView.reloadData()
            }
        }
        
        vm.highestNft.bind { [weak self] rankCellVM in
            guard let `self` = self,
                  let vm = rankCellVM
            else { return }
                    
            self.highestScoreVM = vm
        }
        
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
        if section == 0 {
            return 1
        } else {
            return self.nftsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NftRankCell.identifier) as? NftRankCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.resetCell()
        cell.switchRankImageToLabel()
        
        if indexPath.section == 0 {
            guard let vm = self.highestScoreVM else { return UITableViewCell() }
            cell.showStarBadge()
            cell.nftImageBorderColor = AftermintColor.moonoBlue.cgColor
            cell.nftNameLabelColor = AftermintColor.moonoBlue
            cell.rankLabelColor = AftermintColor.moonoBlue
            cell.contentView.backgroundColor = AftermintColor.moonoYellow.withAlphaComponent(0.2)
            cell.configure(vm: vm)
            return cell
            
        } else {
            let vm = nftsList[indexPath.row]
            vm.setRankNumberWithIndexPath(indexPath.row + 1)
            
            /// Find current user owned nfts and highlight those cells
            if self.checkCurrentUserOwnedNfts(vm: vm) {
                cell.showStarBadge()
                cell.nftImageBorderColor = AftermintColor.moonoBlue.cgColor
                cell.nftNameLabelColor = AftermintColor.moonoBlue
                cell.rankLabelColor = AftermintColor.moonoBlue
                cell.contentView.backgroundColor = AftermintColor.moonoYellow.withAlphaComponent(0.2)
            }
            
            cell.configure(vm: vm)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func checkCurrentUserOwnedNfts(vm: NftRankCellViewModel) -> Bool {
//        print(vm.ownerAddress)
        if vm.ownerAddress == mockUser.address {
            return true
        }
        return false
    }
    
}
