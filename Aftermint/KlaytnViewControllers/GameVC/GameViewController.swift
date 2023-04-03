//
//  GameViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/09.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    
    // MARK: - Constants
    private var nickNameLabelText: String = "월요 병아리"
    private var initialTouchScore: Int = 0
    
    // MARK: - Dependency
    private var leaderBoardListViewModel: LeaderBoardTableViewCellListViewModel
    private var scene: MoonoGameScene?
    
    private var touchCount: Int64 = 0
    private var touchCountToShow: Int64 = 0 {
        didSet {
            self.touchCountLabel.text = "\(self.touchCountToShow)"
        }
    }
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemFill
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor(ciColor: .white).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let userInfoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let walletAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = BellyGomFont.header05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = self.nickNameLabelText
        label.textColor = .white
        label.font = BellyGomFont.header05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popRankStack: BasicStackView = {
        let stack = BasicStackView()
        stack.topLabelText = "Pop Rank"
        stack.topLabelFont = BellyGomFont.header05
        stack.bottomLabelText = "12"
        stack.bottomLabelFont = BellyGomFont.header04
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let popScoreStack: BasicStackView = {
        let stack = BasicStackView()
        stack.topLabelText = "Pop Score"
        stack.topLabelFont = BellyGomFont.header05
        stack.bottomLabelText = "358,732"
        stack.bottomLabelFont = BellyGomFont.header04
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftsStack: BasicStackView = {
        let stack = BasicStackView()
        stack.topLabelText = "NFTs"
        stack.topLabelFont = BellyGomFont.header05
        stack.bottomLabelText = "17"
        stack.bottomLabelFont = BellyGomFont.header05
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionCountStack: BasicStackView = {
        let stack = BasicStackView()
        stack.topLabelText = "Action Count"
        stack.topLabelFont = BellyGomFont.header05
        stack.bottomLabelFont = BellyGomFont.header05
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    //Change this to Pop Score Label
    private lazy var touchCountLabel: UILabel = {
        let label = UILabel()
        label.text = "\(self.initialTouchScore)"
        label.textColor = .white
        label.font = BellyGomFont.header03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var gameSKView: SKView = {
        let view = SKView()
        view.backgroundColor = AftermintColor.secondaryBackgroundNavy
        view.showsFPS = false
        view.showsNodeCount = false
        view.ignoresSiblingOrder = true
        return view
    }()
    
    private lazy var bottomSheetView: BottomSheetView = {
        let bottomSheet = BottomSheetView(frame: .zero, vm: leaderBoardListViewModel)
        bottomSheet.bottomSheetColor = AftermintColor.backgroundNavy
        bottomSheet.barViewColor = .darkGray
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        return bottomSheet
    }()
    
    private var tempTouchCountList: [String: Int64] {
        print("\(self.bottomSheetView.tempTouchCountList)")
        return self.bottomSheetView.tempTouchCountList
    }
    
    // MARK: - Init
    init(leaderBoardListViewModel: LeaderBoardTableViewCellListViewModel) {
        self.leaderBoardListViewModel = leaderBoardListViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        setGameScene()

//        configureProfileInfo()
        self.bottomSheetView.bottomSheetDelegate = self
        //Correct loction to call this?
//        getCurrentUserViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarSetup()
    }
    
//    var timer: Timer = Timer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        ///Set Timer scheduler to repeat certain action
//        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//            print("Accumulated touchCount: \(self.touchCount)")
//            self.leaderBoardListViewModel.increaseTouchCount(self.touchCount)
//        }
    }
    
    override func viewWillLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ///Disable the timer when the view disappeared
//        timer.invalidate()
    }
    private func navigationBarSetup() {
        
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.navigationItem.title = ""
        
        let logo = UIImage(named: GameAsset.gameVCLogo.rawValue)
        let myImageView = UIImageView(image: logo)
        let leftBar: UIBarButtonItem = UIBarButtonItem(customView: myImageView)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftBar
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        view.backgroundColor = AftermintColor.backgroundLightBlue
        view.addSubview(gameSKView)
        view.addSubview(userImageView)
        view.addSubview(userInfoStackView)
        view.addSubview(bottomSheetView)
        view.addSubview(popRankStack)
        view.addSubview(popScoreStack)
        view.addSubview(nftsStack)
        view.addSubview(actionCountStack)
        
        userInfoStackView.addArrangedSubview(walletAddressLabel)
        userInfoStackView.addArrangedSubview(nickNameLabel)
    }
    
    private func setLayout() {
        let viewHeight = view.frame.size.height
        gameSKView.frame = view.bounds
        NSLayoutConstraint.activate([
            self.userImageView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.userImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            self.userImageView.heightAnchor.constraint(equalToConstant: viewHeight / 14),
            self.userImageView.widthAnchor.constraint(equalTo: self.userImageView.heightAnchor),
            
            self.userInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userImageView.trailingAnchor, multiplier: 1),
            self.userInfoStackView.centerYAnchor.constraint(equalTo: self.userImageView.centerYAnchor),
            
            self.popRankStack.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0),
            self.popRankStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userInfoStackView.trailingAnchor, multiplier: 1),
            self.popScoreStack.topAnchor.constraint(equalTo: self.popRankStack.topAnchor),
            self.popScoreStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.popRankStack.trailingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreStack.trailingAnchor, multiplier: 1),
            
            self.nftsStack.topAnchor.constraint(equalToSystemSpacingBelow: self.popRankStack.bottomAnchor, multiplier: 1),
            self.nftsStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userInfoStackView.trailingAnchor, multiplier: 1),
            self.actionCountStack.topAnchor.constraint(equalTo: self.nftsStack.topAnchor),
            self.actionCountStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftsStack.trailingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.actionCountStack.trailingAnchor, multiplier: 1),
            
            
            self.bottomSheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Get viewModel for current user information
    private func getCurrentUserViewModel() {
        let currentUserViewModel = self.leaderBoardListViewModel.currentUserViewModel()
        DispatchQueue.main.async {
            /// User information part
            self.userImageView.image = UIImage(named: currentUserViewModel?.userProfileImage ?? "rebecca")
            self.walletAddressLabel.text = currentUserViewModel?.topLabelText.cutOfRange(length: 10)
            self.nickNameLabel.text = currentUserViewModel?.bottomLabelText
            /// Scoreboard part
            self.popScoreStack.bottomLabelText = String(describing: currentUserViewModel?.popScore ?? 0)
            self.actionCountStack.bottomLabelText = String(describing: currentUserViewModel?.actionCount ?? 0)
        }
    }
    
}

// MARK: - Set GameScene
extension GameViewController {
    
    private func setGameScene() {
        let width = view.frame.size.width
        let height = view.frame.size.height
        scene = MoonoGameScene(size: CGSize(width: width, height: height))
        guard let scene = scene else { return }
        scene.gameSceneDelegate = self
        scene.backgroundColor = AftermintColor.backgroundLightBlue
        scene.scaleMode = .aspectFit
        gameSKView.presentScene(scene)
    }
    
//    private func configureProfileInfo() {
//        let card = leaderBoardListViewModel.randomMoonoData
//        let url = URL(string: card.imageUrl)
//        NukeImageLoader.loadImageUsingNuke(url: url) { image in
//            self.userImageView.image = image
//        }
//
//        let nftName = card.tokenId.replacingOccurrences(of: "___", with: " #")
//        self.walletAddressLabel.text = "\(nftName) "
//    }
}

extension GameViewController: MoonoGameSceneDelegate {
    
    func didReceiveTouchCount(number: Int64) {
        print("Touch received: \(number)")
        self.touchCountToShow += number
        self.touchCount += number
        
        let ownerAddress: String = KasWalletRepository.shared.getCurrentWallet()
        let mockUserData: AfterMintUserTest = MoonoMockUserData().getOneUserData()
        let mockCardData: Card = MoonoMockMetaData().getOneMockData()
        
        self.leaderBoardListViewModel.saveCountNumber(collectionAddress: K.ContractAddress.moono,
                                                      collectionImageUrl: "fake url",
                                                      popScore: touchCount * Int64(mockUserData.totalNfts),
                                                      actionCount: touchCount,
                                                      ownerAddress: mockUserData.address,
                                                      ownerProfileImage: mockUserData.imageUrl,
                                                      nftImageUrl: mockCardData.imageUrl,
                                                      nftTokenId: mockCardData.tokenId,
                                                      totalNfts: mockUserData.totalNfts,
                                                      ofCollectionType: .moono)
    }

}

//TODO: Export this logic to GameVCViewModel
extension GameViewController: BottomSheetViewDelegate {
    
    ///Get notified when the data saved to firestore
    func dataFetched() {
        self.touchCount = 0
        self.getCurrentUserViewModel()
    } 

}
