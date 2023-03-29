//
//  TemplateCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/01/28.
//

import UIKit

import ReactorKit

final class LottieTemplateCell: UICollectionViewCell, View {

    var isOff: Bool = true
    var disposeBag: DisposeBag = .init()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header04
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.tag
        label.textColor = AftermintColor.titleGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        self.contentView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.emojiLabel)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.subTitleLabel)
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = AftermintColor.borderNavy.cgColor
        self.contentView.backgroundColor = AftermintColor.secondaryBackgroundNavy

    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stackView.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stackView.bottomAnchor, multiplier: 1)
        ])
    }
    
    // MARK: - Public
    let backgroundGradient: CAGradientLayer = CAGradientLayer()
    
    func configure(emojiString: String, title: String, subTitle: String) {
        self.emojiLabel.text = emojiString
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }

    func resetCell() {
        self.emojiLabel.text = nil
        self.titleLabel.text = nil
        self.subTitleLabel.text = nil
        self.backgroundGradient.removeFromSuperlayer()
    }
    
    func setGradientColor() {
        let startColor: UIColor = AftermintColor.moonoBlue
        let endColor: UIColor = AftermintColor.titleBlue
        self.backgroundGradient.makeGradient(with: [startColor.cgColor, endColor.cgColor])
        self.backgroundGradient.frame.size = contentView.frame.size
        self.contentView.layer.insertSublayer(self.backgroundGradient, at:0)
        
        self.subTitleLabel.textColor = .white
    }
    
    func removeGradientLayer() {
        backgroundGradient.removeFromSuperlayer()
        
        self.subTitleLabel.textColor = AftermintColor.titleGrey
    }
    
    // MARK: - Bind reactor
    func bind(reactor: TemplateCellReactor) {
        bindState(reactor)
        bindAction(reactor)
    }
    
    private func bindState(_ reactor: TemplateCellReactor) {

    }
    
    private func bindAction(_ reactor: TemplateCellReactor) {
        
    }
}

struct TemplateCellContent {
    let emojiString: String
    let title: String
    let subTitle: String
}
