//
//  LoginViewReactor.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/30.
//

import ReactorKit
import RxSwift
import UIKit

final class LoginViewReactor: Reactor {
    
    let kasWalletRepository: KasWalletRepository = KasWalletRepository.shared
    let kasConnectService: KASConnectService = KASConnectService.shared
    let firestoreRepository: FirestoreRepository = FirestoreRepository.shared
    var requestToken: String?
    
    private var isWaitingTransactionResponse: Bool = false
    private var observer: NSObjectProtocol?
    
    enum Action {
        case connectWithFavorlet
        case connectWithKaikas
    }
    
    enum Mutation {
        case openFavorlet
        case openKaikas
        case presentAlert(String?)
    }
    
    struct State {
        var shouldOpenFavorlet: Bool = false
        var shouldOpenKaikas: Bool = false
        var alertMessage: String?
        var isWalletConnected: Bool = false
    }
    
    var initialState: State
    
    // MARK: - Init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .connectWithFavorlet:
            self.saveWalletAddressAndUsernameToFirestore()
            return Observable.just(Mutation.openFavorlet)
            
        case .connectWithKaikas:
            return Observable.create { observer -> Disposable in
                self.deeplinkToKaikasToConnectWallet { result in
                    switch result {
                    case .success:
                        observer.onNext(.openKaikas)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onNext(.presentAlert(error.localizedDescription))
                        observer.onNext(.presentAlert(nil))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        }
    }
    
    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .openFavorlet:
            newState.shouldOpenFavorlet = true
            newState.shouldOpenKaikas = false
            
        case .openKaikas:
//            newState.shouldOpenFavorlet = false
//            newState.shouldOpenKaikas = true
            newState.isWalletConnected = true
            
        case .presentAlert(let message):
            newState.alertMessage = message
        }
        return newState
    }
}

extension LoginViewReactor {

    private func deeplinkToKaikasToConnectWallet(completion: @escaping (Result<String, Error>) -> ()) {
        Task.init {
            do {
                guard let requestToken = try await self.kasConnectService.getTokenID() else { return }
                guard let kaikasUrl = URL(string: "kaikas://wallet/api?request_key=\(requestToken)") else { return }
                guard let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/id1626107061") else { return }
                self.isWaitingTransactionResponse = true
                
                /// Check if `Kaikas` is installed or not;
                /// If so, open `Kaikas`,
                /// else, open `AppStore`.
                if await UIApplication.shared.canOpenURL(kaikasUrl) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(kaikasUrl)
                    }
                } else {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(appStoreUrl)
                    }
                }
                
                /// Notify when the app will enter foreground.
                self.observer = await NotificationCenter.default.addObserver(
                    forName: UIApplication.willEnterForegroundNotification,
                    object: nil,
                    queue: .main,
                    using: { notification in

                        /// When notified that the app will enter foreground,
                        /// acquire wallet address and save the address to KasWalletRepository.
                        /// ** Also save the address and username to Firestore **
                        /// ** Username is a demo pupose **
                        Task.init {
                            do {
                                let walletAddress = try await self.kasConnectService.getWalletAddress(requestKey: requestToken)
                                self.kasWalletRepository.setCurrentWallet(walletAddress: walletAddress)
                                print("walletAddress: \(walletAddress)")
                                completion(.success(walletAddress))
                            } catch (let error){
                                print("Error \(error)")
                                completion(.failure(error))
                            }
                        }
                })
   
            } catch (let error){
                print("Error \(error)")
                completion(.failure(error))
            }
        }
    }
    
    /// ** Save the address and username to Firestore **
    /// ** Username is a demo pupose **
    private func saveWalletAddressAndUsernameToFirestore() {
        let mockUser = MoonoMockUserData().getOneUserData()
        
        /// TEMP: Only for demo purpose
        self.firestoreRepository.saveAddressBaseFields(
            ownerAddress: mockUser.address,
            username: mockUser.username
        )
        self.kasWalletRepository.setUsername(
            username: mockUser.username
        )

    }
    
}

