//
//  KlaytnHomeViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/20.
//

import UIKit

class KlaytnHomeViewController: UIViewController {
    
    struct Dependency {
        let homeViewReactor: HomeViewReactor2
        let lottieViewControllerDependency: LottieViewController.Dependency
    }
    
    var reactor: HomeViewReactor2
    var lottieVCDependency: LottieViewController.Dependency
    
    //MARK: - UIElements
    
    private let welcomeUpperView: WelcomeUpperView = {
        let view = WelcomeUpperView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftCardView: NFTCardView = {
        let vm = NFTCardViewModel()
        let cardView = NFTCardView(vm: vm)
        cardView.accessibilityIdentifier = "nftCardView"
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    private let collectNewNFTButton: CollectNewNFTButton = {
        let button = CollectNewNFTButton()
        button.backgroundColor = AftermintColor.secondaryBackgroundNavy
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init(reactor: HomeViewReactor2,
         lottieViewControllerDependency: LottieViewController.Dependency) {
        self.reactor = reactor
        self.lottieVCDependency = lottieViewControllerDependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nftCardView.delegate = self
        
        view.addSubview(welcomeUpperView)
        view.addSubview(nftCardView)
        view.addSubview(collectNewNFTButton)
        layout()
        
        //TEMP
        welcomeUpperView.usernameLabel.text = KasWalletRepository.shared.getUsername()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("KHVC will appear")
        nftCardView.prefetcher.isPaused = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("KHVC will disappear")
        nftCardView.prefetcher.isPaused = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Set up UI & Layout
    
    private func layout() {
        let tabBarHeight = view.frame.size.height / 8.2
        let viewFrameHeight = view.frame.size.height
        let viewFrameWidth = view.frame.size.width
        
        NSLayoutConstraint.activate([
            
            welcomeUpperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: viewFrameHeight / 32.48),
            welcomeUpperView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: viewFrameWidth / 18.7),
            welcomeUpperView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -(viewFrameWidth / 20.7)),
            welcomeUpperView.heightAnchor.constraint(equalToConstant: viewFrameHeight / 10.1),
            
            nftCardView.topAnchor.constraint(equalTo: welcomeUpperView.bottomAnchor, constant: viewFrameHeight / 29),
            nftCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewFrameWidth / 18.7),
            nftCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectNewNFTButton.topAnchor.constraint(equalTo: nftCardView.bottomAnchor, constant: viewFrameHeight / 35.0),
            collectNewNFTButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewFrameWidth / 18.7),
            collectNewNFTButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(viewFrameWidth / 18.7)),
            collectNewNFTButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -((viewFrameHeight / 33.8)+tabBarHeight))

            
        ])
        welcomeUpperView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        nftCardView.setContentHuggingPriority(.defaultLow, for: .vertical)
        collectNewNFTButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}

extension KlaytnHomeViewController: NFTCardViewDelegate {

    func didTapTemplateButton() {
        
        let templateVC: LottieViewController = LottieViewController(reactor: makeMockMoonoReactorByGall3ry3())
        navigationController?.pushViewController(templateVC, animated: true)
        
    }
    
}

// MARK: Extension for Lottie player of Gall3ry3
extension KlaytnHomeViewController {
 
    private func makeReactorByGall3ry3(nft: MoonoNft) -> LottieViewReactor {
//        let appDependency = AppDependency.resolve()
//        return appDependency.homeViewReactor.dependency
//            .lottieViewReactorFactory.create(
//                payload: .init(nft: makeOpenSeaNftByGall3ry3(moonoNft: nft), format: .video)
//            )
        
        return reactor.dependency.lottieViewReactorFactory.create(payload: .init(nft: makeOpenSeaNftByGall3ry3(moonoNft: nft), format: .video))
        
    }
    
    private func makeMockMoonoReactorByGall3ry3() -> LottieViewReactor {
//        let appDependency = AppDependency.resolve()
//        return appDependency.homeViewReactor.dependency
//            .lottieViewReactorFactory.create(
//                payload: .init(nft: makeMockOpenSeaMoonoNftByGall3ry3(), format: .video)
//            )
        return reactor.dependency.lottieViewReactorFactory.create(payload: .init(nft: makeMockOpenSeaMoonoNftByGall3ry3(), format: .video))
    }
    
    private func makeOpenSeaNftByGall3ry3(moonoNft: MoonoNft) -> OpenSeaNFT {
        let collectionTitle = "Moono Week"
        let collectionProfileImageUrl = "https://i.seadn.io/gae/cB8JeJwP76w_GGSvQe-WpwfzA31aQZF2fVLA0FmvcsrISfe9e7HDQ_DE9QhilMaCW88vFo_EfBA6ItrNrUOxmbWlbq6suY0v8Sln?auto=format&w=256"
        let nftOwnerAddress = "0x3961eA20e28A30bCB25E130bec3378d0C248030C"
        
        let openSeaPaymentToken = OpenSeaPaymentToken(
            eth_price: "1.000000000000000"
        )
        let openSeaNftLastSale = OpenSeaNFTLastSale(
            total_price: "31000000000000000",
            payment_token: openSeaPaymentToken
        )
        let openSeaNftCollection = OpenSearNFTCollection(
            name: collectionTitle,
            image_url: collectionProfileImageUrl,
            slug: "MOONO"
        )
        let openSeaCreator = OpenSeaCreator(
            user: OpenseaUser(username: collectionTitle)
        )
        let openSeaNftOwner = OpenSeaNFTOwner(
            user: OpenSeaNFTOwner.OpenSeaNFTUser(username: nftOwnerAddress),
            profile_img_url: "https://storage.googleapis.com/opensea-static/opensea-profile/11.png",
            address: nftOwnerAddress
        )
        
        return OpenSeaNFT(
            id: Int(moonoNft.tokenId) ?? -1,
            owner: openSeaNftOwner,
            name: moonoNft.name,
            permalink: "https://opensea.io/assets/klaytn/0x29421a3c92075348fcbcb04de965e802ed187302/\(moonoNft.tokenIdInteger)",
            sell_orders: nil,
            last_sale: openSeaNftLastSale,
            collection: openSeaNftCollection,
            creator: openSeaCreator,
            price: nil,
            tokenID: moonoNft.tokenId,
            description: moonoNft.description,
            imageURLString: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23\(moonoNft.tokenIdInteger).jpeg?alt=media"
        )
    }
    
    private func makeMockOpenSeaMoonoNftByGall3ry3() -> OpenSeaNFT {
        let openSeaPaymentToken = OpenSeaPaymentToken(
            eth_price: "1.000000000000000"
        )
        let openSeaNftLastSale = OpenSeaNFTLastSale(
            total_price: "31000000000000000",
            payment_token: openSeaPaymentToken
        )
        let openSeaNftCollection = OpenSearNFTCollection(
            name: "Moono Week",
            image_url: "https://i.seadn.io/gae/cB8JeJwP76w_GGSvQe-WpwfzA31aQZF2fVLA0FmvcsrISfe9e7HDQ_DE9QhilMaCW88vFo_EfBA6ItrNrUOxmbWlbq6suY0v8Sln?auto=format&w=256",
            slug: "MOONO"
        )
        let openSeaCreator = OpenSeaCreator(
            user: OpenseaUser(username: "2B14DA")
        )
        return OpenSeaNFT(
            id: 994262845,
            owner: nil,
            name: "Moono#1183",
            permalink: "https://opensea.io/assets/klaytn/0x29421a3c92075348fcbcb04de965e802ed187302/1183",
            sell_orders: nil,
            last_sale: openSeaNftLastSale,
            collection: openSeaNftCollection,
            creator: openSeaCreator,
            price: nil,
            tokenID: "1183",
            description: "Meet the unique generative NFT art of Moono and join the exclusive membership!",
            imageURLString: "https://i.seadn.io/gae/Aa6TaAL9HxsTUVCbOfBXKqLzM5dEGQz4Oioo7PBRM4aUmBy5Jxzel9doCM8eGH5NRfH_taxqnFYUK05QtaA-tqNGOVSrApvSRI6A?auto=format&w=1000"
        )
    }
}
