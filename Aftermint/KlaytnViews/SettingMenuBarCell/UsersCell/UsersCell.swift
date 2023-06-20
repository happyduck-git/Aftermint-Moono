//
//  UsersCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class UsersCell: UICollectionViewCell {
    
    private var viewModel: UsersCellViewModel? {
        didSet {
            self.bind()
        }
    }
    
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
        imageView.clipsToBounds = true
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
        label.textColor = .white
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
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Pop score", "Action count"])
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.selectedSegmentTintColor = .black.withAlphaComponent(0.5)
        control.addTarget(self, action: #selector(didChangeValue(segment:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let popScoreTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .black
        table.register(PopScoreRankCell.self, forCellReuseIdentifier: PopScoreRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let actionCountTableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.backgroundColor = .black
        table.register(PopScoreRankCell.self, forCellReuseIdentifier: PopScoreRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        setUI()
        setLayout()
        setDelegate()
        
        spinner.startAnimating()
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
        self.contentView.addSubview(spinner)
    }
    
    private func setLayout() {
        let spinnerHeight: CGFloat = 50
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
            self.contentView.bottomAnchor.constraint(equalTo: self.actionCountTableView.bottomAnchor),
            
            self.spinner.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.spinner.heightAnchor.constraint(equalToConstant: spinnerHeight),
            self.spinner.widthAnchor.constraint(equalTo: self.spinner.heightAnchor)
        ])
        
        self.nftImageView.layer.cornerRadius = 80 / 2
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
    public func configure(with vm: UsersCellViewModel) {
        self.viewModel = vm
    }
    
    private func bind() {
        guard let vm = self.viewModel else {
            return
        }
        
        vm.currentNft.bind { [weak self] collection in
            guard let `self` = self,
                  let collection = collection else { return }
            DispatchQueue.main.async {
                self.popScoreLabel.text = "\(collection?.totalPopCount ?? 0)"
                self.actionCountLabel.text = "\(collection?.totalActionCount ?? 0)"
                guard let imageUrl = collection?.imageUrl else { return }
                let url = URL(string: imageUrl)
                NukeImageLoader.loadImageUsingNuke(url: url) { image in
                    self.nftImageView.image = image
                }
            }
        }
        
        vm.usersList.bind { viewModels in
          
            let filteredList = vm.usersList.value?.filter({ vm in
                vm.ownerAddress == MoonoMockUserData().getOneUserData().address
            })
            
            vm.currentUserInfo.value = filteredList?.first

        }
        
        vm.isLoaded.bind { [weak self] isLoaded in
            guard let `self` = self,
                  isLoaded != nil,
                  isLoaded == true
            else { return }
            DispatchQueue.main.async {
                self.popScoreTableView.reloadData()
                self.actionCountTableView.reloadData()
                self.spinner.stopAnimating()
            }
        }
    }

}

extension UsersCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.textColor = .lightGray
        label.font = BellyGomFont.header04
        
        if tableView == popScoreTableView {
            if section == 0 {
                label.text = SettingAsset.usersPopScoreFirstSectionHeader.rawValue
            } else {
                label.text = SettingAsset.usersPopScoreSecondSectionHeader.rawValue
            }
        } else if tableView == actionCountTableView {
            if section == 0 {
                label.text = SettingAsset.usersActionCountFirstSectionHeader.rawValue
            } else {
                label.text = SettingAsset.usersActionCountSecondSectionHeader.rawValue
            }
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.numberOfRowsAt(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: PopScoreRankCell.identifier, for: indexPath) as? PopScoreRankCell
        else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.resetCell()
        
        guard let vmNew = self.viewModel?.viewModelAt(indexPath) else {
            return UITableViewCell()
        }
       
        if vmNew.ownerAddress == MoonoMockUserData().getOneUserData().address {
            self.setCurrentUserColor(at: cell, color: AftermintColor.bellyGreen)
            cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
        }
        
        if indexPath.row <= 2 {
            vmNew.setRankImage(with: cellRankImageAt(indexPath.row))
        } else {
            cell.switchRankImageToLabel()
            vmNew.setRankNumberWithIndexPath(indexPath.row + 1)
        }
        
        if tableView == self.popScoreTableView {
            if indexPath.section == 0 {
                print("Rank image of the popScoreTableView: \(String(describing: vmNew.rank))")
                self.setCurrentUserColor(at: cell, color: AftermintColor.bellyGreen)
                cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
                
                if vmNew.rank >= 3 {
                    cell.switchRankImageToLabel()
                    vmNew.setRankNumberWithIndexPath(indexPath.row + 1)
                }
            }
            cell.configureRankScoreCell(with: vmNew)
            return cell
            
        } else if tableView == self.actionCountTableView {
            if indexPath.section == 0 {
                self.setCurrentUserColor(at: cell, color: AftermintColor.bellyGreen)
                cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
                
                if vmNew.rank >= 3 {
                    cell.switchRankImageToLabel()
                    vmNew.setRankNumberWithIndexPath(indexPath.row + 1)
                }
            }
            
            cell.configureActionCountCell(with: vmNew)
            return cell
            
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

