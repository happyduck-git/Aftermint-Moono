//
//  BottomSheetView.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import UIKit
import Nuke

protocol BottomSheetViewDelegate: AnyObject {
    func dataFetched()
}

final class BottomSheetView: PassThroughView {
    
    let prefetcher = ImagePrefetcher()
    
    var firstSectionVM: LeaderBoardFirstSectionCellViewModel
    var sectionSectionVM: LeaderBoardSecondSectionCellListViewModel?
    
    weak var bottomSheetDelegate: BottomSheetViewDelegate?
    var tempTouchCountList: [String: Int64] = [:]
    
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
        imageView.image = UIImage(named: LeaderBoardAsset.markImageName.rawValue)
        return imageView
    }()
    
    private let leaderBoardLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.textColor = .white
        label.text = LeaderBoardAsset.title.rawValue
        return label
    }()
    
    let leaderBoardTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = AftermintColor.backgroundNavy
        table.alpha = 0.0
        table.register(LeaderBoardFirstSectionCell.self, forCellReuseIdentifier: LeaderBoardFirstSectionCell.identifier)
        table.register(LeaderBoardTableViewCell.self, forCellReuseIdentifier: LeaderBoardTableViewCell.identifier)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10.0, right: 0)
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
    
    init(frame: CGRect,
         vm: LeaderBoardSecondSectionCellListViewModel,
         firstSectionVM: LeaderBoardFirstSectionCellViewModel
    ) {
        self.firstSectionVM = firstSectionVM
        super.init(frame: frame)
        
        self.sectionSectionVM = vm
        self.backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.addGestureRecognizer(panGesture)
        
        self.bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.bottomSheetView.layer.cornerRadius = Const.cornerRadius
        self.bottomSheetView.clipsToBounds = true
        
        setUI()
        setLayout()
        setDelegate()
        
        getFirstSectionViewModel()
//        getSecondSectionViewModel()
        //TODO: Need to change getSecondSectionViewModel() to vm.getAddressSectionVM()
        vm.getAddressSectionVM()
        bind()
        
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
    
    private func bind() {
        self.sectionSectionVM?.leaderBoardVMList.bind({ [weak self] _ in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6) {
                    self?.leaderBoardTableView.reloadData()
                    self?.leaderBoardTableView.alpha = 1.0
                }
            }
        })
    }
    
}

// MARK: - TableView Delegate & DataSource
extension BottomSheetView: UITableViewDelegate, UITableViewDataSource {
    
    private func getFirstSectionViewModel() {
        
        self.firstSectionVM.getFirstSectionViewModel(ofCollection: .moono) { result in
            switch result {
            case .success(let vm):
                self.firstSectionVM.nftImage = vm.nftImage
                self.firstSectionVM.nftCollectionName = vm.nftCollectionName
                self.firstSectionVM.totalActionCount = vm.totalActionCount
                self.firstSectionVM.totalPopScore = vm.totalPopScore
                
//                DispatchQueue.main.async {
//                    UIView.animate(withDuration: 0.6) {
//                        self.leaderBoardTableView.reloadData()
//                        self.leaderBoardTableView.alpha = 1.0
//                    }
//                }
            case .failure(let failure):
                print("Error getting first section view model: \(failure)")
            }
        }
      
    }
    
//    private func getSecondSectionViewModel() {
//        self.sectionSectionVM?.getAddressSectionViewModel(completion: { result in
//            switch result {
//            case .success(let viewModels):
//                self.sectionSectionVM?.leaderBoardVMList.value = viewModels
//                DispatchQueue.main.async {
//                    UIView.animate(withDuration: 0.6) {
//                        self.leaderBoardTableView.reloadData()
//                        self.bottomSheetDelegate?.dataFetched()
//                        self.leaderBoardTableView.alpha = 1.0
//                    }
//                }
//
//            case .failure(let failure):
//                print("Error getting viewmodels : \(failure)")
//            }
//        })
//
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            guard let numberOfSection = self.sectionSectionVM?.numberOfRowsInSection(at: section) else { return 0 }
            return numberOfSection
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardFirstSectionCell.identifier) as? LeaderBoardFirstSectionCell else { return UITableViewCell() }
            cell.resetCell()
            cell.configure(with: firstSectionVM)
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardTableViewCell.identifier) as? LeaderBoardTableViewCell,
                  let vm = self.sectionSectionVM?.modelAt(indexPath)
            else { return UITableViewCell()}
            cell.resetCell()

            guard let indices = self.sectionSectionVM?.changedIndicies.value else { return UITableViewCell() }
            for index in indices {
                if indexPath.row == Int(index) {
                    UIView.transition(with: cell, duration: 0.8, options: .transitionCrossDissolve) {
                        cell.popScoreLabel.textColor = .systemOrange
                    } completion: { _ in
                        UIView.transition(with: cell, duration: 0.8, options: .transitionCrossDissolve) {
                            cell.popScoreLabel.textColor = .white
                        }
                    }
                }
            }
            
            if vm.topLabelText == MoonoMockUserData().getOneUserData().address {
                cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
            }
 
            //TODO: Make below logic as a separate function
            if indexPath.row <= 2 {
                vm.setRankImage(with: cellRankImageAt(indexPath.row))
            } else {
                cell.switchRankImageToLabel()
                vm.setRankNumberWithIndexPath(indexPath.row + 1)
            }
            
            cell.configure(with: vm)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return 40
        }
    }
    
    /// Determine cell image
    private func cellRankImageAt(_ indexPathRow: Int) -> UIImage? {
        switch indexPathRow {
        case 0:
            return UIImage(named: LeaderBoardAsset.firstPlace.rawValue)
        case 1:
            return UIImage(named: LeaderBoardAsset.secondPlace.rawValue)
        case 2:
            return UIImage(named: LeaderBoardAsset.thirdPlace.rawValue)
        default:
            return UIImage(named: LeaderBoardAsset.markImageName.rawValue)
        }
    }
    
    private func setDelegate() {
        leaderBoardTableView.delegate = self
        leaderBoardTableView.dataSource = self
        leaderBoardTableView.prefetchDataSource = self
    }
    
}

extension BottomSheetView: UITableViewDataSourcePrefetching {
    
    /// PretchImageAt
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urlStrings: [String] = indexPaths.compactMap {
            self.sectionSectionVM?.modelAt($0)?.userProfileImage
        }
        let urls: [URL] = urlStrings.compactMap {
            URL(string: $0)
        }
        prefetcher.startPrefetching(with: urls)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let urlStrings: [String] = indexPaths.compactMap {
            self.sectionSectionVM?.modelAt($0)?.userProfileImage
        }
        let urls: [URL] = urlStrings.compactMap {
            URL(string: $0)
        }
        prefetcher.stopPrefetching(with: urls)
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
    private func fetchTouchCount(with viewModelList: [LeaderBoardSecondSectionCellViewModel]) -> [String: Int64] {
        var result: [String: Int64] = [:]
//        viewModelList.forEach { vm in
//            let key = vm.nftName
//            let value = vm.touchScore
//            result[key] = value
//        }
        return result
    }
}
