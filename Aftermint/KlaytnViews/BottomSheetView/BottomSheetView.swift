//
//  BottomSheetView.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import UIKit

protocol BottomSheetViewDelegate: AnyObject {
    func tempFetchData(data: [String: Int64])
}

final class BottomSheetView: PassThroughView {
    
//    var viewModel: LeaderBoardTableViewCellListViewModel = LeaderBoardTableViewCellListViewModel()
    var viewModel: LeaderBoardTableViewCellListViewModel?
    
    weak var bottomSheetDelegate: BottomSheetViewDelegate?
    var tempTouchCountList: [String: Int64] = [:]
    // viewModel.viewModelList -> forEach -> filter by elements tokenId(which is nftName)
    // in GameVC, if the tokenId matches, get its touchCount and update scoreLabel.text
    
    // MARK: - UI Elements
    
    let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let leaderBoardStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 15
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let leaderBoardLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: LeaderBoard.markImageName.rawValue)
        return imageView
    }()
    
    private let leaderBoardLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.textColor = .white
        label.text = LeaderBoard.title.rawValue
        return label
    }()
    
    private let leaderBoardTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = AftermintColor.backgroundNavy
        table.alpha = 0.0
        table.register(LeaderBoardTableViewCell.self, forCellReuseIdentifier: LeaderBoardTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Properties
    var mode: Mode = .tip {
        didSet {
            switch self.mode {
            case .tip:
                break
            case .full:
                break
            }
            self.updateConstraint(offset: Const.bottomSheetYPosition(self.mode))
        }
    }
    
    var bottomSheetColor: UIColor? {
        didSet { self.bottomSheetView.backgroundColor = self.bottomSheetColor }
    }
    
    var barViewColor: UIColor? {
        didSet { self.barView.backgroundColor = self.barViewColor }
    }
    
    // MARK: - Initializer
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init() has not been implemented")
    }
    
    init(frame: CGRect, vm: LeaderBoardTableViewCellListViewModel) {
        super.init(frame: frame)
        
        self.viewModel = vm
        self.backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.addGestureRecognizer(panGesture)
        
        self.bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.bottomSheetView.layer.cornerRadius = Const.cornerRadius
        self.bottomSheetView.clipsToBounds = true
        
        setUI()
        setLayout()
        setDelegate()
        
        self.viewModel?.getAllNftRankCellViewModels { result in
            switch result {
            case .success(let viewModels):
                self.viewModel?.viewModelList = viewModels
                self.tempTouchCountList = self.fetchTouchCount(with: viewModels)
                self.bottomSheetDelegate?.tempFetchData(data: self.tempTouchCountList)
                DispatchQueue.main.async {
                    self.leaderBoardTableView.reloadData()
                }
            case .failure(let failure):
                print("Error getting viewmodels : \(failure)")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.barView.frame.size.height
        self.barView.layer.cornerRadius = height / 2
    }
    
    // MARK: - SetUI & Layout
    /// Dynamic BottomSheet top constraint
    var bottomSheetViewTopConstraint: NSLayoutConstraint?
    
    private func setUI() {
        
        self.addSubview(self.bottomSheetView)
        self.bottomSheetView.addSubview(self.barView)
        self.bottomSheetView.addSubview(leaderBoardStackView)
        self.bottomSheetView.addSubview(leaderBoardTableView)
        self.leaderBoardStackView.addArrangedSubview(leaderBoardLogoImageView)
        self.leaderBoardStackView.addArrangedSubview(leaderBoardLabel)
        
        leaderBoardTableView.separatorColor = AftermintColor.separatorNavy
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.barView.topAnchor.constraint(equalTo: self.bottomSheetView.topAnchor, constant: Const.barViewTopSpacing),
            self.barView.widthAnchor.constraint(equalToConstant: Const.barViewWidth),
            self.barView.heightAnchor.constraint(equalToConstant: Const.barViewHeight),
            self.barView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.leaderBoardStackView.topAnchor.constraint(equalToSystemSpacingBelow: barView.bottomAnchor, multiplier: 2),
            self.leaderBoardStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.leaderBoardTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.leaderBoardStackView.bottomAnchor, multiplier: 2),
            self.leaderBoardTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.leaderBoardTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.leaderBoardTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        bottomSheetViewTopConstraint = self.bottomSheetView.topAnchor.constraint(equalTo: self.topAnchor, constant: Const.bottomSheetYPosition(.tip))
        bottomSheetViewTopConstraint?.isActive = true
        
    }
    
    // MARK: Methods
    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        
        let translationY = recognizer.translation(in: self).y
        let minY = self.bottomSheetView.frame.minY
        let offset = translationY + minY
        
        if Const.bottomSheetYPosition(.full)...Const.bottomSheetYPosition(.tip) ~= offset {
            self.updateConstraint(offset: offset)
            recognizer.setTranslation(.zero, in: self)
        }
        
        UIView.animate(
            withDuration: 0,
            delay: 0,
            options: .curveEaseOut,
            animations: self.layoutIfNeeded,
            completion: nil
        )
        
        guard recognizer.state == .ended else { return }
        UIView.animate(
            withDuration: Const.duration,
            delay: 0,
            options: .allowUserInteraction,
            animations: {
                self.mode = recognizer.velocity(in: self).y >= 0 ? Mode.tip : .full
            },
            completion: nil
        )
    }
    
    /// Update top constraint of the bottom sheet by pan gesture offset
    private func updateConstraint(offset: Double) {

        bottomSheetViewTopConstraint?.constant = offset
        self.layoutIfNeeded()
    }
}

// MARK: - TableView Delegate & DataSource
extension BottomSheetView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfSection = self.viewModel?.numberOfRowsInSection(at: section) else { return 0 }
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardTableViewCell.identifier) as? LeaderBoardTableViewCell else { fatalError("Unsupported Cell") }
        
        cell.resetCell()
        
        guard let vm = self.viewModel?.modelAt(indexPath.row) else {
            fatalError("ViewModel found to be nil")
        }
        
        if indexPath.row <= 2 {
            vm.setRankImage(with: cellRankImageAt(indexPath.row))
        } else {
            cell.switchRankImageToLabel()
            vm.setRankNumberWithIndexPath(indexPath.row + 1)
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.6) {
                self.leaderBoardTableView.alpha = 1.0
            }
        }
        
        cell.configure(with: vm)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    private func cellRankImageAt(_ indexPathRow: Int) -> UIImage? {
        switch indexPathRow {
        case 0:
            return UIImage(named: RankImage.firstPlace.rawValue)
        case 1:
            return UIImage(named: RankImage.secondPlace.rawValue)
        case 2:
            return UIImage(named: RankImage.thirdPlace.rawValue)
        default:
            return UIImage(named: RankImage.others.rawValue)
        }
    }
    
    private func setDelegate() {
        leaderBoardTableView.delegate = self
        leaderBoardTableView.dataSource = self
    }
    
}

// MARK: - Enums
extension BottomSheetView {
    // MARK: Constants
    enum Mode {
        case tip
        case full
    }
    
    private enum Const {
        static let duration = 0.0
        static let cornerRadius = 12.0
        static let barViewTopSpacing = 5.0
        static let barViewWidth = UIScreen.main.bounds.width * 0.2
        static let barViewHeight = 5.0
        static let bottomSheetRatio: (Mode) -> Double = { mode in
            switch mode {
            case .tip:
                return 0.47 // 위에서 부터의 값 (밑으로 갈수록 값이 커짐)
            case .full:
                return 0.1
            }
        }
        static let bottomSheetYPosition: (Mode) -> Double = { mode in
            Self.bottomSheetRatio(mode) * UIScreen.main.bounds.height
        }
    }
}

//TEMP
extension BottomSheetView {
    private func fetchTouchCount(with viewModelList: [LeaderBoardTableViewCellViewModel]) -> [String: Int64] {
        var result: [String: Int64] = [:]
        viewModelList.forEach { vm in
            let key = vm.nftName
            let value = vm.touchScore
            result[key] = value
        }
        
        return result
    }
}
