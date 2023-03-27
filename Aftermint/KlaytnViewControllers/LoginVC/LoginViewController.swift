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

class LoginViewController: UIViewController, View, Coordinating {
    
    // MARK: - Dependency
    let startVCDependency: StartViewController.Dependency
    
    var coordinator: Coordinator?
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Init
    init(reactor: LoginViewReactor,
         startVCDependency: StartViewController.Dependency) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.startVCDependency = startVCDependency
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Elements
    private let moonoLoginBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "moono_login_image")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let loginDescription: UILabel = {
        let label = UILabel()
        label.text = "멤버십 서비스 이용을 위해 NFT 지갑을 연결해주세요."
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
        button.setImage(UIImage(named: "favorletbutton"), for: .normal)
        return button
    }()
    
    private lazy var kaikasButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kaikasbutton"), for: .normal)
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
        let vm = LeaderBoardTableViewCellListViewModel() //Need adopt appDependency
        let homeVC = KlaytnTabViewController(vm: mainTabBarViewControllerDependency.leaderBoardListViewModel())
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    private func connectKaikasWallet() { //change the name of the function to openStartVC
        let startVC = StartViewController(mainTabBarViewControllerDependency: <#T##KlaytnTabViewController.Dependency#>)
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
