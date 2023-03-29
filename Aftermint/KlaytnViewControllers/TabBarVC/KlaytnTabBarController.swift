//
//  KlaytnTabBarController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/20.
//

import UIKit

class KlaytnTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    
    struct Dependency {
        let leaderBoardListViewModel: () -> LeaderBoardTableViewCellListViewModel
        let homeViewControllerDependency: KlaytnHomeViewController.Dependency
//        let lottieVCDependency: LottieViewController.Dependency
        let bookmarkVCDependency: BookmarkViewController.Dependency
        let calendarVCDependency: CalendarViewController.Dependency
    }
    
    
    private let leaderBoardListViewModel: LeaderBoardTableViewCellListViewModel
    private let homeViewControllerDependency: KlaytnHomeViewController.Dependency
    private let lottieVCDependency: LottieViewController.Dependency
    private let bookmarkVCDependency: BookmarkViewController.Dependency
    private let calendarVCDependency: CalendarViewController.Dependency
    
    // MARK: - Init
    init(vm: LeaderBoardTableViewCellListViewModel,
         homeViewControllerDependency: KlaytnHomeViewController.Dependency,
         lottieViewControllerDependency: LottieViewController.Dependency,
         bookmarkVCDependency: BookmarkViewController.Dependency,
         calendarVCDependency: CalendarViewController.Dependency
    ) {
        self.leaderBoardListViewModel = vm
        self.homeViewControllerDependency = homeViewControllerDependency
        self.lottieVCDependency = lottieViewControllerDependency
        self.bookmarkVCDependency = bookmarkVCDependency
        self.calendarVCDependency = calendarVCDependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTabBarItems()
        changeTabBarRadius()
        tabBar.backgroundColor = AftermintColor.tabBarNavy
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.changeTabBarHeight()
        setUpTabBarShadow()
    }
    
    //TabBar Items
    private func setTabBarItems() {
        tabBar.backgroundColor = .white
        
        let klaytnHomeVC = KlaytnHomeViewController(reactor: homeViewControllerDependency.homeViewReactor,
                                                    lottieViewControllerDependency: lottieVCDependency)
        klaytnHomeVC.tabBarItem.image = UIImage(named: TabBarAsset.mainOff.rawValue)?.withRenderingMode(.alwaysOriginal)
        klaytnHomeVC.tabBarItem.selectedImage = UIImage(named: TabBarAsset.mainOn.rawValue)?.withRenderingMode(.alwaysOriginal)
        
        let benefitVC = BenefitViewController(bookmarkVCDependency: bookmarkVCDependency,
                                              calendarVCDependency: calendarVCDependency)
        let benefitNaviVC = UINavigationController(rootViewController: benefitVC)
        benefitNaviVC.tabBarItem.image = UIImage(named: TabBarAsset.giftOff.rawValue)?.withRenderingMode(.alwaysOriginal)
        benefitNaviVC.tabBarItem.selectedImage = UIImage(named: TabBarAsset.giftOn.rawValue)?.withRenderingMode(.alwaysOriginal)
        
        let marketVC = MarketViewController()
        marketVC.tabBarItem.image = UIImage(named: TabBarAsset.marketOff.rawValue)?.withRenderingMode(.alwaysOriginal)
        marketVC.tabBarItem.selectedImage = UIImage(named: TabBarAsset.marketOn.rawValue)?.withRenderingMode(.alwaysOriginal)

        let gameVC = GameViewController(leaderBoardListViewModel: self.leaderBoardListViewModel)
        gameVC.tabBarItem.image = UIImage(named: TabBarAsset.gameOff.rawValue)?.withRenderingMode(.alwaysOriginal)
        gameVC.tabBarItem.selectedImage = UIImage(named: TabBarAsset.gameOn.rawValue)?.withRenderingMode(.alwaysOriginal)
        
        let settingVC = SettingViewController()
        settingVC.tabBarItem.image = UIImage(named: TabBarAsset.settingOff.rawValue)?.withRenderingMode(.alwaysOriginal)
        settingVC.tabBarItem.selectedImage = UIImage(named: TabBarAsset.settingOn.rawValue)?.withRenderingMode(.alwaysOriginal)

        self.viewControllers = [klaytnHomeVC, benefitNaviVC, marketVC, gameVC, settingVC]

    }
    
    private func changeTabBarHeight() {
        var tabFrame = tabBar.frame
        let tabBarHeight = view.frame.size.height / 8.2
        tabFrame.size.height = tabBarHeight
        tabFrame.origin.y = view.frame.height - tabBarHeight
        tabBar.frame = tabFrame
    }
    
    private func changeTabBarRadius() {
        tabBar.isTranslucent = true
        tabBar.layer.cornerRadius = 16
        tabBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
        
    private func setUpTabBarShadow() {
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor.white.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBar.layer.shadowRadius = 16
    }
    
}

