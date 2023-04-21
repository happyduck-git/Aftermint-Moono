//
//  ShopViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/20.
//

import UIKit

class MarketViewController: UIViewController {
    
    /// NOTE: Only for demonstration purpose;
    /// use of dummy images will be replaced with real image data from Opensea
    let moonoMockImageData: MoonoMockImageData = MoonoMockImageData()
    
    /// TODO: Change the dropDown view using DropDown library
    let dropDownView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: MarketAsset.dropDown.rawValue)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var nftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = view.frame.width / 15
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = AftermintColor.backgroundNavy
        collection.register(MarketCell.self, forCellWithReuseIdentifier: MarketCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        
        return collection
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup()
        setUI()
        setLayout()
    }
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MarketVC - \(#function)")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationBarSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MarketVC - \(#function)")
        
        /// When NavigationController's navigation bar is hidden
        /// due to view hierarchy, show hidden navigation bar in viewDidAppear.
        if self.navigationController?.isNavigationBarHidden ?? true {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
    }

    //MARK: - Set UI & Layout
    private func setUI() {
        view.addSubview(dropDownView)
        view.addSubview(nftCollectionView)
        nftCollectionView.delegate = self
        nftCollectionView.dataSource = self
    }
    
    private func setLayout() {
        let tabBarHeight = view.frame.size.height / 8.2
        
        NSLayoutConstraint.activate([
            
            dropDownView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            dropDownView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dropDownView.widthAnchor.constraint(equalToConstant: 100.0),
            dropDownView.heightAnchor.constraint(equalToConstant: 32.0),
            
            nftCollectionView.topAnchor.constraint(equalTo: dropDownView.bottomAnchor, constant: 24.0),
            nftCollectionView.leadingAnchor.constraint(equalTo: dropDownView.leadingAnchor),
            nftCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            nftCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight))
        ])
    }
    
    private func navigationBarSetup() {
        
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.navigationItem.title = ""
        
        let logo = UIImage(named: MarketAsset.marketVCLogo.rawValue)
        let myImageView = UIImageView(image: logo)
        let leftBar: UIBarButtonItem = UIBarButtonItem(customView: myImageView)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftBar
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
    }
}

extension MarketViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MarketCell.identifier, for: indexPath) as? MarketCell else {
            fatalError("Unsupported cell")
        }
        cell.configure(image: moonoMockImageData.moonoDummyImages[indexPath.item % 8])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        
        return CGSize(width: viewWidth / 2.34, height: viewHeight / 3.76)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let marketNftVC: BasicTabBarController = BasicTabBarController()
        navigationItem.titleView?.tintColor = AftermintColor.backgroundNavy
        navigationController?.pushViewController(marketNftVC, animated: true)
        
    }
    
}
