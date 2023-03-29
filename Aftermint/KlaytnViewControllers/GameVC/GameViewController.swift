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
    private var nftGradeLabelText: String = "/ Moono week"
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
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemFill
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor(ciColor: .white).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftDataAndScoreStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftDataStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = BellyGomFont.header06
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nftGradeLabel: UILabel = {
        let label = UILabel()
        label.text = self.nftGradeLabelText
        label.textColor = .white
        label.font = BellyGomFont.header06
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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

        configureProfileInfo()
        self.bottomSheetView.bottomSheetDelegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarSetup()
    }
    
    var timer: Timer = Timer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        ///Set Timer scheduler to repeat certain action
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            print("Accumulated touchCount: \(self.touchCount)")
            self.leaderBoardListViewModel.increaseTouchCount(self.touchCount)
        }
    }
    
    override func viewWillLayoutSubviews() {
        nftImageView.layer.cornerRadius = nftImageView.frame.size.width / 2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ///Disable the timer when the view disappeared
        timer.invalidate()
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
        view.addSubview(nftImageView)
        view.addSubview(nftDataAndScoreStackView)
        view.addSubview(bottomSheetView)
        
        nftDataAndScoreStackView.addArrangedSubview(nftDataStackView)
        nftDataAndScoreStackView.addArrangedSubview(touchCountLabel)
        nftDataStackView.addArrangedSubview(nftNameLabel)
        nftDataStackView.addArrangedSubview(nftGradeLabel)
    }
    
    private func setLayout() {
        let viewHeight = view.frame.size.height
        gameSKView.frame = view.bounds
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.nftImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            self.nftImageView.heightAnchor.constraint(equalToConstant: viewHeight / 14),
            self.nftImageView.widthAnchor.constraint(equalTo: self.nftImageView.heightAnchor),
            
            
            self.nftDataAndScoreStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 1),
            self.nftDataAndScoreStackView.centerYAnchor.constraint(equalTo: self.nftImageView.centerYAnchor),
            
            self.bottomSheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
    
    private func configureProfileInfo() {
        let card = leaderBoardListViewModel.randomMoonoData
        let url = URL(string: card.imageUri)
        NukeImageLoader.loadImageUsingNuke(url: url) { image in
            self.nftImageView.image = image
        }
        
        let nftName = card.tokenId.replacingOccurrences(of: "___", with: " #")
        self.nftNameLabel.text = "\(nftName) "
    }
}

extension GameViewController: MoonoGameSceneDelegate {
    
    func didReceiveTouchCount(number: Int64) {
        print("Touch received: \(number)")
        self.touchCountToShow += number
        self.touchCount += number
    }

}

//TODO: Export this logic to GameVCViewModel
extension GameViewController: BottomSheetViewDelegate {
    
    ///Get notified when the data saved to firestore
    func dataFetched() {
        self.touchCount = 0
    } 

}
