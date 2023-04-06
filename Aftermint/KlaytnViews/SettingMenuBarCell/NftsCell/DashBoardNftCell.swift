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
    
    //MARK: - UI Elements
    private let nftScoreTableView: UITableView = {
        let table = UITableView()
        table.register(NftRankCell.self, forCellReuseIdentifier: NftRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemGray
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
    public func configure(vm: DashBoardNftCellViewModel) {
        self.nftsList = vm.nftsList.value ?? []
        self.highestScoreVM = vm.getTheHighestScoreNftOfCurrentUser()
        DispatchQueue.main.async {
            self.nftScoreTableView.reloadData()
        }
    }
    
}

extension DashBoardNftCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return SettingAsset.nftsFirstSectionHeader.rawValue
        } else {
            return SettingAsset.nftsSecondSectionHeader.rawValue
        }
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
        if indexPath.section == 0 {
            guard let vm = self.highestScoreVM else { return UITableViewCell() }
            cell.configure(vm: vm)
            return cell
        } else {
            let vm = nftsList[indexPath.row]
            vm.setRankNumberWithIndexPath(indexPath.row + 1)
            cell.configure(vm: vm)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    /// Determine cell image
    private func cellRankImageAt(_ indexPathRow: Int) -> UIImage? {
        switch indexPathRow {
        case 0:
            return UIImage(named: LeaderBoardAsset.firstPlace.rawValue)
        case 1:
            return UIImage(named: LeaderBoardAsset.secondPlace.rawValue)
        case 2:
            return UIImage(named: LeaderBoardAsset.thirdPlace.rawValue)
        default:
            return UIImage(named: LeaderBoardAsset.markImageName.rawValue)
        }
    }
}
