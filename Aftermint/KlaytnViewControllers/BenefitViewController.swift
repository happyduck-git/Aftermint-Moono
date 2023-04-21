//
//  EventViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/20.
//

import UIKit
import Pulley

class BenefitViewController: UIViewController {
    
    // MARK: - Dependency
    struct Dependency {
        let bookmarkVCDependency: BookmarkViewController.Dependency
        let calendarVCDependency: CalendarViewController.Dependency
    }
    
    private let bookmarkVCDependency: BookmarkViewController.Dependency
    private var calendarVCDependency: CalendarViewController.Dependency
    
    // MARK: - Init
    init(bookmarkVCDependency: BookmarkViewController.Dependency,
         calendarVCDependency: CalendarViewController.Dependency) {
        self.bookmarkVCDependency = bookmarkVCDependency
        self.calendarVCDependency = calendarVCDependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Elements
    private let menuBar: BenefitMenuBar = {
        let menuBar = BenefitMenuBar()
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        return menuBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(EventCell.self, forCellWithReuseIdentifier: EventCell.identifier)
        collection.register(VoteCell.self, forCellWithReuseIdentifier: VoteCell.identifier)
        
        collection.backgroundColor = AftermintColor.backgroundNavy
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        
        return collection
        
    }()
    
    public let bottomSheetVC: BenefitTabBottomViewController = BenefitTabBottomViewController()
    private var pulleyVC: PulleyViewController?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationBarSetup()
        setUI()
        setLayout()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BenefitVC will appear")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationBarSetup()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("BenefitVC will disappear")
//        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    //MARK: - Set UI & Layout
    private func setUI() {
        view.addSubview(menuBar)
        view.addSubview(collectionView)
        
        bottomSheetVC.delegate = self
        menuBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    private func setLayout() {
        let tabBarHeight = view.frame.size.height / 8.2
        
        
        NSLayoutConstraint.activate([
            menuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            menuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuBar.heightAnchor.constraint(equalToConstant: 48.0),
            
            collectionView.topAnchor.constraint(equalTo: menuBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight))
            
        ])
    }
    
    private func navigationBarSetup() {
        
        self.navigationController?.navigationBar.backgroundColor = .white
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.navigationItem.title = ""
        
        /* Left bar item */
        let logo = UIImage(named: "benefit_logo")
        let myImageView = UIImageView(image: logo)
        let leftBar: UIBarButtonItem = UIBarButtonItem(customView: myImageView)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftBar
        
        /* Right bar item */
        let rightBarBookmark: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "bookmark_white_empty_24")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(bookmarkTapped))
        
        let rightBarCalendar: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar_white_empty_24")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(calendarTapped))
        
        self.tabBarController?.navigationItem.rightBarButtonItems = [rightBarCalendar, rightBarBookmark]
        
    }
    
    @objc private func bookmarkTapped() {
        let reactor = BookmarkViewReactor()
        /// NOTE: DELETE IF NOT NEEDED
//        let benefitTabBottomVC = BenefitTabBottomViewController()
        let bookmarkVC = BookmarkViewController(reactor: bookmarkVCDependency.reactor(),
                                                bottomSheetVC: bookmarkVCDependency.bottomSheetVC)
        self.navigationController?.pushViewController(bookmarkVC, animated: true)
    }
    
    @objc private func calendarTapped() {
        let reactor = CalendarViewReactor()
        let calendarVC = CalendarViewController(reactor: calendarVCDependency.reactor(),
                                                bottomSheetVC: calendarVCDependency.bottomSheetVC)
        self.navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    
}

extension BenefitViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath {
        case IndexPath(item: 0, section: 0):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as? EventCell else { return UICollectionViewCell() }
            return cell
            
        case IndexPath(item: 1, section: 0):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VoteCell.identifier, for: indexPath) as? VoteCell else { return UICollectionViewCell() }
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as? EventCell else { return UICollectionViewCell() }
            return cell
            
        }
        
    }

    // Temporarily deactivated
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath {
            
        case IndexPath(item: 0, section: 0):
            let eventDetailVC: EventDetailViewController = EventDetailViewController()
            pulleyVC = PulleyViewController(contentViewController: eventDetailVC, drawerViewController: bottomSheetVC)
            guard let pulleyVC = pulleyVC else { return }
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(pulleyVC, animated: true)

            
        default:
            return
        }
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        menuBar.selectItem(at: Int(index))
    }
    
}

extension BenefitViewController: BenefitMenuBarDelegate {
    func didSelectItemAt(index: Int) {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        menuBar.selectItem(at: index)
        collectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }
}

extension BenefitViewController: BenefitTabBottomViewControllerDelegate {
    func didButtonTap() {
        print("Button tapped")
        let vc = BottomSheetViewController()
        vc.modalPresentationStyle = .overCurrentContext
        pulleyVC?.present(vc, animated: false)
    }
}
