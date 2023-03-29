//
//  LeaderBoardBottomSheetViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/10.
//


/// NOTE: THIS VC IS NOT IN USE. PLEASE DELETE WHEN POSSIBLE
import UIKit

final class LeaderBoardBottomSheetViewController: UIViewController {
    
    //TODO: Change this dependency to initialize dependecy
    var viewModel: LeaderBoardTableViewCellListViewModel = LeaderBoardTableViewCellListViewModel()
    
    // MARK: - UI Elements
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
        table.backgroundColor = AftermintColor.secondaryBackgroundNavy
        table.register(LeaderBoardTableViewCell.self, forCellReuseIdentifier: LeaderBoardTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        setDelegate()
//        dummyViewModelGenerator()
    }
    
    // MARK: - Set up UI & Layout
    private func setUI() {
        view.backgroundColor = AftermintColor.backgroundNavy
        leaderBoardTableView.separatorColor = AftermintColor.separatorNavy
        view.addSubview(leaderBoardStackView)
        view.addSubview(leaderBoardTableView)
        self.leaderBoardStackView.addArrangedSubview(leaderBoardLogoImageView)
        self.leaderBoardStackView.addArrangedSubview(leaderBoardLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.leaderBoardStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 4),
            self.leaderBoardStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.leaderBoardTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.leaderBoardStackView.bottomAnchor, multiplier: 2),
            self.leaderBoardTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.leaderBoardTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.leaderBoardTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

// MARK: - TableView Delegate & DataSource
extension LeaderBoardBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardTableViewCell.identifier) as? LeaderBoardTableViewCell else { fatalError("Unsupported Cell") }
        
        let vm = self.viewModel.modelAt(indexPath.row)
        cell.configure(with: vm)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    /* TEMP */
//    private func dummyViewModelGenerator() {
//        let vm = LeaderBoardTableViewCellViewModel(rankImage: "1st_place_medal",
//                                                   nftImage: "nftimage1",
//                                                   nftName: "Moono #100",
//                                                   touchScore: 10)
//        for _ in 0...10 {
//            self.viewModel.viewModelList.append(vm)
//        }
//        
//        DispatchQueue.main.async {
//            self.leaderBoardTableView.reloadData()
//        }
//    }
    
    private func setDelegate() {
        leaderBoardTableView.delegate = self
        leaderBoardTableView.dataSource = self
    }
}
