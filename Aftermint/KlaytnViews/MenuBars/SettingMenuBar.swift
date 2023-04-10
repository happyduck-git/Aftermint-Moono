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
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(youButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var usersButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.usersButtonTitle.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nftsButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.nftsButtonTitle.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(nftsButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var projectsButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingAsset.projectsButtonTitle.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(projectsButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: self.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setAlpha(for button: UIButton) {
        youButton.alpha = 0.5
        usersButton.alpha = 0.5
        nftsButton.alpha = 0.5
        projectsButton.alpha = 0.5
        button.alpha = 1.0
    }
}
