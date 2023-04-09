//
//  YouCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class YouCell: UICollectionViewCell {
    
    let vm: YouCellViewModel
    
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
        stack.topLabelFont = .systemFont(ofSize: 20, weight: .light)
        stack.bottomLabelFont = .systemFont(ofSize: 18, weight: .bold)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let usernameStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.usernameTitle.rawValue
        stack.topLabelFont = .systemFont(ofSize: 20, weight: .light)
        stack.bottomLabelFont = .systemFont(ofSize: 18, weight: .bold)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let popScoreStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.popScoreTitle.rawValue
        stack.topLabelFont = .systemFont(ofSize: 20, weight: .light)
        stack.bottomLabelFont = .systemFont(ofSize: 18, weight: .bold)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionCountStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = SettingAsset.actionCountTitle.rawValue
        stack.topLabelFont = .systemFont(ofSize: 20, weight: .light)
        stack.bottomLabelFont = .systemFont(ofSize: 18, weight: .bold)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftsTableView: UITableView = {
        let table = UITableView()
        table.register(NftRankCell.self, forCellReuseIdentifier: NftRankCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        self.vm = YouCellViewModel()
        super.init(frame: frame)
        setUI()
        setLayout()
        setDelegate()
        fetchTableViewData()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.profileImageView.frame.size.width
        self.profileImageView.layer.cornerRadius = width / 2
    }
    
    //MARK: - Private
    
    private func setUI() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(walletAddressStack)
        self.contentView.addSubview(usernameStack)
        self.contentView.addSubview(popScoreStack)
        self.contentView.addSubview(actionCountStack)
        self.contentView.addSubview(nftsTableView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 0),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.profileImageView.heightAnchor.constraint(equalToConstant: 90),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            self.walletAddressStack.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
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
            self.nftsTableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.nftsTableView.delegate = self
        self.nftsTableView.dataSource = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK: - Public
    public func configure(vm: YouCellViewModel) {
        guard let currentUser = vm.currentUser.value,
              let currentUser = currentUser
        else { return }
        self.profileImageView.image = UIImage(named: currentUser.profileImageUrl) /// TODO: Need to change the logic to actually fetch image from server or cache
        self.walletAddressStack.bottomLabelText = currentUser.ownerAddress.cutOfRange(length: 15)
        self.usernameStack.bottomLabelText = currentUser.username
        self.popScoreStack.bottomLabelText = "\(currentUser.popScore)"
        self.actionCountStack.bottomLabelText = "\(currentUser.actionCount)"
    }
    
    public func bind(with vm: YouCellViewModel) {
        vm.currentUser.bind { address in
            guard let address = address else { return }
            self.profileImageView.image = UIImage(named: address?.profileImageUrl ?? "N/A")
            self.walletAddressStack.bottomLabelText = address?.ownerAddress ?? "N/A"
            self.usernameStack.bottomLabelText = address?.username ?? "N/A"
            self.popScoreStack.bottomLabelText = "\(address?.popScore ?? 0)"
            self.actionCountStack.bottomLabelText = "\(address?.actionCount ?? 0)"
        }
        vm.nftRankViewModels.bind { _ in
            self.nftsTableView.reloadData()
        }
    }
    
}

extension YouCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingAsset.tableHeaderTitle.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = vm.nftRankViewModels.value?.count else { return 0 }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NftRankCell.identifier) as? NftRankCell,
              let nftRankCellViewModel = vm.nftRankViewModels.value?[indexPath.row]
        else { return UITableViewCell() }
        nftRankCellViewModel.setRankNumberWithIndexPath(indexPath.row + 1)
        cell.configure(vm: nftRankCellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func fetchTableViewData() {
        self.vm.getAllOwnedNft(collectionType: .moono, completion: { result in
            switch result {
            case .success(let viewModels):
                self.vm.nftRankViewModels.value = viewModels
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        })
    }
}

extension YouCell {
    
    private func bind() {
        vm.nftRankViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.nftsTableView.reloadData()
            }
        }
    }
    
}
