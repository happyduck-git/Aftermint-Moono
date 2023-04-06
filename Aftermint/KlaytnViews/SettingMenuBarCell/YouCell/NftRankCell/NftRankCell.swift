//
//  NftRankCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/04.
//

import UIKit

final class NftRankCell: UITableViewCell {
    
    //MARK: - UI Elements
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.text = SettingAsset.pointLabel.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.nftImageView.frame.size.height
        self.nftImageView.layer.cornerRadius = height / 2
    }
    
    //MARK: - Private
    private func setUI() {
        self.contentView.addSubview(rankLabel)
        self.contentView.addSubview(nftImageView)
        self.contentView.addSubview(nftNameLabel)
        self.contentView.addSubview(scoreLabel)
        self.contentView.addSubview(pointLabel)
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.rankLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.rankLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankLabel.bottomAnchor, multiplier: 1),
            self.rankLabel.widthAnchor.constraint(equalTo: self.rankLabel.heightAnchor),
            self.nftImageView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankLabel.trailingAnchor, multiplier: 0),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 1),
            self.nftImageView.widthAnchor.constraint(equalTo: self.nftImageView.heightAnchor),
            self.nftNameLabel.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.nftNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftNameLabel.bottomAnchor, multiplier: 1),
            self.scoreLabel.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.scoreLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftNameLabel.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.scoreLabel.bottomAnchor, multiplier: 1),
            self.pointLabel.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.scoreLabel.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1)
        ])
        
        self.pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    //MARK: - Public
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
}
