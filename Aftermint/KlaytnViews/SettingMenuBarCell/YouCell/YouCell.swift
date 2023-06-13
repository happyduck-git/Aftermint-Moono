//
//  YouCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class YouCell: UICollectionViewCell {
    
    private var viewModel: YouCellViewModel? {
        didSet {
            self.bind()
        }
    }
    
    private let mockUser = MoonoMockUserData().getOneUserData()
    
    //MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let walletAddressStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.walletAddressTitle.rawValue
        stack.topLabelFont = BellyGomFont.header04
        stack.topLabelTextColor = AftermintColor.moonoBlue
        stack.bottomLabelFont = BellyGomFont.header08
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let usernameStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.usernameTitle.rawValue
        stack.topLabelFont = BellyGomFont.header04
        stack.topLabelTextColor = AftermintColor.moonoBlue
        stack.bottomLabelFont = BellyGomFont.header08
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let popScoreStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.popScoreTitle.rawValue
        stack.topLabelFont = BellyGomFont.header04
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header08
        stack.bottomLabelText = "0"
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionCountStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.actionCountTitle.rawValue
        stack.topLabelFont = BellyGomFont.header04
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header08
        stack.bottomLabelText = "0"
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftsTableView: UITableView = {
        let table = UITableView()
        table.alpha = 0.0
        table.backgroundColor = .black
        table.register(NftRankCell.self, forCellReuseIdentifier: NftRankCell.identifier)
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
        setUI()
        setLayout()
        setDelegate()
        
        self.spinner.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Private
    
    private func setUI() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(walletAddressStack)
        self.contentView.addSubview(usernameStack)
        self.contentView.addSubview(popScoreStack)
        self.contentView.addSubview(actionCountStack)
        self.contentView.addSubview(nftsTableView)
        self.contentView.addSubview(spinner)
    }
    
    private func setLayout() {
        let profileImageHeight: CGFloat = 90
        let spinnerHeight: CGFloat = 50
        
        NSLayoutConstraint.activate([
            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.profileImageView.heightAnchor.constraint(equalToConstant: profileImageHeight),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            self.walletAddressStack.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.walletAddressStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 2),
            self.usernameStack.topAnchor.constraint(equalToSystemSpacingBelow: self.walletAddressStack.bottomAnchor, multiplier: 2),
            self.usernameStack.leadingAnchor.constraint(equalTo: self.walletAddressStack.leadingAnchor),
            
            self.popScoreStack.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameStack.bottomAnchor, multiplier: 2),
            self.popScoreStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.actionCountStack.topAnchor.constraint(equalTo: self.popScoreStack.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.actionCountStack.trailingAnchor, multiplier: 3),
            
            self.nftsTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.popScoreStack.bottomAnchor, multiplier: 2),
            self.nftsTableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftsTableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.nftsTableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.spinner.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.spinner.heightAnchor.constraint(equalToConstant: spinnerHeight),
            self.spinner.widthAnchor.constraint(equalTo: self.spinner.heightAnchor)
        ])
        
        self.profileImageView.layer.cornerRadius = profileImageHeight / 2
    }
    
    private func setDelegate() {
        self.nftsTableView.delegate = self
        self.nftsTableView.dataSource = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func bind() {
        guard let vm = self.viewModel else {
            return
        }
        
        Task {
            guard let nftsOwned = UserDefaults.standard.dictionary(forKey: K.BasicInfo.ownedNfts) else {
                return
            }
            var convertedDictionary: [String: String] = [:]

            for (key, value) in nftsOwned {
                if let stringValue = value as? String {
                    convertedDictionary[key] = stringValue
                } else {
                    print("Value `\(value)` cannot be casted to String.")
                }
            }
            await vm.getCurrentUserCards(
                address: mockUser.address,
                gameType: .popgame,
                nftsOwned: convertedDictionary
            )
        }
        
        vm.currentUser.bind { [weak self] address in
            guard let address = address,
                  let `self` = self
            else { return }
            
            guard let urlString = address?.profileImageUrl else {
                return
            }
            let url = URL(string: urlString)
            NukeImageLoader.loadImageUsingNuke(url: url) { image in
                DispatchQueue.main.async { [weak self] in
                    self?.profileImageView.image = image
                }
            }
            DispatchQueue.main.async {
                self.walletAddressStack.bottomLabelText = address?.ownerAddress.cutOfRange(length: 15) ?? "N/A"
                self.usernameStack.bottomLabelText = address?.username ?? LeaderBoardAsset.usernamePlaceHolder.rawValue
                self.popScoreStack.bottomLabelText = "\(address?.popScore ?? 0)"
                self.actionCountStack.bottomLabelText = "\(address?.actionCount ?? 0)"
            }
        }
        
        vm.isLoaded.bind { [weak self] isLoaded in
            guard let `self` = self,
                  isLoaded != nil,
                  isLoaded == true
            else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6) {
                    self.nftsTableView.reloadData()
                    self.nftsTableView.alpha = 1.0
                    self.spinner.stopAnimating()
                }
            }
        }
    }
    
    //MARK: - Public
    
    public func configure(with vm: YouCellViewModel) {
        self.viewModel = vm
    }
    
}

extension YouCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = SettingAsset.tableHeaderTitle.rawValue
        label.font = BellyGomFont.header04
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.textColor = .lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.nftsList.count
        return self.viewModel?.numberOfRowsAt() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NftRankCell.identifier) as? NftRankCell
        else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.switchRankImageToLabel()
        
//        let vm = self.nftsList[indexPath.row]
        
        guard let vm = self.viewModel?.viewModelAt(indexPath) else {
            return UITableViewCell()
        }
        
        vm.setRankNumberWithIndexPath(indexPath.row + 1)
        cell.configure(vm: vm)
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
