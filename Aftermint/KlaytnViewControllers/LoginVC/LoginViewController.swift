//
//  LoginViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, View {
    
    // MARK: - Dependency
    struct Dependency {
        let reactor: () -> LoginViewReactor
        let startViewControllerDependency: StartViewController.Dependency
        let mainTabBarViewControllerDependency: KlaytnTabViewController.Dependency
    }
    
    private var startVCDependency: StartViewController.Dependency
    private var mainTabBarVCDependency: KlaytnTabViewController.Dependency
    private let lottieVCDependency: LottieViewController.Dependency
    private var bookmarkVCDependency: BookmarkViewController.Dependency
    private var calendarVCDependency: CalendarViewController.Dependency
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Init
    init(reactor: LoginViewReactor,
         startVCDependency: StartViewController.Dependency,
         mainTabBarVCDependency: KlaytnTabViewController.Dependency,
         lottieVCDependency: LottieViewController.Dependency,
         bookmarkVCDependency: BookmarkViewController.Dependency,
         calendarVCDependency: CalendarViewController.Dependency
    ) {
        self.startVCDependency = startVCDependency
        self.mainTabBarVCDependency = mainTabBarVCDependency
        self.lottieVCDependency = lottieVCDependency
        self.bookmarkVCDependency = bookmarkVCDependency
        self.calendarVCDependency = calendarVCDependency
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Elements
    private let moonoLoginBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: LoginAsset.backgroundImage.rawValue)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let loginDescription: UILabel = {
        let label = UILabel()
        label.text = LoginAsset.loginDescription.rawValue
        label.sizeToFit()
        label.font = BellyGomFont.header06
        label.textColor = AftermintColor.lightGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let walletStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let favorletButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LoginAsset.favorletButton.rawValue), for: .normal)
        return button
    }()
    
    private lazy var kaikasButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LoginAsset.kaikasButton.rawValue), for: .normal)
        return button
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: .curveEaseOut) {
            self.moonoLoginBackgroundImageView.alpha = 0.0
            self.loginDescription.alpha = 0.0
            self.walletStackView.alpha = 0.0
            self.favorletButton.alpha = 0.0
            self.kaikasButton.alpha = 0.0
        }
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        view.backgroundColor = AftermintColor.backgroundBlue
        
        view.addSubview(moonoLoginBackgroundImageView)
        view.addSubview(loginDescription)
        view.addSubview(walletStackView)
        
        walletStackView.addArrangedSubview(favorletButton)
        walletStackView.addArrangedSubview(kaikasButton)
        
    }
    
    private func setLayout() {
        let viewHeight = UIScreen.main.bounds.size.height
        
        NSLayoutConstraint.activate([
            
            moonoLoginBackgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            moonoLoginBackgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moonoLoginBackgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            moonoLoginBackgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginDescription.topAnchor.constraint(equalTo: moonoLoginBackgroundImageView.bottomAnchor, constant: 59),
            loginDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            walletStackView.topAnchor.constraint(equalTo: loginDescription.bottomAnchor, constant: viewHeight / 67.66),
            walletStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walletStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(viewHeight / 8.28))
            
        ])
    }
    
    private func connectFavorletWallet() {
        /// NOTE: Temporarily push directly to KlaytnTabViewController;
        /// Will connect to FavorletWallet application later in the future
        let homeVC = KlaytnTabViewController(
            vm: mainTabBarVCDependency.leaderBoardListViewModel(),
            homeViewControllerDependency: mainTabBarVCDependency.homeViewControllerDependency,
            lottieViewControllerDependency: lottieVCDependency,
            bookmarkVCDependency: bookmarkVCDependency,
            calendarVCDependency: calendarVCDependency
        )
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    private func connectKaikasWallet() { //change the name of the function to openStartVC
        let startVC = StartViewController(
            mainTabBarViewControllerDependency: mainTabBarVCDependency,
            lottieViewControllerDependency: lottieVCDependency,
            bookmarkVCDependency: bookmarkVCDependency,
            calendarVCDependency: calendarVCDependency
        )
        navigationController?.pushViewController(startVC, animated: true)
    }

}

//MARK: - Bind Action and State

extension LoginViewController {
    
    func bind(reactor: LoginViewReactor) {
        bindAction(with: reactor)
        bindState(with: reactor)
    }
    
    private func bindState(with reactor: LoginViewReactor) {
        reactor.state.map { $0.shouldOpenFavorlet }
            .bind{ [weak self] shouldOpenFavorlet in
                if shouldOpenFavorlet {
                    self?.connectFavorletWallet()
                }
            }
            .disposed(by: disposeBag)
    
        reactor.state.map { $0.isWalletConnected }
            .bind{ [weak self] isWalletConnected in
                if isWalletConnected {
                    DispatchQueue.main.async {
                        self?.connectKaikasWallet()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.alertMessage }
            .bind { [weak self] alertMessage in
                guard let errorMessage = alertMessage else { return }
                let alert = UIAlertController(
                    title: "Wallet connection error",
                    message: "There was a problem connecting with your wallet. Please re-try wallet connection. - \(errorMessage)",
                    preferredStyle: .alert
                )
                alert.addAction(
                    UIAlertAction(title: "Confirm", style: .default)
                )
                DispatchQueue.main.async {
                    self?.present(alert, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(with reactor: LoginViewReactor) {
        favorletButton.rx.tap
            .map { Reactor.Action.connectWithFavorlet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        kaikasButton.rx.tap
            .map { Reactor.Action.connectWithKaikas }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
