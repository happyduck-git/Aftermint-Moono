//
//  OpenSeaService.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/03.
//

import Foundation

import RxSwift
import RxRelay

final class OpenSeaService: MarketPlaceServiceProtocol {
    
    static let shared: OpenSeaService = .init()
    
    private let client = OpenSeaClient.shared
    private let queue = DispatchQueue(label: "net.platfarm.mojitok-nft.OpenSeaService", qos: .utility)
    private let disposeBag: DisposeBag = .init()
    
    var addresses: [String] = []
    
    var allNFTs: [String: [NFTProtocol]] = [:]
    var dateNFTs: [String: [NFTProtocol]] = [:]
    var priceNFTs: [String: [NFTProtocol]] = [:]
    var collections: [String: [OpenSeaCollection]] = [:]
    
    let event = PublishSubject<MarketPlaceEvent>()
    
    private init() {}
    
    func request(address: String) {
        client.newnft(address: address, slug: nil) { [weak self] nfts in
            guard let self = self else {
                return
            }
            self.queue.sync { [weak self] in
                self?.allNFTs[address] = nfts
                self?.event.onNext(.all)
            }
        }
        
        client.newnft(address: address, slug: "sale_date") { [weak self] nfts in
            guard let self = self else {
                return
            }
            self.queue.sync { [weak self] in
                self?.dateNFTs[address] = nfts
                self?.event.onNext(.date)
            }
        }
        
        client.newnft(address: address, slug: "sale_price") { [weak self] nfts in
            guard let self = self else {
                return
            }
            self.queue.sync { [weak self] in
                self?.priceNFTs[address] = nfts
                self?.event.onNext(.price)
            }
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            let collections = self.client.collections(owner: address)
            self.queue.sync { [weak self] in
                self?.collections[address] = collections
                self?.event.onNext(.collection)
            }
        }
    }
    
    func refresh() {
        self.queue.sync {
            allNFTs.removeAll()
            dateNFTs.removeAll()
            priceNFTs.removeAll()
            collections.removeAll()
            event.onNext(.all)
            event.onNext(.date)
            event.onNext(.price)
            event.onNext(.collection)
        }
        for address in addresses {
            request(address: address)
        }
    }
    
    func configuration(addresses: [String]) {
        self.addresses = addresses
    }
    
    func add(address: String) {
        addresses.insert(address, at: 0)
        request(address: address)
    }
    
    func delete(address: String) {
        if let index = addresses.firstIndex(where: { $0 == address }) {
            addresses.remove(at: index)
            allNFTs.removeValue(forKey: address)
            dateNFTs.removeValue(forKey: address)
            collections.removeValue(forKey: address)
            priceNFTs.removeValue(forKey: address)
            event.onNext(.all)
            event.onNext(.price)
            event.onNext(.collection)
            event.onNext(.date)
        }
    }
}
