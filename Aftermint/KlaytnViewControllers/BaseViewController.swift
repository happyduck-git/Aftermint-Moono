//
//  BaseViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/19.
//

import UIKit

class BaseViewController: UIViewController {
    
    private let sharedAlertController = UIAlertController(
        title: "Network Error",
        message: "Please check your internet connection and try again.",
        preferredStyle: .alert
    )
    
    private let action: UIAlertAction = UIAlertAction(title: "Dismiss", style: .cancel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sharedAlertController.addAction(action)
        NotificationCenter.default.addObserver(self, selector: #selector(isOnline(notification:)), name: .connectivityStatus, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .connectivityStatus, object: nil)
    }
    
    @objc func isOnline(notification: Notification) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                self.showAlert()
            }
        }
    }
    
    private func showAlert() {
        guard presentedViewController == nil else { return }
        
        if self.sharedAlertController.presentingViewController == nil {
            present(self.sharedAlertController, animated: true, completion: nil)
        }
    }
    
}


