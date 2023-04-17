//
//  StartViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/25.
//

import UIKit

class StartViewController: UIViewController {
    
    // MARK: - Dependency
    struct Dependency {
        let mainTabBarViewControllerDependency: KlaytnTabViewController.Dependency
    }
    
    private let mainTabBarViewControllerDependency: KlaytnTabViewController.Dependency
    private let lottieViewControllerDependency: LottieViewController.Dependency
    private let bookmarkVCDependency: BookmarkViewController.Dependency
    private let calendarVCDependency: CalendarViewController.Dependency
    
    // MARK: - UI Elements
    private let walletConnectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kaikas_connected_info")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titlesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let mainTitle: UILabel = {
        let label = UILabel()
        label.text = "어떤일에도 무너지지 않는 Moono Story"
        label.textColor = AftermintColor.moonoBlue
        label.font = BellyGomFont.header04
        label.textAlignment = .center
        
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.text = """
                        계속 업데이트 될,
                        NFT만으로 누릴 수 있는 Moono Benefit
                     """
        label.textAlignment = .center
        label.textColor = .white
        label.font = BellyGomFont.header05
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "start_button"), for: .normal)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(mainTabBarViewControllerDependency: KlaytnTabViewController.Dependency,
         lottieViewControllerDependency: LottieViewController.Dependency,
         bookmarkVCDependency: BookmarkViewController.Dependency,
         calendarVCDependency: CalendarViewController.Dependency
    ) {
        self.mainTabBarViewControllerDependency = mainTabBarViewControllerDependency
        self.lottieViewControllerDependency = lottieViewControllerDependency
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
        view.backgroundColor = AftermintColor.backgroundNavy
        
        setUI()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: .curveEaseOut) {
            self.walletConnectImageView.alpha = 0.0
            self.mainTitle.alpha = 0.0
            self.subTitle.alpha = 0.0
        }
    }

    // MARK: - Set UI & Layout
    private func setUI() {
        
        view.addSubview(walletConnectImageView)
        view.addSubview(titlesStackView)
        titlesStackView.addArrangedSubview(mainTitle)
        titlesStackView.addArrangedSubview(subTitle)
        view.addSubview(startButton)
        
    }
    
    private func setLayout() {
        let viewHeight = UIScreen.main.bounds.size.height
        let viewWidth = UIScreen.main.bounds.size.width
        
        NSLayoutConstraint.activate([
            
            walletConnectImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: viewHeight / 5.07),
            walletConnectImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titlesStackView.topAnchor.constraint(equalTo: walletConnectImageView.bottomAnchor),
            titlesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
            startButton.topAnchor.constraint(equalTo: titlesStackView.bottomAnchor, constant: viewHeight / 3.79),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewWidth / 18.75),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(viewWidth / 18.75)),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(viewHeight / 25.37))
            
        ])
        
        titlesStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        startButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        mainTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    // MARK: - Private Function
//    private func pushToHomeVC() {
//        let vc = KlaytnTabViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    @objc private func startButtonTapped() {
        let vc = KlaytnTabViewController(
            leaderBoardFirstViewModel: mainTabBarViewControllerDependency.leaderBoardFirstListViewModel(),
            leaderBoardSecondViewModel: mainTabBarViewControllerDependency.leaderBoardSecondListViewModel(),
            homeViewControllerDependency: mainTabBarViewControllerDependency.homeViewControllerDependency,
            lottieViewControllerDependency: lottieViewControllerDependency,
            bookmarkVCDependency: bookmarkVCDependency,
            calendarVCDependency: calendarVCDependency
        )
//        let vc = KlaytnTabViewController(vm: mainTabBarViewControllerDependency.leaderBoardListViewModel())
        navigationController?.pushViewController(vc, animated: true)
    }
}


