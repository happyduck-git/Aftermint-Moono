//
//  NftCardCellBack.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/01/22.
//

import UIKit

protocol NftCardCellDelegate: AnyObject {
    func didTapTemplateButton()
}

class NftCardCell: UICollectionViewCell {
    
    weak var delegate: NftCardCellDelegate?

    //MARK: - UI Elements
    
    internal let cardBackView: NftCardCellBackView = {
        let view = NftCardCellBackView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal let cardFrontView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bellygom_test")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20.0
        imageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let traitView: NftTraitView = {
        let view = NftTraitView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var traitButtonImage: UIImage? {
        if !cardFrontView.isHidden {
            return UIImage(named: "front_deco_button")
        } else {
            return UIImage(named: "back_opensea_button")
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setUI()
        setLayout()

        traitView.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - Set UI and Layout
    
    private func setUI() {
        
        self.addSubview(cardBackView)
        self.addSubview(cardFrontView)
        
        self.addSubview(traitView)
        
    }
    
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            
            cardBackView.topAnchor.constraint(equalTo: self.topAnchor),
            cardBackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardBackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardBackView.heightAnchor.constraint(equalToConstant: self.frame.size.width),
            
            cardFrontView.topAnchor.constraint(equalTo: self.topAnchor),
            cardFrontView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardFrontView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardFrontView.heightAnchor.constraint(equalToConstant: self.frame.size.width),
            
            traitView.topAnchor.constraint(equalTo: cardBackView.bottomAnchor, constant: 10),
            traitView.topAnchor.constraint(equalTo: cardFrontView.bottomAnchor, constant: 10),
            traitView.leadingAnchor.constraint(equalToSystemSpacingAfter: cardBackView.leadingAnchor, multiplier: 2),
            cardBackView.trailingAnchor.constraint(equalToSystemSpacingAfter: traitView.trailingAnchor, multiplier: 2),
            traitView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
            
        ])
        
    }
    
    //MARK: - Configuration
    public func configure(with viewModel: NftCardCellViewModel) {
        
        //TODO: PropertyView, TraitView, CardFrontView => ViewModel 만들기
        
        self.cardBackView.propertyView.configure(accDesc: viewModel.accDesc,
                                                 backgroundDesc: viewModel.backgroundDesc,
                                                 bodyDesc: viewModel.bodyDesc,
                                                 dayDesc: viewModel.dayDesc,
                                                 effectDesc: viewModel.effectDesc,
                                                 expressionDesc: viewModel.expressionDesc,
                                                 hairDesc: viewModel.hairDesc)
        
        
        self.traitView.configure(name: viewModel.name,
                                 updatedAt: viewModel.updatedAt)
        
        guard let url = URL(string: viewModel.imageUrl) else { return }
        NukeImageLoader.loadImageUsingNuke(url: url) { image in
                DispatchQueue.main.async {
                    self.cardFrontView.image = image
                }
        }
    }
    
    
    internal func selectViewToHide(cardBackView hideCardBackView: Bool, nftImageView hideNftImageView: Bool) {
        self.cardBackView.isHidden = hideCardBackView
        self.cardFrontView.isHidden = hideNftImageView
        self.traitView.changeCardButtonImage(with: traitButtonImage)
    }
    
    internal func resetCell() {
        self.cardBackView.propertyView.configure(accDesc: nil,
                                                 backgroundDesc: nil,
                                                 bodyDesc: nil,
                                                 dayDesc: nil,
                                                 effectDesc: nil,
                                                 expressionDesc: nil,
                                                 hairDesc: nil)
        self.traitView.configure(name: nil,
                                 updatedAt: nil)
        self.traitView.cardButton.imageView?.image = UIImage(named: "front_deco_button")
        self.cardFrontView.image = nil
        
        self.cardFrontView.isHidden = false
        self.cardBackView.isHidden = true
        
    }
    
}

extension NftCardCell: NftTraitViewDelegate {
    
    func didTapTemplateButton() {
        delegate?.didTapTemplateButton()
    }
    
}
