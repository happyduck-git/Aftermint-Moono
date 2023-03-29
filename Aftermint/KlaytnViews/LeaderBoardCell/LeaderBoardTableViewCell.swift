//
//  LeaderBoardTableViewCell.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit

final class LeaderBoardTableViewCell: UITableViewCell {
    
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
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor(ciColor: .white).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftInfoStackView: BasicStackView = {
        let stack = BasicStackView()
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
    
    private let touchScoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = BellyGomFont.header03
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = AftermintColor.backgroundNavy
        nftImageView.layer.cornerRadius = nftImageView.frame.size.width / 2
    }
    
    // MARK: - Private
    private func setUI() {
        contentView.addSubview(rankImageView)
        contentView.addSubview(rankLabel)
        contentView.addSubview(nftImageView)
        contentView.addSubview(nftNameLabel) //Will be replaced
        contentView.addSubview(nftInfoStackView)
        contentView.addSubview(touchScoreLabel)
    }
    
    private func setLayout() {
        
        let height = contentView.frame.size.height
        
        NSLayoutConstraint.activate([
            self.rankImageView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            self.rankImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 4),
            self.rankImageView.widthAnchor.constraint(equalToConstant: height / 2),
            self.rankImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            self.rankLabel.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.rankLabel.leadingAnchor.constraint(equalTo: self.rankImageView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankLabel.bottomAnchor, multiplier: 1),
            
            self.nftImageView.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.nftImageView.widthAnchor.constraint(equalTo: self.nftImageView.heightAnchor),
            self.nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankImageView.trailingAnchor, multiplier: 2),
            
            self.nftInfoStackView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.nftInfoStackView.bottomAnchor.constraint(equalTo: self.rankLabel.bottomAnchor),
            self.nftInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 2),
            
            self.touchScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.touchScoreLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftNameLabel.trailingAnchor, multiplier: 2),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.touchScoreLabel.trailingAnchor, multiplier: 4)
                                                       
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rankImageView.isHidden = false
        self.rankLabel.isHidden = true
    }
    
    internal func resetCell() {
        self.rankLabel.text = nil
        self.nftImageView.image = nil
        self.nftNameLabel.text = nil
        self.touchScoreLabel.text = nil
        self.contentView.backgroundColor = nil
    }
    
    // MARK: - Public
    public func configure(with vm: LeaderBoardTableViewCellViewModel) {
        rankImageView.image = vm.rankImage
        rankLabel.text = String(describing: vm.rank)
        nftNameLabel.text = vm.nftName //TODO: Change TokenId -> NFTName (e.g. Moono #199)
        nftInfoStackView.topLabelText = "NFT Project"
        touchScoreLabel.text = String(describing: vm.touchScore)
       
        self.imageStringToImage(with: vm.userProfileImage) { result in
            switch result {
            case .success(let image):
                self.nftImageView.image = image
                return
            case .failure(let error):
                print("Error configure NftRankCell --- \(error.localizedDescription) --- with result \(result)")
                self.nftImageView.image = nil
                return
            }
        }
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
