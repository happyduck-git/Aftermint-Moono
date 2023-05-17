//
//  NFTCardView.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/01/20.
//


import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Nuke

protocol NFTCardViewDelegate: AnyObject {
    func didTapTemplateButton()
}

class NFTCardView: UIView {
    
    let prefetcher = ImagePrefetcher()
    var viewModel: NFTCardViewModel
    var nftSelected: [Bool] = []
    
    // MARK: - UIElements
    
    weak var delegate: NFTCardViewDelegate?
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 1.0
        stackView.accessibilityIdentifier = "nftCardStackView"
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let numbersOfNft: UILabel = {
        let label = UILabel()
        label.text = "3"
        label.font = BellyGomFont.header03
        label.textColor = AftermintColor.moonoBlue
        return label
    }()
    
    private let numbersOfNftDescription: UILabel = {
        let label = UILabel()
        label.text = "개의 무너 NFT"
        label.font = BellyGomFont.header06
        label.textColor = .white
        return label
    }()
    
    private let nftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(NftCardCell.self, forCellWithReuseIdentifier: NftCardCell.identifier)
        collectionView.accessibilityIdentifier = "nftCollectionView"
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AftermintColor.backgroundNavy
        collectionView.alpha = 0.0
        return collectionView
        
    }()
    
    // MARK: - Init
    
    init(vm: NFTCardViewModel) {
        self.viewModel = vm
        super.init(frame: .zero)
        setUI()
        layout()
        setDelegate()
        
        spinner.startAnimating()
        
        bind()
        fetchMoonoNft()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI and Layout
    private func setUI() {
        self.addSubview(spinner)
        self.addSubview(stackView)
        stackView.addArrangedSubview(numbersOfNft)
        stackView.addArrangedSubview(numbersOfNftDescription)
        
        self.addSubview(nftCollectionView)
    }
    
    private func setDelegate() {
        self.viewModel.delegate = self
        
        self.nftCollectionView.delegate = self
        self.nftCollectionView.dataSource = self
        
        self.nftCollectionView.isPrefetchingEnabled = true
        self.nftCollectionView.prefetchDataSource = self
    }
    
    private func layout() {
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: 50),
            spinner.heightAnchor.constraint(equalTo: spinner.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
            
            nftCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            nftCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            nftCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            nftCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
        
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}

//MARK: - CollectionView Delegate & DataSource

extension NFTCardView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        let numberOfNfts = self.viewModel.numberOfItemsInSection()
        
        self.numbersOfNft.text = String(numberOfNfts)
        nftSelected = Array(repeating: false, count: numberOfNfts)
        
        return numberOfNfts

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let vm = self.viewModel.itemAtIndex(indexPath.row) else {
            fatalError("No nft value found")
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NftCardCell.identifier, for: indexPath) as? NftCardCell else {
            fatalError("Unsupported cell")
        }
        
        // TODO: nftSelected을 ViewModel로 옮기기
        if nftSelected[indexPath.row] == false {
            cell.resetCell()
        } else {
            cell.selectViewToHide(cardBackView: false, nftImageView: true)
        }
        
        cell.delegate = self
        
        cell.backgroundColor = .white
        makeCellRadius(of: cell)
        makeCellShadow(of: cell)
        
        DispatchQueue.main.async {
            
            // Give fade-in animation
            UIView.animate(withDuration: 0.4) {
                self.nftCollectionView.alpha = 1.0
            }
            
            cell.configure(with: vm)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewFrameHeight = self.nftCollectionView.frame.size.height
        let viewFrameWidth = self.nftCollectionView.frame.size.width
        return CGSize(width: viewFrameWidth / 1.3, height: viewFrameHeight - 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! NftCardCell
        
        if nftSelected[indexPath.row] {
            nftSelected[indexPath.row] = false
            cell.selectViewToHide(cardBackView: true, nftImageView: false)

            UIView.transition(from: cell.cardBackView,
                              to: cell.cardFrontView,
                              duration: 0.3,
                              options: [.transitionFlipFromLeft, .showHideTransitionViews])
        } else {
            nftSelected[indexPath.row] = true
            cell.selectViewToHide(cardBackView: false, nftImageView: true)
        
            UIView.transition(from: cell.cardFrontView,
                              to: cell.cardBackView,
                              duration: 0.3,
                              options: [.transitionFlipFromLeft, .showHideTransitionViews])
        }
        
    }
    
    private func makeCellRadius(of cell: UICollectionViewCell) {
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(ciColor: .black).cgColor
    }
    
    private func makeCellShadow(of cell: UICollectionViewCell) {
        cell.layer.masksToBounds = false
        cell.layer.shadowRadius = 8.0
        cell.layer.shadowOpacity = 1
        cell.layer.shadowColor = UIColor(red: 0.696, green: 0.696, blue: 0.696, alpha: 0.5).cgColor
        cell.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 4, y: 10, width: cell.frame.width, height: cell.frame.height - 10), cornerRadius: 20).cgPath
        cell.layer.shadowOffset = CGSize(width: 4, height: 4)
    }
 
}

extension NFTCardView: UICollectionViewDataSourcePrefetching {
    
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        let urlStrings = indexPaths.compactMap {
            self.viewModel.itemAtIndex($0.row)?.imageUrl
        }
        let urls = urlStrings.compactMap {
            URL(string: $0)
        }
        prefetcher.startPrefetching(with: urls)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
        let urlStrings = indexPaths.compactMap {
            self.viewModel.itemAtIndex($0.row)?.imageUrl
        }
        let urls = urlStrings.compactMap {
            URL(string: $0)
        }
        prefetcher.stopPrefetching(with: urls)
    }

}

//MARK: - ViewModel related

extension NFTCardView {
    
    private func bind() {
        
        viewModel.nftCardCellViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.nftCollectionView.reloadData()
            }
        }
        
    }
    
    private func fetchMoonoNft() {
        
        /// TempAddress used when there was no game features
//        let tempAddress: String = K.Wallet.temporaryAddress
        let tempAddress: String = MoonoMockUserData().getOneUserData().address

        self.viewModel.getNftCardCellViewModels(of: tempAddress) { result in
            switch result {
            case .success(let viewModels):
                self.viewModel.nftCardCellViewModel.value = viewModels
            case .failure(let failure):
                print("Failed -- \(#function) --- \(failure)")
            }
        }
        
    }
    
}

//MARK: - NftCardCellDelegate

extension NFTCardView: NftCardCellDelegate {
    
    func didTapTemplateButton() {
        delegate?.didTapTemplateButton()
    }
    
}

extension NFTCardView: NFTCardViewModelDelegate {
    
    func didLoadNfts() {
        spinner.stopAnimating()
    }
    
}
