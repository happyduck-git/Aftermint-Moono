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
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
    }
    
    // MARK: - Private
    private func setUI() {
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
        self.contentView.backgroundColor = nil
    }
    
    // MARK: - Public
    public func configure(with vm: LeaderBoardTableViewCellViewModel) {
        rankImageView.image = vm.rankImage
        rankLabel.text = String(describing: vm.rank)
        nftInfoStackView.topLabelText = vm.topLabelText.cutOfRange(length: 10)
        nftInfoStackView.bottomLabelText = vm.bottomLabelText
        popScoreLabel.text = String(describing: vm.popScore)
        userProfileImageView.image = UIImage(named: vm.userProfileImage)
       
        //Temporarily inactivated
        /*
        self.imageStringToImage(with: vm.userProfileImage) { result in
            switch result {
            case .success(let image):
                self.userProfileImageView.image = image
                return
            case .failure(let error):
                print("Error configure NftRankCell --- \(error.localizedDescription) --- with result \(result)")
                self.userProfileImageView.image = nil
                return
            }
        }
         */
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
