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
    
    //MARK: - Button functions
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
    
}
