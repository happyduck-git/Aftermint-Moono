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
    private var nickNameLabelText: String = ""
    private var initialTouchScore: Int = 0
    private var mockUser: AfterMintUser = MoonoMockUserData().getOneUserData()
    
    // MARK: - Dependency
    private var bottomSheetVM: BottomSheetViewModel
    private var gameVM: GameViewViewModel = GameViewViewModel()
    private var scene: MoonoGameScene?
    
    //MARK: - Game score data variables
    var timer: Timer = Timer()
    /// TEMP ========================
    var tempPopScore: Int64 = 0
    var tempActionCount: Int64 = 0
    /// ============================
    
    private var touchCount: Int64 = 0
    private var totalTouchCount: Int64 = 0
    private var touchCountToShow: Int64 = 0 {
        didSet {
            self.popScoreLabel.text = "\(self.touchCountToShow)"
        }
    }
    private var numberOfOwnedNfts: Int64 = 0
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemFill
        imageView.contentMode = .scaleAspectFill
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
        label.font = BellyGomFont.header08
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = self.nickNameLabelText
        label.textColor = .white
        label.font = BellyGomFont.header04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popRankStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "Pop Rank"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelText = "12" // TODO: TEMPORARY VALUE
        stack.bottomLabelFont = BellyGomFont.header09
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let popScoreStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "Pop Score"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
//        stack.bottomLabelText = "358,732"
        stack.bottomLabelFont = BellyGomFont.header09
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftsStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "NFTs"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
//        stack.bottomLabelText = "17"
        stack.bottomLabelFont = BellyGomFont.header05
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionCountStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "Action Count"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header05
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    //Change this to Pop Score Label
    private lazy var popScoreLabel: UILabel = {
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
        let bottomSheet = BottomSheetView(
            frame: .zero,
            bottomSheetVM: bottomSheetVM
        )
        bottomSheet.bottomSheetColor = AftermintColor.backgroundNavy
        bottomSheet.barViewColor = .darkGray
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        return bottomSheet
    }()
    
    // MARK: - Init
    init(
        bottomSheetVM: BottomSheetViewModel
    ) {
        self.bottomSheetVM = bottomSheetVM
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
        setDelegate()
        
        // NEW SCEHME RELATED
        gameVM.getOwnedNfts()
        bind()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationBarSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        saveAndRetrieveGameCache(after: 5.0)
        
        if self.navigationController?.isNavigationBarHidden ?? true {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func viewWillLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ///Disable the timer when the view disappeared
        timer.invalidate()
        saveGameTotalScore()
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
    
    private func setDelegate() {
        self.bottomSheetVM.delegate = self
        self.bottomSheetVM.secondListVM.delegate = self
    }
    
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
    
    //MARK: - Private
    
    private func bind() {
        
        gameVM.ownedNftTokenIds.bind { tokenIds in
            guard let tokenIds = tokenIds else { return }
            // TODO: tokenIds는 Fire store에 저장할 때 사용될 예정
        }
        
    }
    
    // NEW SCHEME
    private func saveGameTotalScore() {
        
        Task {
            try await self.gameVM.saveScoreCache(
                of: .popgame,
                popScore: self.touchCount * self.numberOfOwnedNfts,
                actionCount: self.touchCount,
                ownerAddress: self.mockUser.address
            )
            print("Touch count saved: \(self.touchCount)")
            self.touchCount = 0
        }
        
        Task {
            try await self.gameVM.saveNFTScores(
                of: .popgame,
                actionCount: self.totalTouchCount,
                nftTokenId: self.gameVM.ownedNftTokenIds.value ?? [],
                ownerAddress: mockUser.address
            )
            print("Total touch count saved: \(self.totalTouchCount)")
            self.totalTouchCount = 0
        }

    }
    
    private func saveAndRetrieveGameCache(after second: TimeInterval) {
        timer = Timer.scheduledTimer(
            withTimeInterval: second,
            repeats: true,
            block: { [weak self] _ in
                guard let `self` = self else { return }
                // Save game score to db
                Task {
                    try await self.gameVM.saveScoreCache(
                        of: .popgame,
                        popScore: self.touchCount * self.numberOfOwnedNfts,
                        actionCount: self.touchCount,
                        ownerAddress: self.mockUser.address
                    )
                    self.touchCount = 0
                }
                // Retrive game score from db
                self.bottomSheetVM.getItems(of: .moono, gameType: .popgame)

            })
    }
    
    /// Get viewModel for current user information at the top right corner of the vc
    private func getCurrentUserViewModel() {
        let currentUserViewModel = self.bottomSheetVM.secondListVM.currentUserViewModel()
        self.numberOfOwnedNfts = Int64(currentUserViewModel?.bottomLabelText ?? "0") ?? 0
        DispatchQueue.main.async {
            /// User information part
            let url = URL(string: currentUserViewModel?.userProfileImage ?? "N/A")
            NukeImageLoader.loadImageUsingNuke(url: url) { image in
                self.userImageView.image = image
            }

            self.walletAddressLabel.text = currentUserViewModel?.topLabelText.cutOfRange(length: 10)
            self.nickNameLabel.text = "NFTs \(currentUserViewModel?.bottomLabelText ?? "0")"
            /// Scoreboard part
            self.nftsStack.bottomLabelText = currentUserViewModel?.bottomLabelText ?? "0"
            self.tempPopScore = currentUserViewModel?.popScore ?? 0
            self.tempActionCount = currentUserViewModel?.actionCount ?? 0
            self.popScoreStack.bottomLabelText = String(describing: self.tempPopScore)
            self.actionCountStack.bottomLabelText = String(describing: self.tempActionCount)
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

}

extension GameViewController: MoonoGameSceneDelegate {
    
    func didReceiveTouchCount(number: Int64) {
        let currentUserViewModel = self.bottomSheetVM.secondListVM.currentUserViewModel()
        guard let numberOfNfts = Int64(currentUserViewModel?.bottomLabelText ?? "0") else { return }

        self.touchCountToShow += number
        self.totalTouchCount += number
        self.touchCount += number
        
        self.tempPopScore += (number * Int64(numberOfNfts))
        self.tempActionCount += number
        self.popScoreStack.bottomLabelText = "\(self.tempPopScore)"
        self.actionCountStack.bottomLabelText = "\(self.tempActionCount)"
        
        self.bottomSheetView.currentUserScoreUpdateHandler?(self.tempPopScore)
    }

}

//TODO: Export this logic to GameVCViewModel
extension GameViewController: BottomSheetViewModelDelegate {
    
    ///Get notified when the data saved to firestore
    func dataFetched() {
        print("Fetched")
//        self.touchCount = 0
//        self.getCurrentUserViewModel()
    }

}

// TODO: NO4. BottomSheetVMDelegate으로 이동
extension GameViewController: LeaderBoardSecondSectionCellListViewModelDelegate {
    func dataFetched2() {
        self.touchCount = 0
        self.getCurrentUserViewModel()
    }
}
