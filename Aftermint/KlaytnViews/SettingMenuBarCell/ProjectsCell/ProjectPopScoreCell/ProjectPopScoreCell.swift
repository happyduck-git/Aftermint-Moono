//
//  ProjectPopScoreCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/06.
//

import UIKit

final class ProjectPopScoreCell: UITableViewCell {
    // MARK: - UI Elements
    private let rankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.textColor = AftermintColor.rankGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionImageView: UIImageView = {
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
        collectionImageView.layer.cornerRadius = collectionImageView.frame.size.width / 2
    }
    
    // MARK: - Private
    private func setUI() {
        contentView.addSubview(rankImageView)
        contentView.addSubview(rankLabel)
        contentView.addSubview(collectionImageView)
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
            
            self.collectionImageView.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.collectionImageView.widthAnchor.constraint(equalTo: self.collectionImageView.heightAnchor),
            self.collectionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.collectionImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankImageView.trailingAnchor, multiplier: 2),
            
            self.nftInfoStackView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.nftInfoStackView.bottomAnchor.constraint(equalTo: self.rankLabel.bottomAnchor),
            self.nftInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.collectionImageView.trailingAnchor, multiplier: 2),
            
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
        self.collectionImageView.image = nil
        self.popScoreLabel.text = nil
        self.contentView.backgroundColor?.withAlphaComponent(1.0)
        self.contentView.backgroundColor = nil
    }
    
    // MARK: - Public
    public func configureRankScoreCell(with vm: ProjectPopScoreCellViewModel) {
        self.rankImageView.image = vm.rankImage
        self.rankLabel.text = "\(vm.rank)"
        self.collectionImageView.image = UIImage(named: vm.nftImageUrl)
        self.nftInfoStackView.topLabelText = vm.nftCollectionName
        self.nftInfoStackView.bottomLabelText = "Nfts \(vm.totalNfts) / Holders \(vm.totalHolders)"
        self.popScoreLabel.text = "\(vm.popScore)"
    }
    
    public func configureActionCountCell(with vm: ProjectPopScoreCellViewModel) {
        self.rankImageView.image = vm.rankImage
        self.rankLabel.text = "\(vm.rank)"
        self.collectionImageView.image = UIImage(named: vm.nftImageUrl)
        self.nftInfoStackView.topLabelText = vm.nftCollectionName
        self.nftInfoStackView.bottomLabelText = "Nfts \(vm.totalNfts) / Holders \(vm.totalHolders)"
        self.popScoreLabel.text = "\(vm.actioncount)"
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
