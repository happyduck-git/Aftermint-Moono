//
//  NftRankCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class NftRankCell: UITableViewCell {
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.nftImageView.layer.cornerRadius = self.nftImageView.frame.size.height / 2
    }
    
    //MARK: - UI Elements
    private let rankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = false
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = BellyGomFont.header03
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// To put start badge on current user's nfts
    private let starBadge: UIImageView = {
       let imageView = UIImageView()
        imageView.isHidden = true
        imageView.image = UIImage(systemName: "star.fill")?.withTintColor(AftermintColor.moonoBlue, renderingMode: .alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftNameLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header08
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.textColor = AftermintColor.moonoYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.pointLabel.rawValue
        label.font = BellyGomFont.header07
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Setter
    var rankLabelColor: UIColor = .white {
        didSet {
            self.rankLabel.textColor = self.rankLabelColor
        }
    }
    
    var nftImageBorderColor: CGColor = UIColor.white.cgColor {
        didSet {
            self.nftImageView.layer.borderColor = self.nftImageBorderColor
        }
    }
    
    var nftNameLabelColor: UIColor = .white {
        didSet {
            self.nftNameLabel.textColor = self.nftNameLabelColor
        }
    }
    
    //MARK: - Private
    private func setUI() {
        self.backgroundColor = AftermintColor.backgroundNavy
        
        self.contentView.addSubview(rankImageView)
        self.contentView.addSubview(rankLabel)
        self.contentView.addSubview(nftImageView)
        self.contentView.addSubview(nftNameLabel)
        self.contentView.addSubview(scoreLabel)
        self.contentView.addSubview(pointLabel)
        self.contentView.addSubview(starBadge)
    }
    
    private func setLayout() {
        
        let height = contentView.frame.size.height
        
        NSLayoutConstraint.activate([
            self.rankLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.rankLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankLabel.bottomAnchor, multiplier: 1),
            
            self.rankImageView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.rankImageView.leadingAnchor.constraint(equalTo: self.rankLabel.leadingAnchor),
            self.rankImageView.bottomAnchor.constraint(equalTo: self.rankLabel.bottomAnchor),
            self.rankImageView.widthAnchor.constraint(equalToConstant: height / 2),
            
            self.nftImageView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 1),
            self.nftImageView.widthAnchor.constraint(equalTo: self.nftImageView.heightAnchor),
            
            /// ========================
            self.starBadge.heightAnchor.constraint(equalTo: self.nftImageView.heightAnchor, multiplier: 0.4),
            self.starBadge.widthAnchor.constraint(equalTo: self.starBadge.heightAnchor),
            self.starBadge.topAnchor.constraint(equalTo: self.nftImageView.topAnchor),
            self.starBadge.trailingAnchor.constraint(equalTo: self.nftImageView.trailingAnchor),
            /// ========================
            
            self.nftNameLabel.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.nftNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftNameLabel.bottomAnchor, multiplier: 1),
            self.scoreLabel.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.scoreLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftNameLabel.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.scoreLabel.bottomAnchor, multiplier: 1),
            self.pointLabel.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.scoreLabel.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1)
        ])
        
        self.rankImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.rankLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.scoreLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    //MARK: - Public
    
    public func switchRankImageToLabel() {
        self.rankImageView.isHidden = true
        self.rankLabel.isHidden = false
    }

    public func showStarBadge() {
        self.starBadge.isHidden = false
    }
    
    public func configure(vm: NftRankCellViewModel) {
        self.rankLabel.text = "\(vm.rank)"
        let url = URL(string: vm.nftImageUrl)
        NukeImageLoader.loadImageUsingNuke(url: url) { image in
            DispatchQueue.main.async {
                self.nftImageView.image = image
            }
        }
        self.nftNameLabel.text = vm.nftName
        self.scoreLabel.text = "\(vm.score)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rankImageView.isHidden = false
        self.rankLabel.isHidden = true
    }
    
    public func resetCell() {
        self.starBadge.isHidden = true
        self.nftImageView.image = nil
        self.rankLabel.text = nil
        self.nftNameLabel.text = nil
        self.scoreLabel.text = nil
        self.pointLabel.text = nil
        self.rankLabel.textColor = .white
        self.nftImageView.layer.borderColor = UIColor.white.cgColor
        self.nftNameLabel.textColor = .white
        self.contentView.backgroundColor?.withAlphaComponent(1.0)
        self.contentView.backgroundColor = AftermintColor.backgroundNavy
    }
    
}
