//
//  LottieViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/26.
//

import UIKit
import AVKit

import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import Nuke

class LottieViewController: UIViewController, View {
    
    // MARK: - Dependency
    struct Dependency {
        let factory: LottieViewReactor.Factory
    }
    
    var disposeBag = DisposeBag()
    
    //MARK: - Init
    init(reactor: LottieViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Image & Description data
    private let templateOnImageList: [UIImage?] = [
        UIImage(named: "fyi_on"), UIImage(named: "welcome_on"), UIImage(named: "gallery_on"), UIImage(named: "bought_on")
    ]
    
    private let templateOffImageList: [UIImage?] = [
        UIImage(named: "fyi_off"), UIImage(named: "welcome_off"), UIImage(named: "gallery_off"), UIImage(named: "bought_off")
    ]
    
    private let testCellVMList: [TemplateCellContent] = [
        TemplateCellContent(emojiString: "🗝", title: "FYI", subTitle: "제일 가치로운"),
        TemplateCellContent(emojiString: "🎉", title: "Welcome", subTitle: "환영합니다!"),
        TemplateCellContent(emojiString: "🏙", title: "Gallery", subTitle: "멋진 갤러리처럼"),
        TemplateCellContent(emojiString: "💰", title: "Just Bought", subTitle: "새로 샀어요"),
    ]
    
    //MARK: - UI Elements
    private let animationFrameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .secondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var previewAnimationView: AnimationView = {
        var view = AnimationView()
        view.layer.masksToBounds = true
        view.backgroundColor = .secondaryLabel
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        TemplateUtility.shared.setup(view)
        return view
    }()
    
    private let horizontalLine1: UIView = {
        let view = UIView()
        view.backgroundColor = AftermintColor.moonoGrey
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = BellyGomFont.header05
        label.numberOfLines = 0
        label.text = LottieAsset.description.rawValue
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let horizontalLine2: UIView = {
        let view = UIView()
        view.backgroundColor = AftermintColor.moonoGrey
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LottieAsset.refreshButton.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let undoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LottieAsset.undoButton.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let redoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LottieAsset.redoButton.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let templateCollectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.register(LottieTemplateCell.self, forCellWithReuseIdentifier: LottieTemplateCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = AftermintColor.backgroundNavy
        return collection
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LottieAsset.sharedButton.rawValue), for: .normal)
        button.imageView?.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let barButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: LottieAsset.backButton.rawValue), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AftermintColor.backgroundNavy
        
        templateCollectionView.delegate = self
        templateCollectionView.dataSource = self

        setUI()
        setLayout()
        setBarButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Set UI & Layout
    private func setUI() {
        view.addSubview(animationFrameView)
        view.addSubview(previewAnimationView)
        view.addSubview(horizontalLine1)
        view.addSubview(descriptionLabel)
        view.addSubview(horizontalLine2)
        view.addSubview(refreshButton)
        view.addSubview(undoButton)
        view.addSubview(redoButton)
        view.addSubview(templateCollectionView)
        view.addSubview(shareButton)

    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            animationFrameView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24.0),
            animationFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationFrameView.widthAnchor.constraint(equalToConstant: 335.0),
            animationFrameView.heightAnchor.constraint(equalToConstant: 335.0),
            
            horizontalLine1.topAnchor.constraint(equalTo: animationFrameView.bottomAnchor, constant: 24.0),
            horizontalLine1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17.5),
            horizontalLine1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17.5),
            horizontalLine1.heightAnchor.constraint(equalToConstant: 1.0),
            
            descriptionLabel.topAnchor.constraint(equalTo: horizontalLine1.bottomAnchor, constant: 12.0),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.5),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.5),
            
            horizontalLine2.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12.0),
            horizontalLine2.leadingAnchor.constraint(equalTo: horizontalLine1.leadingAnchor),
            horizontalLine2.trailingAnchor.constraint(equalTo: horizontalLine1.trailingAnchor),
            horizontalLine2.heightAnchor.constraint(equalTo: horizontalLine1.heightAnchor),
            
            refreshButton.topAnchor.constraint(equalTo: horizontalLine2.bottomAnchor, constant: 16.0),
            refreshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21.0),

            undoButton.topAnchor.constraint(equalTo: refreshButton.topAnchor),
            undoButton.leadingAnchor.constraint(equalTo: refreshButton.trailingAnchor, constant: 230.0),

            redoButton.topAnchor.constraint(equalTo: refreshButton.topAnchor),
            redoButton.leadingAnchor.constraint(equalTo: undoButton.trailingAnchor, constant: 8.0),
            redoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),

            templateCollectionView.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 14.0),
            templateCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            templateCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            shareButton.topAnchor.constraint(equalTo: templateCollectionView.bottomAnchor, constant: 24.0),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -42.0),
        ])
        
        setPreviewAnimationViewLayout()
    }
    
    private func setPreviewAnimationViewLayout() {
        NSLayoutConstraint.activate([
            previewAnimationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24.0),
            previewAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewAnimationView.widthAnchor.constraint(equalToConstant: 335.0),
            previewAnimationView.heightAnchor.constraint(equalToConstant: 335.0)
        ])
    }

    private func setBarButtonItem() {
        let backButtonImage: UIImage? = UIImage(named: LottieAsset.backButton.rawValue)?.withRenderingMode(.alwaysOriginal)
        let buttonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backToHomeVC))
        self.navigationItem.leftBarButtonItem = buttonItem
    }
    
    @objc private func backToHomeVC() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Extension for Lottie player of Gall3ry3
    private var imageData: Data?
    private var isLoadedText: Bool = false {
        didSet {
            if isLoadedText,
               isLoadedImage {
                dismissIndicator()
            }
        }
    }
    private var isLoadedImage: Bool = false {
        didSet {
            if isLoadedText,
               isLoadedImage {
                dismissIndicator()
            }
        }
    }
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<TemplateSection>(configureCell: { _, collectionView, indexPath, reactor in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LottieTemplateCell.identifier, for: indexPath) as! LottieTemplateCell
        cell.reactor = reactor
        return cell
    })
    
    private lazy var blockView = UIView().then {
        $0.backgroundColor = .init(hex: 0xEDEDED).withAlphaComponent(0.5)
        view.addSubview($0)
    }
    
    private lazy var indicator = UIActivityIndicatorView().then {
        $0.layer.cornerRadius = 8 * scale
        $0.layer.backgroundColor = UIColor.white01.cgColor
        $0.frame.center = self.view.bounds.center
        $0.frame.size = .init(width: 70 * scale, height: 70 * scale)
        $0.startAnimating()
        view.addSubview($0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoadedText || !isLoadedImage {
            presentIndicator()
        } else {
            dismissIndicator()
        }
    }
}


extension LottieViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templateOffImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LottieTemplateCell.identifier, for: indexPath) as? LottieTemplateCell else {
            fatalError("Unsupported cell")
        }
        cell.resetCell()
        let vm = testCellVMList[indexPath.row]
        cell.configure(emojiString: vm.emojiString, title: vm.title, subTitle: vm.subTitle)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewFrameHeight = self.templateCollectionView.frame.size.height
        return CGSize(width: viewFrameHeight, height: viewFrameHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LottieTemplateCell else { return }
        
        cell.isOff = !cell.isOff
        if cell.isOff {
            cell.removeGradientLayer()
        } else {
            cell.setGradientColor()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LottieTemplateCell else { return }
        
        cell.isOff = !cell.isOff
        if cell.isOff {
            cell.removeGradientLayer()
        } else {
            cell.setGradientColor()
        }
    }

}

//MARK: - Bind Action and State
extension LottieViewController {
    
    func bind(reactor: LottieViewReactor) {
        bindByGall3ry3(reactor: reactor)
        bindAction(with: reactor)
        bindState(with: reactor)
    }
    
    private func bindState(with reactor: LottieViewReactor) {
    }
    
    private func bindAction(with reactor: LottieViewReactor) {
    }
}

// MARK: Extension for Lottie player of Gall3ry3
extension LottieViewController {
    private func bindByGall3ry3(reactor: LottieViewReactor) {
        setUiByGall3ry3()
        bindStateByGall3ry3(with: reactor)
        bindActionByGall3y3(with: reactor)
    }
    
    private func bindStateByGall3ry3(with reactor: LottieViewReactor) {
//        reactor.state.map { $0.templateSections }
//            .bind(to: templateCollectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.selectedTemplate }
            .bind { [weak self] template in
                self?.presentIndicator {
                    DispatchQueue.global().async {
                        self?.setTemplate(template: template, nft: reactor.payload.nft)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.render }
            .bind { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.presentIndicator {
                    self.render(format: self.reactor!.payload.format)
                }
                
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.lottieTextDictionary }
            .bind { [weak self] dic in
                guard let self = self else {
                    return
                }
                if self.isLoadedText == false {
                    self.isLoadedText = true
                }
                if let template = reactor.currentState.selectedTemplate {
                    let keys = self.previewAnimationView.getLayerKeypaths()
                    let updatedDic = template.updateDic(keys: keys, dic: dic)
                    self.updateText(updatedDic)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.share }
            .bind { [weak self] _ in
                self?.shareVideo()
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.collectionImageData }
            .bind { [weak self] data in
                if self?.isLoadedImage == false {
                    self?.isLoadedImage = true
                }
                self?.updateImage(key: "image_0", data: data)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindActionByGall3y3(with reactor: LottieViewReactor) {
        templateCollectionView.rx.itemSelected
            .map(Reactor.Action.selectTemplate)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .map { _ in Reactor.Action.share }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.just(Reactor.Action.fetchTemplate)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        if let openSeaNFT = reactor.payload.nft as? OpenSeaNFT {
            Observable.just(Reactor.Action.requestCollection(openSeaNFT))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            Observable.just(Reactor.Action.requestCollectionImage(openSeaNFT))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
}

// MARK: Extension for Lottie player of Gall3ry3
extension LottieViewController {
    // MARK: - Method
    private func presentIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
            self.indicator.isHidden = false
            self.blockView.isHidden = false
            completion?()
        }
    }
    
    private func dismissIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.blockView.isHidden = true
            completion?()
        }
    }
    
    private func setUiByGall3ry3() {
        blockView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        indicator.snp.makeConstraints {
            $0.width.height.equalTo(70 * scale)
            $0.center.equalToSuperview()
        }
    }
    
    private func shareVideo() {
        guard let reactor = reactor else {
            return
        }
        
        DispatchQueue.main.async {
            let videoPath = InventoryService.videoCacheFolderURL.appendingPathComponent(reactor.payload.art!.fileName)
            LLog.i("videoPath: \(videoPath)")
            
            let items = [videoPath]
            let shareViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(shareViewController, animated: true)
        }
        
        if let selectedTemplate = reactor.prevSelectedTemplate {
            DispatchQueue.global().async {
                self.setTemplate(template: selectedTemplate, nft: reactor.payload.nft)
            }
        }
        dismissIndicator()
    }
    
    private func setTemplate(template: Template, nft: NFTProtocol) {
        DispatchQueue.global().async { [weak self] in
            if let reactor = self?.reactor,
               let url = URL(string: reactor.payload.nft.imageURLString) {
                ImagePipeline.shared.loadData(with: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let result):
                        self.previewAnimationView.animation = .fileURL(template.fileURL)
                        let keypaths = self.previewAnimationView.getLayerKeypaths()
                        if let dic = reactor.currentState.lottieTextDictionary,
                           let template = reactor.currentState.selectedTemplate {
                            let updatedDic = template.updateDic(keys: keypaths, dic: dic)
                            if !updatedDic.isEmpty {
                                self.updateText(updatedDic)
                            }
                        }
                        if let data = reactor.currentState.collectionImageData {
                            self.updateImage(key: "image_0", data: data)
                        }
                        self.imageData = result.data
                        self.updateImage(key: "image_1", data: result.data)
                        if self.reactor?.payload.format == .video {
                            self.previewAnimationView.play()
                        } else {
                            self.previewAnimationView.updateAnimationFrame(self.previewAnimationView.animation?.endFrame ?? 0)
                        }
                    case .failure(let error):
                        print("Fail fetch image from Nuke: \(error.localizedDescription)")
                    }
                    self.dismissIndicator()
                }
            }
        }
    }
    
    private func render(format: OutputFormat) {
        switch format {
        case .video:
            renderToVideo()
        case .image:
            renderToImage()
        }
    }
    
    private func updateImage(key: String, data: Data) {
        let base64 = "data:image/png;base64," + data.base64EncodedString()
        if key == "image_1",
           let size = UIImage(data: data)?.size {
            if size.width > size.height {
                let scale = size.height / size.width
                
                previewAnimationView = updateHeightSize(scale: scale, animationView: previewAnimationView)
                previewAnimationView = updateImageHeightSize(scale: scale, animationView: previewAnimationView)
            } else {
                let scale = size.width / size.height
                
                previewAnimationView = updateWidthSize(scale: scale, animationView: previewAnimationView)
                previewAnimationView = updateImageWidthSize(scale: scale, animationView: previewAnimationView)
            }
        }
            
        let animation = self.previewAnimationView.animation
        animation?.assetLibrary?.imageAssets[key]?.name = base64
        animation?.assetLibrary?.imageAssets[key]?.directory = ""
        self.previewAnimationView.animation = animation
    }
    
    private func updateWidthSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("frame"),
                   layers[layerIndex].type == .shape,
                   let shapeLayer = layers[layerIndex] as? ShapeLayerModel {
                    
                    for itemIndex in 0..<shapeLayer.items.count {
                        if shapeLayer.items[itemIndex].type == .group,
                           let group = shapeLayer.items[itemIndex] as? Group {
                            
                            for itemIndex in 0..<group.items.count {
                                if group.items[itemIndex].type == .rectangle,
                                    let rectangleItem = group.items[itemIndex] as? Rectangle {
                                    
                                    let size = rectangleItem.size.keyframes.first!.value
                                    let newSize: KeyframeGroup<Vector3D> = .init(.init(x: size.x * scale, y: size.y, z: size.z))
                                    (group.items[itemIndex] as? Rectangle)?.size = newSize
                                }
                            }
                            shapeLayer.items[itemIndex] = group
                        }
                    }
                    result.animation?.layers[layerIndex] = shapeLayer
                }
            }
        }
        return result
    }
    
    private func updateHeightSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("frame"),
                   layers[layerIndex].type == .shape,
                   let shapeLayer = layers[layerIndex] as? ShapeLayerModel {
                    
                    for itemIndex in 0..<shapeLayer.items.count {
                        if shapeLayer.items[itemIndex].type == .group,
                           let group = shapeLayer.items[itemIndex] as? Group {
                            
                            for itemIndex in 0..<group.items.count {
                                if group.items[itemIndex].type == .rectangle,
                                    let rectangleItem = group.items[itemIndex] as? Rectangle {
                                    
                                    let size = rectangleItem.size.keyframes.first!.value
                                    let newSize: KeyframeGroup<Vector3D> = .init(.init(x: size.x, y: size.y * scale, z: size.z))
                                    (group.items[itemIndex] as? Rectangle)?.size = newSize
                                }
                            }
                            shapeLayer.items[itemIndex] = group
                        }
                    }
                    result.animation?.layers[layerIndex] = shapeLayer
                }
            }
        }
        return result
    }
    
    private func updateImageWidthSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("resize"),
                   layers[layerIndex].type == .image,
                   let imageLayer = layers[layerIndex] as? ImageLayerModel {
                    for keyframeIndex in 0..<imageLayer.transform.scale.keyframes.count {
                        let size = imageLayer.transform.scale.keyframes[keyframeIndex].value
                        let newSize: Keyframe<Vector3D> = .init(.init(x: size.x * scale, y: size.y, z: size.z))
                        imageLayer.transform.scale.keyframes[keyframeIndex] = newSize
                    }
                    result.animation?.layers[layerIndex] = imageLayer
                }
            }
        }
        return result
    }
    
    private func updateImageHeightSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("resize"),
                   layers[layerIndex].type == .image,
                   let imageLayer = layers[layerIndex] as? ImageLayerModel {
                    for keyframeIndex in 0..<imageLayer.transform.scale.keyframes.count {
                        let size = imageLayer.transform.scale.keyframes[keyframeIndex].value
                        let newSize: Keyframe<Vector3D> = .init(.init(x: size.x, y: size.y * scale, z: size.z))
                        imageLayer.transform.scale.keyframes[keyframeIndex] = newSize
                    }
                    result.animation?.layers[layerIndex] = imageLayer
                }
            }
        }
        return result
    }
    
    private func updateText(_ dic: [String: String]) {
        let textProvider = DictionaryTextProvider(dic)
        previewAnimationView.textProvider = textProvider
    }
    
    private func getAnimationLayer(frame: CGFloat? = nil) -> CALayer {
        var targetFrame: CGFloat = 0
        if let frame = frame {
            targetFrame = frame
        } else if let frame = previewAnimationView.animation?.endFrame {
            targetFrame = frame
        }
        previewAnimationView.updateAnimationFrame(targetFrame)
        return previewAnimationView.layer
    }
    
    private func renderToImage() {
        DispatchQueue.main.async {
            let layer = self.getAnimationLayer()
            ImageRenderer.shared.quickRenderImage(layer: layer, size: .init(width: 720, height: 720)) { [weak self] data in
                guard let self = self,
                      let reactor = self.reactor else {
                    return
                }
                if let data = data,
                   let template = reactor.prevSelectedTemplate {
                    let art = InventoryService.shared.saveImage(data: data, nft: reactor.payload.nft, template: template)
                    self.reactor!.payload.art = art
                    Observable.just(Reactor.Action.rendered(data))
                        .bind(to: self.reactor!.action)
                        .disposed(by: self.disposeBag)
                }
            }
        }
    }
    
    private func renderToVideo() {
        guard let animation = self.previewAnimationView.animation else {
            LLog.w("animation is nil.")
            return
        }
        
        let framesLength = Int(animation.endFrame) + 1
        let timeScale = animation.framerate
        let taskGroup = DispatchGroup()
        var frameImageDataDictionary: [Int: Data] = [:]
        
        previewAnimationView.removeFromSuperview()
        DispatchQueue.global().async(group: taskGroup) {
            frameImageDataDictionary = ImageRenderer.shared.renderImages(animationView: self.previewAnimationView)
        }
        
        taskGroup.notify(queue: .global()) {
            DispatchQueue.main.async {
                self.view.addSubview(self.previewAnimationView)
                self.setPreviewAnimationViewLayout()
            }
            
            var frameImages: [UIImage] = []
            guard let thumbnailImageData = frameImageDataDictionary[framesLength-1] else {
                LLog.w("thumbnailImageData is nil.")
                return
            }
            
            for index in 0..<framesLength {
                // First frame will be wrong scaled image sometimes. We try to ignore this frame.
                if index == 0 { continue }
                
                if let frameImageData = frameImageDataDictionary[index],
                   let frameImage = UIImage(data: frameImageData) {
                    frameImages.append(frameImage)
                } else {
                    LLog.w("frameImage is nil. index: \(index).")
                }
            }
            
            NewVideoRenderer.shared.quickRenderVideo(images: frameImages, endTime: .zero, timeScale: .init(timeScale), type: .multiple) { [weak self] videoData in
                DispatchQueue.main.async {
                    guard let self = self,
                       let videoData = videoData,
                       let reactor = self.reactor else {
                        return
                    }
                    let disposeBag = self.disposeBag
                    if let template = reactor.prevSelectedTemplate {
                        let art = InventoryService.shared.saveVideo(thumbData: thumbnailImageData, videoData: videoData, nft: reactor.payload.nft, template: template)
                        reactor.payload.art = art
                        Observable.just(Reactor.Action.rendered(videoData))
                            .bind(to: reactor.action)
                            .disposed(by: disposeBag)
                    }
                }
            }
        }
    }
}
