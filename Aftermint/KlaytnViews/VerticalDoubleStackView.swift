//
//  BasicStackView.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/29.
//

import UIKit

class VerticalDoubleStackView: UIStackView {
    
    var topLabelText: String = "Title" {
        didSet {
            self.topLabel.text = self.topLabelText
        }
    }
    
    var bottomLabelText: String = "" {
        didSet {
            self.bottomLabel.text = self.bottomLabelText
        }
    }
    
    var topLabelFont: UIFont? = .systemFont(ofSize: 14.0) {
        didSet {
            self.topLabel.font = self.topLabelFont
        }
    }
    
    var bottomLabelFont: UIFont? = .systemFont(ofSize: 14.0) {
        didSet {
            self.bottomLabel.font = self.bottomLabelFont
        }
    }
    
    var topLabelTextAlignment: NSTextAlignment = .center {
        didSet {
            self.topLabel.textAlignment = self.topLabelTextAlignment
        }
    }
    
    var bottomLabelTextAlignment: NSTextAlignment = .center {
        didSet {
            self.bottomLabel.textAlignment = self.bottomLabelTextAlignment
        }
    }
    
    var topLabelTextColor: UIColor = .white {
        didSet {
            self.topLabel.textColor = self.topLabelTextColor
        }
    }
    
    var bottomLabelTextColor: UIColor = .white {
        didSet {
            self.bottomLabel.textColor = self.bottomLabelTextColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
//        setLayout()
        self.axis = .vertical
        self.distribution = .fillEqually
        self.bottomLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = self.topLabelText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = self.bottomLabelText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setUI() {
        self.addArrangedSubview(topLabel)
        self.addArrangedSubview(bottomLabel)
    }
    
    private func setLayout() {
        let height = self.frame.height
        print("HEIGHT: \(height)")
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: self.topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            topLabel.heightAnchor.constraint(equalToConstant: height),
            bottomLabel.heightAnchor.constraint(equalToConstant: height),
            
            bottomLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}
