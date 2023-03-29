//
//  BookmarkViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/02/06.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Pulley

class BookmarkViewController: UIViewController {
    
    // MARK: - Dependency
    struct Dependency {
        let reactor: () -> BookmarkViewReactor
        let bottomSheetVC: BenefitTabBottomViewController
    }
    
    private var bottomSheetVC: BenefitTabBottomViewController
    var disposeBag: DisposeBag = DisposeBag()
    
    //MARK: - UI Elements

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(EventCell.self, forCellWithReuseIdentifier: EventCell.identifier)
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true

        return collection

    }()
    
    //MARK: - Init
    init(reactor: BookmarkViewReactor,
         bottomSheetVC: BenefitTabBottomViewController) {
        self.bottomSheetVC = bottomSheetVC
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationController?.setNavigationBarHidden(false, animated: false) //벨리곰 로고 나오는 bar
        self.navigationController?.setNavigationBarHidden(true, animated: false) //북마크 타이틀 & left button bar
        navigationBarSetup()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.parent?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    

    //MARK: - Set UI & Layout
    private func setUI() {
        
        view.addSubview(collectionView)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
           
        ])
    }
    
    private func navigationBarSetup() {
        
        self.parent?.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        
        /* Left bar item */
        let backButtonImage: UIImage? = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        let leftBar = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backToPreviousVC))
        self.parent?.tabBarController?.navigationItem.leftBarButtonItem = leftBar
        self.parent?.tabBarController?.navigationItem.title = "북마크"
        self.parent?.tabBarController?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(ciColor: .white)]
        
        /* Right bar item */
        self.parent?.tabBarController?.navigationItem.rightBarButtonItems = nil
        self.parent?.tabBarController?.tabBar.barTintColor = AftermintColor.backgroundNavy
    }
    
    @objc private func backToPreviousVC() {
        self.navigationController?.popViewController(animated: true)
    }


}


extension BookmarkViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
    
    
    private func tapToBenefitVC() {
        
        // Temporarily deactivated
        /*
        let eventDetailVC: EventDetailViewController = EventDetailViewController()

        let pulleyVC = PulleyViewController(contentViewController: eventDetailVC, drawerViewController: bottomSheetVC)

        self.navigationController?.pushViewController(pulleyVC, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        */
    }
    
    
    
}

extension BookmarkViewController: View {
    
    func bind(reactor: BookmarkViewReactor) {
        bindAction(with: reactor)
        bindState(with: reactor)
    }
    
    private func bindState(with reactor: BookmarkViewReactor) {
        
        reactor.state.map { $0.cellItems }
            .bind(to: self.collectionView.rx.items) { collectionView, item, element in
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: IndexPath(item: item, section: 0)) as? EventCell else { return UICollectionViewCell() }
                cell.configure(image: element)
                return cell
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isBenefitTapped }
            .subscribe { [weak self] isBenefitTapped in
                guard !isBenefitTapped else { return }
                guard let `self` = self else { return }
                self.tapToBenefitVC()
            }
            .disposed(by: self.disposeBag)


    }
    
    private func bindAction(with reactor: BookmarkViewReactor) {
        
        Observable.just(Reactor.Action.refresh)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.collectionView.rx.itemSelected
            .map { indexPath in
                print("Item selected tapped")
//                return Reactor.Action.tapEventImage
                if indexPath == IndexPath(item: 0, section: 0) {
                    return Reactor.Action.tapEventImage
                } else {
                    return Reactor.Action.tapUtilityImage
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
}



extension BookmarkViewController: BookmarkMenuBarDelegate {
    func didSelectItemAt(index: Int) {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
    
}
