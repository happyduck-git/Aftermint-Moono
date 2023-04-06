//
//  DashBoardNftCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class DashBoardNftCell: UICollectionViewCell {
    
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NftRankCell.identifier) else { return UITableViewCell() }
        return cell
    }
    
}
