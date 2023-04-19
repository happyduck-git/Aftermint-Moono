//
//  NetworkMonitor.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/19.
//

import Foundation
import Network

extension Notification.Name {
    static let connectivityStatus = Notification.Name("connectivityStatusChanged")
}

final class NetworkMonitor {
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor
    
    private var flag: Bool = false
    public private(set) var isConnected: Bool = false {
        didSet {
            if self.isConnected && self.isConnected != oldValue {
                self.flag = true
            } else if !self.isConnected && self.isConnected != oldValue {
                self.flag = true
            } else {
                self.flag = false
            }
        }
    }
    
    public private(set) var connectionType: ConnectionType = .unknown
    
    private init() {
        self.monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        self.monitor.start(queue: queue)
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let `self` = self else { return }
            self.isConnected = path.status == .satisfied
            self.getConnectionType(path)
            if self.flag {
                NotificationCenter.default.post(name: .connectivityStatus, object: nil)
            }
        }
    }
    
    public func stopMonitoring() {
        self.monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self.connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            self.connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            self.connectionType = .ethernet
        } else {
            self.connectionType = .unknown
        }
    }
    
}
