//
//  UsersCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class UsersCell: UICollectionViewCell {
    
    var usersList: [PopScoreRankCellViewModel] = []
    //MARK: - UI Elements
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let popScoreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.projectPopScoreTitle.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionCountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.projectActionScoreTitle.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Pop score", "Action count"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let popScoreTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .orange
        table.register(PopScoreRankCell.self, forCellReuseIdentifier: PopScoreRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let actionCountTableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(PopScoreRankCell.self, forCellReuseIdentifier: PopScoreRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemBlue
        setUI()
        setLayout()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func setUI() {
        self.contentView.addSubview(nftImageView)
        self.contentView.addSubview(popScoreTitleLabel)
        self.contentView.addSubview(popScoreLabel)
        self.contentView.addSubview(actionCountTitleLabel)
        self.contentView.addSubview(actionCountLabel)
        self.contentView.addSubview(segmentedControl)
        self.contentView.addSubview(popScoreTableView)
        self.contentView.addSubview(actionCountTableView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.popScoreTitleLabel.topAnchor.constraint(equalTo: self.nftImageView.topAnchor),
            self.popScoreTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 1),
            self.popScoreLabel.topAnchor.constraint(equalTo: self.popScoreTitleLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreLabel.trailingAnchor, multiplier: 1),
            self.actionCountTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.popScoreTitleLabel.bottomAnchor, multiplier: 1),
            self.actionCountTitleLabel.leadingAnchor.constraint(equalTo: self.popScoreTitleLabel.leadingAnchor),
            self.actionCountLabel.topAnchor.constraint(equalTo: self.actionCountTitleLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.actionCountLabel.trailingAnchor, multiplier: 1),
            
            self.segmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: self.actionCountTitleLabel.bottomAnchor, multiplier: 2),
            self.segmentedControl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
            self.popScoreTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.segmentedControl.bottomAnchor, multiplier: 1),
            self.popScoreTableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.popScoreTableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.popScoreTableView.bottomAnchor, multiplier: 1),
            
            self.actionCountTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.segmentedControl.bottomAnchor, multiplier: 1),
            self.actionCountTableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.actionCountTableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.actionCountTableView.bottomAnchor, multiplier: 1),
        ])
    }
    
    private func setDelegate() {
        self.popScoreTableView.delegate = self
        self.popScoreTableView.dataSource = self
        self.actionCountTableView.delegate = self
        self.actionCountTableView.dataSource = self
    }
    
    //MARK: - Public
    public func configure(vm: UsersCellViewModel) {
        self.nftImageView.image = UIImage(named: vm.currentNft.value??.imageUrl ?? "N/A")
        self.popScoreLabel.text = "\(vm.currentNft.value??.popCount ?? 0)"
        self.actionCountLabel.text = "\(vm.currentNft.value??.actionCount ?? 0)"
        self.usersList = vm.usersList.value ?? []
        DispatchQueue.main.async {
            self.popScoreTableView.reloadData()
        }
    }
    
}

extension UsersCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.popScoreTableView {
            return self.usersList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.popScoreTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopScoreRankCell.identifier, for: indexPath) as? PopScoreRankCell
            else { return UITableViewCell() }
            
            let vm = self.usersList[indexPath.row]
            /// Set Rank Image for 1st to 3rd rank and give number of rank to below seats
            if indexPath.row <= 2 {
                vm.setRankImage(with: cellRankImageAt(indexPath.row))
            } else {
                cell.switchRankImageToLabel()
                vm.setRankNumberWithIndexPath(indexPath.row + 1)
            }
            
            cell.configure(with: vm)
            return cell
        }

        return UITableViewCell()
        
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

