//
//  SettingMenuBar.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/03.
//

import UIKit

protocol SettingMenuBarDelegate: AnyObject {
    func didSelectItemAt(index: Int)
}

final class SettingMenuBar: UIView {
    
    weak var delegate: SettingMenuBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
        setAlpha(for: youButton)
        buttons = [youButton, usersButton, nftsButton, projectsButton]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Elements
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var youButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.youButtonTitle.rawValue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(youButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var usersButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.usersButtonTitle.rawValue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nftsButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.nftsButtonTitle.rawValue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(nftsButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var projectsButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.projectsButtonTitle.rawValue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(projectsButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let indicator: UIView = {
        let view = UIView()
        view.backgroundColor = AftermintColor.moonoBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorTrailing: NSLayoutConstraint?
    private let leadPadding: CGFloat = 16
    private let buttonSpace: CGFloat = 6
    private var buttons: [UIButton] = []
    
    //MARK: - Public functions
    func selectItem(at index: Int) {
        animateIndicator(to: index)
    }
    
    private func animateIndicator(to index: Int) {
        var button: UIButton
        switch index {
        case 0:
            button = youButton
        case 1:
            button = usersButton
        case 2:
            button = nftsButton
        default:
            button = projectsButton
        }
        
        setAlpha(for: button)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    //MARK: - Private functions
    @objc private func youButtonTapped() {
        delegate?.didSelectItemAt(index: 0)
    }
    
    @objc private func usersButtonTapped() {
        delegate?.didSelectItemAt(index: 1)
    }
    
    @objc private func nftsButtonTapped() {
        delegate?.didSelectItemAt(index: 2)
    }
    
    @objc private func projectsButtonTapped() {
        delegate?.didSelectItemAt(index: 3)
    }
    
    private func setUI() {
        addSubview(buttonStack)
        self.buttonStack.addArrangedSubview(youButton)
        self.buttonStack.addArrangedSubview(usersButton)
        self.buttonStack.addArrangedSubview(nftsButton)
        self.buttonStack.addArrangedSubview(projectsButton)
        addSubview(indicator)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: self.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        indicatorLeading = indicator.leadingAnchor.constraint(equalTo: youButton.leadingAnchor)
        indicatorTrailing = indicator.trailingAnchor.constraint(equalTo: youButton.trailingAnchor)
        
        indicatorLeading?.isActive = true
        indicatorTrailing?.isActive = true
    }
    
    private func setAlpha(for button: UIButton) {
        youButton.alpha = 0.5
        usersButton.alpha = 0.5
        nftsButton.alpha = 0.5
        projectsButton.alpha = 0.5
        button.alpha = 1.0
    }
    
    func scrollIndicator(to contentOffset: CGPoint) {
        let index = Int(contentOffset.x / frame.width)
        let atScrollStart = Int(contentOffset.x) % Int(frame.width) == 0
        
        if atScrollStart {
            return
        }
        
        let percentScrolled: CGFloat
        switch index {
        case 1:
            percentScrolled = contentOffset.x / frame.width - 1
        case 2:
            percentScrolled = contentOffset.x / frame.width - 2
        case 3:
            percentScrolled = contentOffset.x / frame.width - 3
        default:
            percentScrolled = contentOffset.x / frame.width
        }
        
        // Determine buttons
        var fromButton: UIButton
        var toButton: UIButton
        
        switch index {
        case 3:
            fromButton = buttons[index]
            toButton = buttons[index - 1]
        default:
            fromButton = buttons[index]
            toButton = buttons[index + 1]
        }
        
        // Animate alpha of buttons
        switch index {
        case 3:
            break
        default:
            fromButton.alpha = fmax(0.5, (1 - percentScrolled))
            toButton.alpha = fmax(0.5, percentScrolled)
        }
        
        // Determine width
        let fromWidth = fromButton.frame.width
        let toWidth = toButton.frame.width
        let sectionWidth: CGFloat
        switch index {
        case 0:
            sectionWidth = leadPadding + fromWidth + buttonSpace
        default:
            sectionWidth = fromWidth + buttonSpace
        }
        
        // Normalize x scroll
        let sectionFraction = sectionWidth / frame.width
        let x = contentOffset.x * sectionFraction
        
        let buttonWidthDiff = fromWidth - toWidth
        let widthOffset = buttonWidthDiff * percentScrolled
        
        let y: CGFloat
        switch index {
        case 0:
            if x < leadPadding {
                y = x
            } else {
                y = x - (leadPadding * percentScrolled)
            }
        default:
            y = x
        }
        
        indicatorLeading?.constant = y
        
        let yTrailing: CGFloat
        switch index {
        case 0:
            yTrailing = y - widthOffset
        case 1:
            yTrailing = y - widthOffset - leadPadding
        case 2:
            yTrailing = y - widthOffset - leadPadding / 2
        case 3:
            yTrailing = y - widthOffset - leadPadding / 3
        default:
            yTrailing = y - widthOffset
        }
        
        indicatorTrailing?.constant = yTrailing
        /// for debug
//        print("\(index) percentScrolled = \(percentScrolled)")
    }
    
}
