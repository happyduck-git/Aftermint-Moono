//
//  NftNameAndButtonView.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/01/21.
//

import UIKit

protocol NftTraitViewDelegate: AnyObject {
    func didTapTemplateButton()
}

class NftTraitView: UIView {
    
    weak var delegate: NftTraitViewDelegate?
        
    //MARK: - UI elements
    
    // Nft name and level
    private let nameAndLevelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "level_belly")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nftName: UILabel = {
        let label = UILabel()
        label.text = "Bellygom #1920"
        label.font = BellyGomFont.header04
        label.adjustsFontSizeToFitWidth = true
        label.textColor = AftermintColor.bellyTitleGrey
        return label
    }()
    
    lazy var cardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "front_deco_button")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(presentTemplateVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //nft traits
    private let withMeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let withMeLabel: UILabel = {
        let label = UILabel()
        label.text = "With me"
        label.adjustsFontSizeToFitWidth = true
        label.font = BellyGomFont.header06
        label.textColor = AftermintColor.traitGrey
        return label
    }()
    
    private let withMeNumLabel: UILabel = {
        let label = UILabel()
        label.text = "D+ 291"
        label.font = BellyGomFont.header05
        label.textColor = AftermintColor.titleBlue
        return label
    }()
    
    private let verticalLine1: UIView = {
        let view = UIView()
        view.backgroundColor = AftermintColor.backgroundGrey
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Change cardButtonImage
    /// - Parameter image: Desired card button image
    public func changeCardButtonImage(with image: UIImage?) {
        self.cardButton.imageView?.image = image
    }
    
    
    //MARK: - Set up UI and Layout
    private func setUI() {
        
        self.addSubview(nameAndLevelStack)
        self.addSubview(cardButton)
        nameAndLevelStack.addArrangedSubview(levelImageView)
        nameAndLevelStack.addArrangedSubview(nftName)

        self.addSubview(withMeStackView)
        withMeStackView.addArrangedSubview(withMeLabel)
        withMeStackView.addArrangedSubview(withMeNumLabel)
        
        self.addSubview(verticalLine1)
        
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            
            nameAndLevelStack.topAnchor.constraint(equalTo: self.topAnchor),
            nameAndLevelStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            cardButton.topAnchor.constraint(equalTo: nameAndLevelStack.topAnchor),
            cardButton.leadingAnchor.constraint(equalToSystemSpacingAfter: nameAndLevelStack.trailingAnchor, multiplier: 2),
            cardButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardButton.bottomAnchor.constraint(equalTo: nameAndLevelStack.bottomAnchor),

            withMeStackView.topAnchor.constraint(equalTo: nameAndLevelStack.bottomAnchor),
            withMeStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            withMeStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            verticalLine1.topAnchor.constraint(equalToSystemSpacingBelow: nameAndLevelStack.bottomAnchor, multiplier: 1),
            verticalLine1.widthAnchor.constraint(equalToConstant: 1),
            verticalLine1.leadingAnchor.constraint(equalToSystemSpacingAfter: withMeStackView.trailingAnchor, multiplier: 1),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: verticalLine1.bottomAnchor, multiplier: 1)
        ])
        
        withMeLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        verticalLine1.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
    }
    
    @objc private func presentTemplateVC() {
        delegate?.didTapTemplateButton()
    }
    
    public func configure(name: String?,
                          updatedAt: Int64?
                       ) {
        
        self.nftName.text = name ?? "N/A"
        self.withMeNumLabel.text = "D+ " + String(calculateNumberOfDays(since: updatedAt ?? 0))
        self.levelImageView.image = UIImage(named: "level_image")
        
    }
    
    @objc func changeCardButtonImage(notification: NSNotification) {
        
        let isBack: Bool = notification.object as! Bool
        print("\(#function) ---- \(isBack)")
        self.cardButton.imageView?.image = isBack ? UIImage(named: "back_opensea_button") : UIImage(named: "front_deco_button")
    }
    
    
    private func calculateNumberOfDays(since endDate: Int64) -> Int {
        let currentDate: Int = Int(Date().timeIntervalSince1970)
        let numberOfDays: Int = (currentDate - Int(endDate)) / 3600 / 24
        return numberOfDays
    }
}
