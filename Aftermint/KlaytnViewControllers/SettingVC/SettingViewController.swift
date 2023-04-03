//
//  SettingsViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/20.
//

import UIKit

final class SettingViewController: UIViewController {
    
    var vm: SettingViewControllerViewModel
    
    private let gameLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: SettingAsset.gameLogo.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dashBoardStackView: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelFont = BellyGomFont.header04
        stack.topLabelText = SettingAsset.dashBoardTitle.rawValue
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    //MARK: - Initializer
    init(
        ofCollectionType collectionType: CollectionType,
        vm: SettingViewControllerViewModel
    ) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        dashBoardStackView.bottomLabelText = collectionType.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: - Set UI & Layout
    private func setUI() {
        view.addSubview(gameLogoImageView)
        view.addSubview(dashBoardStackView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.gameLogoImageView.centerYAnchor.constraint(equalTo: self.dashBoardStackView.centerYAnchor),
            self.gameLogoImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            self.dashBoardStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            self.dashBoardStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.gameLogoImageView.trailingAnchor, multiplier: 2),
        ])
    }
}
