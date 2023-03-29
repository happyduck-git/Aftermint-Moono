//
//  BenefitTabBottomViewController.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/02/06.
//

import UIKit
import Pulley

protocol BenefitTabBottomViewControllerDelegate: AnyObject {
    func didButtonTap()
}

class BenefitTabBottomViewController: UIViewController {
    
    
    weak var delegate: BenefitTabBottomViewControllerDelegate?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        stack.spacing = 16.0
        stack.accessibilityIdentifier = "BBVC stackView"
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bookmarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "bookmark_circle_off_56")
        imageView.layer.masksToBounds = true
        imageView.accessibilityIdentifier = "BBVC imageView"
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var button: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "register"), for: .normal)
        button.addTarget(self, action: #selector(presentBottomSheet), for: .touchUpInside)
        button.accessibilityIdentifier = "BBVC button"
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setLayout()
        
    }
    
    private func setUI() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(bookmarkImageView)
        stackView.addArrangedSubview(button)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15.0),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    public func configure(image: String) {
        button.setImage(UIImage(named: image), for: .normal)
    }
    
    
    @objc private func presentBottomSheet(action: Selector) {
        print("Tpped")
        delegate?.didButtonTap()
    }
}

extension BenefitTabBottomViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        return 68.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        return 264.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed]
    }

}
