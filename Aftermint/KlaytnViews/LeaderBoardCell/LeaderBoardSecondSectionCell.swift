//
//  LeaderBoardTableViewCell.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit

final class LeaderBoardSecondSectionCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let rankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.textColor = AftermintColor.rankGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor(ciColor: .white).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftInfoStackView: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelFont = BellyGomFont.header05
        stack.bottomLabelFont = BellyGomFont.header06
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let popScoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = BellyGomFont.header04
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
    }
    
    // MARK: - Private
    private func setUI() {
        self.backgroundColor = AftermintColor.backgroundNavy
        
        contentView.addSubview(rankImageView)
        contentView.addSubview(rankLabel)
        contentView.addSubview(userProfileImageView)
        contentView.addSubview(nftInfoStackView)
        contentView.addSubview(popScoreLabel)
    }
    
    private func setLayout() {
        
        let height = contentView.frame.size.height
        
        NSLayoutConstraint.activate([
            self.rankImageView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            self.rankImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            self.rankImageView.widthAnchor.constraint(equalToConstant: height / 2),
            self.rankImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            self.rankLabel.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.rankLabel.leadingAnchor.constraint(equalTo: self.rankImageView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankLabel.bottomAnchor, multiplier: 1),
            
            self.userProfileImageView.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.userProfileImageView.widthAnchor.constraint(equalTo: self.userProfileImageView.heightAnchor),
            self.userProfileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.userProfileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankImageView.trailingAnchor, multiplier: 2),
            
            self.nftInfoStackView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.nftInfoStackView.bottomAnchor.constraint(equalTo: self.rankLabel.bottomAnchor),
            self.nftInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userProfileImageView.trailingAnchor, multiplier: 2),
            
            self.popScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.popScoreLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftInfoStackView.trailingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreLabel.trailingAnchor, multiplier: 1)
                                                       
        ])
        
        self.popScoreLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rankImageView.isHidden = false
        self.rankLabel.isHidden = true
    }
    
    internal func resetCell() {
        self.rankLabel.text = nil
        self.rankImageView.image = nil
        self.userProfileImageView.image = nil
        self.popScoreLabel.text = nil
        self.popScoreLabel.textColor = .white
        self.contentView.backgroundColor = nil
    }
    
    // MARK: - Public
    public func configure(with vm: LeaderBoardSecondSectionCellViewModel) {
        rankImageView.image = vm.rankImage
        rankLabel.text = String(describing: vm.rank)
        nftInfoStackView.topLabelText = vm.ownerAddress.cutOfRange(length: 15)
        nftInfoStackView.bottomLabelText = "NFTs \(vm.numberOfNfts)"
        popScoreLabel.text = String(describing: vm.popScore)

        self.imageStringToImage(with: vm.userProfileImage) { result in
            switch result {
            case .success(let image):
                self.userProfileImageView.image = image
            case .failure(let error):
                print("Error \(error)")
            }
        }
    }
    
    public func setAsCollectionInfoCell() {
        self.rankImageView.isHidden = true
        self.rankLabel.isHidden = true
    }
    
    public func switchRankImageToLabel() {
        self.rankImageView.isHidden = true
        self.rankLabel.isHidden = false
    }
    
    private func imageStringToImage(with urlString: String, completion: @escaping (Result<UIImage?, Error>) -> ()) {
        let url = URL(string: urlString)
        NukeImageLoader.loadImageUsingNuke(url: url) { image in
            completion(.success(image))
        }
    }
    
    enum ImageError: Error {
        case nukeImageLoadingError
    }
}
