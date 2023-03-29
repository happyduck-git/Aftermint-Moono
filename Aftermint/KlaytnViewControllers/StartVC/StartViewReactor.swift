//
//  StartViewReactor.swift
//  Aftermint
//
//  Created by Platfarm on 2023/01/30.
//

import ReactorKit
import RxSwift

//TODO: Remove Reactor Logic => No specific logics here
final class StartViewReactor: Reactor { 
    
    let kasWalletRepository: KasWalletRepository = KasWalletRepository.shared
    
    enum Action {
        case start
    }
    
    enum Mutation {
        case start
    }
    
    struct State {
        var start: Void = ()
    }
    
    let initialState: State
    
    // MARK: - Init
    init() {
        self.initialState = State()
    }
    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .start:
            return Observable.just(Mutation.start)
            
        }
    }
    
    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .start:
            newState.start = ()
        }
        
        return newState
    }
    
    
}
