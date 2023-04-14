//
//  UsersCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class UsersCell: UICollectionViewCell {
    
    private var usersList: [PopScoreRankCellViewModel] = []
    private var currentUserVM: PopScoreRankCellViewModel?
    
    /// Bool property to check which view should the segmentedControl show
    private var shouldHideFirstSegment: Bool = false {
        didSet {
            self.popScoreTableView.isHidden = self.shouldHideFirstSegment
            self.actionCountTableView.isHidden = !self.shouldHideFirstSegment
        }
    }
    
    //MARK: - UI Elements
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let popScoreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header04
        label.textColor = AftermintColor.moonoBlue
        label.text = SettingAsset.usersPopScoreTitle.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popScoreLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionCountTitleLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header04
        label.textColor = AftermintColor.moonoBlue
        label.text = SettingAsset.usersActionScoreTitle.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionCountLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Pop score", "Action count"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(didChangeValue(segment:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let popScoreTableView: UITableView = {
        let table = UITableView()
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
        self.contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
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
            self.nftImageView.widthAnchor.constraint(equalToConstant: 80),
            self.nftImageView.heightAnchor.constraint(equalTo: self.nftImageView.widthAnchor),
            
            self.popScoreTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.topAnchor, multiplier: 2),
            self.popScoreTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 3),
            self.popScoreLabel.topAnchor.constraint(equalTo: self.popScoreTitleLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreLabel.trailingAnchor, multiplier: 2),
            self.actionCountTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.popScoreTitleLabel.bottomAnchor, multiplier: 1),
            self.actionCountTitleLabel.leadingAnchor.constraint(equalTo: self.popScoreTitleLabel.leadingAnchor),
            self.actionCountLabel.topAnchor.constraint(equalTo: self.actionCountTitleLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.actionCountLabel.trailingAnchor, multiplier: 2),
            
            self.segmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: self.actionCountTitleLabel.bottomAnchor, multiplier: 4),
            self.segmentedControl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
            self.popScoreTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.segmentedControl.bottomAnchor, multiplier: 1),
            self.popScoreTableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.popScoreTableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.popScoreTableView.bottomAnchor),
            
            self.actionCountTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.segmentedControl.bottomAnchor, multiplier: 1),
            self.actionCountTableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.actionCountTableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.actionCountTableView.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.popScoreTableView.delegate = self
        self.popScoreTableView.dataSource = self
        self.actionCountTableView.delegate = self
        self.actionCountTableView.dataSource = self
    }
    
    //MARK: - Private
    @objc private func didChangeValue(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            self.shouldHideFirstSegment = false
        } else {
            self.shouldHideFirstSegment = true
        }
    }
    
    //MARK: - Public
    public func configure(vm: UsersCellViewModel) {
        guard let image = vm.currentNft.value??.imageUrl else { return }
        self.nftImageView.image = UIImage(named: image)
        self.popScoreLabel.text = "\(vm.currentNft.value??.totalPopCount ?? 0)"
        self.actionCountLabel.text = "\(vm.currentNft.value??.totalActionCount ?? 0)"
        
        self.usersList = vm.usersList.value ?? []
    }
    
    public func bind(with vm: UsersCellViewModel) {
        
        vm.currentNft.bind { [weak self] collection in
            guard let collection = collection else { return }
            DispatchQueue.main.async {
                self?.popScoreLabel.text = "\(collection?.totalPopCount ?? 0)"
                self?.actionCountLabel.text = "\(collection?.totalActionCount ?? 0)"
            }
        }
        
        vm.usersList.bind { [weak self] viewModels in
            self?.usersList = viewModels ?? []
          
            let filteredList = vm.usersList.value?.filter({ vm in
                vm.ownerAddress == MoonoMockUserData().getOneUserData().address
            })
            self?.currentUserVM = filteredList?.first
            
            DispatchQueue.main.async {
                self?.popScoreTableView.reloadData()
                self?.actionCountTableView.reloadData()
            }
        }
        
    }
    
}

extension UsersCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == popScoreTableView {
            if section == 0 {
                return SettingAsset.usersPopScoreFirstSectionHeader.rawValue
            } else {
                return SettingAsset.usersPopScoreSecondSectionHeader.rawValue
            }
        } else if tableView == actionCountTableView {
            if section == 0 {
                return SettingAsset.usersActionCountFirstSectionHeader.rawValue
            } else {
                return SettingAsset.usersActionCountSecondSectionHeader.rawValue
            }
        }
        return SettingAsset.emptyTitle.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.usersList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PopScoreRankCell.identifier, for: indexPath) as? PopScoreRankCell,
              let currentUserVM = currentUserVM
        else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.resetCell()
        
        let vm = self.usersList[indexPath.row]
        /// Set Rank Image for 1st to 3rd rank and give number of rank to below seats
        if indexPath.row <= 2 {
            vm.setRankImage(with: cellRankImageAt(indexPath.row))
        } else {
            cell.switchRankImageToLabel()
            vm.setRankNumberWithIndexPath(indexPath.row + 1)
        }
        /// Check if vm is the owner's vm;
        /// if so, change the cell content background color
        if vm.ownerAddress == MoonoMockUserData().getOneUserData().address {
            self.setCurrentUserColor(at: cell, color: AftermintColor.bellyGreen)
            cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
        }
        
        if tableView == self.popScoreTableView {
            if indexPath.section == 0 {
//                print("Rank image of the popScoreTableView: \(String(describing: currentUserVM.rankImage))")
                self.setCurrentUserColor(at: cell, color: AftermintColor.bellyGreen)
                cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
                cell.configureRankScoreCell(with: currentUserVM)
                return cell
            } else {
                
                cell.configureRankScoreCell(with: vm)
                return cell
            }
            
        } else if tableView == self.actionCountTableView {
            if indexPath.section == 0 {
//                print("Rank image of the actionCountTableView: \(String(describing: currentUserVM.rankImage))")
                self.setCurrentUserColor(at: cell, color: AftermintColor.bellyGreen)
                cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
                cell.configureActionCountCell(with: currentUserVM)
                return cell
            } else {
                cell.configureActionCountCell(with: vm)
                return cell
            }
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func setCurrentUserColor(at cell: PopScoreRankCell,
                             color: UIColor) {
        cell.rankImageColor = color
        cell.rankLabelColor = color
        cell.nftInfoTextColor = color
        cell.userProfileImageBorderColor = color.cgColor
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

