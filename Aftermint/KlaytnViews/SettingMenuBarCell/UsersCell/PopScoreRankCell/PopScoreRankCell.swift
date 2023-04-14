//
//  PopScoreRankCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class PopScoreRankCell: UITableViewCell {
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
    }
    
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
        stack.topLabelFont = BellyGomFont.header04
        stack.bottomLabelFont = BellyGomFont.header06
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = BellyGomFont.header03
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popScoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = BellyGomFont.header03
        label.textColor = AftermintColor.moonoYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Setter
    var rankImageColor: UIColor = .white {
        didSet {
            self.rankImageView.image?.withTintColor(self.rankImageColor)
        }
    }
    
    var rankLabelColor: UIColor = .white {
        didSet {
            self.rankLabel.textColor = self.rankLabelColor
        }
    }
    
    var userProfileImageBorderColor: CGColor = UIColor.white.cgColor {
        didSet {
            self.userProfileImageView.layer.borderColor = self.userProfileImageBorderColor
        }
    }
    
    var nftInfoTextColor: UIColor = UIColor.white {
        didSet {
            self.nftInfoStackView.topLabelTextColor = self.nftInfoTextColor
            self.nftInfoStackView.bottomLabelTextColor = self.nftInfoTextColor
        }
    }
    
    
    // MARK: - Private
    private func setUI() {
        self.backgroundColor = AftermintColor.backgroundNavy
        
        contentView.addSubview(rankImageView)
        contentView.addSubview(rankLabel)
        contentView.addSubview(userProfileImageView)
        contentView.addSubview(nftNameLabel) //Will be replaced
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
        self.userProfileImageView.image = nil
        self.nftNameLabel.text = nil
        self.popScoreLabel.text = nil
        self.rankImageView.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.rankLabel.textColor = .white
        self.userProfileImageView.layer.borderColor = UIColor.white.cgColor
        self.nftInfoStackView.topLabelTextColor = .white
        self.nftInfoStackView.bottomLabelTextColor = .white
        self.contentView.backgroundColor?.withAlphaComponent(1.0)
        self.contentView.backgroundColor = AftermintColor.backgroundNavy
    }
    
    // MARK: - Public
    public func configureRankScoreCell(with vm: PopScoreRankCellViewModel) {
        self.rankImageView.image = vm.rankImage
        self.rankLabel.text = "\(vm.rank)"
        self.userProfileImageView.image = UIImage(named: vm.profileImageUrl)
        self.nftInfoStackView.topLabelText = vm.ownerAddress.cutOfRange(length: 15)
        self.nftInfoStackView.bottomLabelText = "Nfts \(vm.totalNfts)"
        self.popScoreLabel.text = "\(vm.popScore)"
    }
    
    public func configureActionCountCell(with vm: PopScoreRankCellViewModel) {
        self.rankImageView.image = vm.rankImage
        self.rankLabel.text = "\(vm.rank)"
        self.userProfileImageView.image = UIImage(named: vm.profileImageUrl)
        self.nftInfoStackView.topLabelText = vm.ownerAddress.cutOfRange(length: 15)
        self.nftInfoStackView.bottomLabelText = "Nfts \(vm.totalNfts)"
        self.popScoreLabel.text = "\(vm.actioncount)"
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
