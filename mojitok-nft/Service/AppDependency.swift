//
//  AppDependency.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/08.
//

import Foundation

struct AppDependency {
    let homeViewReactor: HomeViewReactor2
    let loginViewControllerDependency: LoginViewController.Dependency
    let startViewControllerDependency: StartViewController.Dependency
    let klaytnTabBarViewControllerDependency: KlaytnTabViewController.Dependency
    let lottieViewControllerDependency: LottieViewController.Dependency
    let bookmarkViewControllerDependency: BookmarkViewController.Dependency
    let calendarViewControllerDependency: CalendarViewController.Dependency
    
    static func resolve() -> AppDependency {
        let templateRepository = TemplateRepository.shared
        let walletRepository = WalletRepository.shared
        let nftRepository = NFTRepository.shared
        let twitterService = TwitterService.shared
        let userService = UserService.shared
        
        /// Currently not in use
        /*
         let templateShareViewReactorFactory = TemplateShareViewReactor.Factory(dependency: .init(twitterService: twitterService, userService: userService))
         
         let templateCreateViewReactorFactory = TemplateCreateViewReactor.Factory(dependency: .init(templateShareViewReactorFactory: templateShareViewReactorFactory, templateRepository: templateRepository))
         
         let homeViewReactor = HomeViewReactor(dependency: .init(templateCreateViewReactorFactory: templateCreateViewReactorFactory, walletRepository: walletRepository, nftRepository: nftRepository), payload: .init())
         */
        
        let templateShareViewReactorFactory2 = TemplateShareViewReactor2.Factory(
            dependency: .init(
                twitterService: twitterService,
                userService: userService
            )
        )
        
        let templateCreateViewReactorFactory2 = TemplateCreateViewReactor2.Factory(
            dependency: .init(
                templateShareViewReactorFactory: templateShareViewReactorFactory2,
                templateRepository: templateRepository
            )
        )
        
        let lottieViewReactorFactory = LottieViewReactor.Factory(
            dependency: .init(
                templateRepository: templateRepository
            )
        )
        
        let homeViewReactor2 = HomeViewReactor2(
            dependency: .init(
                templateCreateViewReactorFactory: templateCreateViewReactorFactory2,
                lottieViewReactorFactory: lottieViewReactorFactory,
                walletRepository: walletRepository,
                nftRepository: nftRepository
            ),
            payload: .init()
        )
        
        let lottieViewControllerDependency: LottieViewController.Dependency =
            .init(
                factory: lottieViewReactorFactory
            )
        
        let homeViewControllerDependency: KlaytnHomeViewController.Dependency =
            .init(
                homeViewReactor: homeViewReactor2,
                lottieViewControllerDependency: lottieViewControllerDependency
            )
        
        let benefitTabBottomVC: BenefitTabBottomViewController = BenefitTabBottomViewController()
        
        let bookmarkVCDependency: BookmarkViewController.Dependency =
            .init(
                reactor: { BookmarkViewReactor() },
                bottomSheetVC: benefitTabBottomVC
            )
        
        let calendarVCDependency: CalendarViewController.Dependency =
            .init(
                reactor: { CalendarViewReactor() },
                bottomSheetVC: benefitTabBottomVC
            )
        
        let mainTabBarControllerDependency: KlaytnTabViewController.Dependency =
            .init(
                leaderBoardListViewModel: { LeaderBoardTableViewCellListViewModel() },
                homeViewControllerDependency: homeViewControllerDependency,
                bookmarkVCDependency: bookmarkVCDependency,
                calendarVCDependency: calendarVCDependency
            )
        
        let startViewControllerDependency: StartViewController.Dependency =
            .init(
                mainTabBarViewControllerDependency: mainTabBarControllerDependency
            )
        
        let loginViewControllerDependency: LoginViewController.Dependency =
            .init(
                reactor: { LoginViewReactor() },
                startViewControllerDependency: startViewControllerDependency,
                mainTabBarViewControllerDependency: mainTabBarControllerDependency
            )
        
        return .init(
            homeViewReactor: homeViewReactor2,
            loginViewControllerDependency: loginViewControllerDependency,
            startViewControllerDependency: startViewControllerDependency,
            klaytnTabBarViewControllerDependency: mainTabBarControllerDependency,
            lottieViewControllerDependency: lottieViewControllerDependency,
            bookmarkViewControllerDependency: bookmarkVCDependency,
            calendarViewControllerDependency: calendarVCDependency
        )
    }
}

