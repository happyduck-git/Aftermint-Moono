//
//  ProjectsCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class ProjectsCell: UICollectionViewCell {
    
    private var currentCollection: ProjectPopScoreCellViewModel?
    private var nftCollectionList: [ProjectPopScoreCellViewModel] = []
    
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
    
    private let collectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popScoreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.projectsPopScoreTitle.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionCountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.actionCountTitle.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalNftsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.totalNftsTitle.rawValue
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalNftsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalHoldersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.totalHoldersTitle.rawValue
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalHoldersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
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
        table.register(ProjectPopScoreCell.self, forCellReuseIdentifier: ProjectPopScoreCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let actionCountTableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ProjectPopScoreCell.self, forCellReuseIdentifier: ProjectPopScoreCell.identifier)
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
        self.contentView.addSubview(collectionTitleLabel)
        self.contentView.addSubview(popScoreTitleLabel)
        self.contentView.addSubview(popScoreLabel)
        self.contentView.addSubview(actionCountTitleLabel)
        self.contentView.addSubview(actionCountLabel)
        self.contentView.addSubview(totalNftsTitleLabel)
        self.contentView.addSubview(totalNftsLabel)
        self.contentView.addSubview(totalHoldersTitleLabel)
        self.contentView.addSubview(totalHoldersLabel)
        self.contentView.addSubview(segmentedControl)
        self.contentView.addSubview(popScoreTableView)
        self.contentView.addSubview(actionCountTableView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 3),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.nftImageView.widthAnchor.constraint(equalToConstant: 80),
            self.nftImageView.heightAnchor.constraint(equalTo: self.nftImageView.widthAnchor),
            
            self.collectionTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.collectionTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 3),
            
            self.popScoreTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.collectionTitleLabel.bottomAnchor, multiplier: 1),
            self.popScoreTitleLabel.leadingAnchor.constraint(equalTo: self.collectionTitleLabel.leadingAnchor),
            self.popScoreLabel.topAnchor.constraint(equalTo: self.popScoreTitleLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreLabel.trailingAnchor, multiplier: 2),
            self.actionCountTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.popScoreTitleLabel.bottomAnchor, multiplier: 1),
            self.actionCountTitleLabel.leadingAnchor.constraint(equalTo: self.popScoreTitleLabel.leadingAnchor),
            self.actionCountLabel.topAnchor.constraint(equalTo: self.actionCountTitleLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.actionCountLabel.trailingAnchor, multiplier: 2),
            
            self.totalNftsTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 2),
            self.totalNftsTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.totalNftsLabel.topAnchor.constraint(equalTo: self.totalNftsTitleLabel.topAnchor),
            self.totalNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.totalNftsTitleLabel.trailingAnchor, multiplier: 2),
            self.totalHoldersTitleLabel.topAnchor.constraint(equalTo: self.totalNftsTitleLabel.topAnchor),
            self.totalHoldersTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.totalNftsLabel.trailingAnchor, multiplier: 2),
            self.totalHoldersLabel.topAnchor.constraint(equalTo: self.totalNftsTitleLabel.topAnchor),
            self.totalHoldersLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.totalHoldersTitleLabel.trailingAnchor, multiplier: 2),
            
            self.segmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: self.totalHoldersTitleLabel.bottomAnchor, multiplier: 3),
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

    @objc private func didChangeValue(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            self.shouldHideFirstSegment = false
        } else {
            self.shouldHideFirstSegment = true
        }
    }
    
    //MARK: - Public
    public func configure(vm: ProjectsCellViewModel) {
        self.nftCollectionList = vm.nftCollectionList.value ?? []
        self.currentCollection = vm.getCurrentNftCollection(ofType: .moono)
        
        self.nftImageView.image = UIImage(named: self.currentCollection?.nftImageUrl ?? "N/A")
        self.collectionTitleLabel.text = self.currentCollection?.nftCollectionName
        self.popScoreLabel.text = "\(self.currentCollection?.popScore ?? 0)"
        self.actionCountLabel.text = "\(self.currentCollection?.actioncount ?? 0)"
        self.totalNftsLabel.text = "\(self.currentCollection?.totalNfts ?? 0)"
        self.totalHoldersLabel.text = "\(self.currentCollection?.totalHolders ?? 0)"
    }
    
}

extension ProjectsCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.popScoreTableView {
            return "Project Pop Score Rank"
        } else if tableView == self.actionCountTableView {
            return "Project Action Count Rank"
        }
        return "Project Pop Score Rank"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.nftCollectionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProjectPopScoreCell.identifier, for: indexPath) as? ProjectPopScoreCell else { return UITableViewCell() }
        let vm = self.nftCollectionList[indexPath.row]
        vm.setRankNumberWithIndexPath(indexPath.row + 1)
        if tableView == self.popScoreTableView {
            cell.configureRankScoreCell(with: vm)
            return cell
        } else if tableView == self.actionCountTableView {
            cell.configureActionCountCell(with: vm)
        }
        return cell
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
