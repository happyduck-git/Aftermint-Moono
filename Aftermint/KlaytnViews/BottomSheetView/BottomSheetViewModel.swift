//
//  BottomSheetViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/24.
//

import Foundation
import DifferenceKit

final class BottomSheetViewModel {
    
    public private(set) var firstListVM: LeaderBoardFirstSectionCellListViewModel
    public private(set) var secondListVM: LeaderBoardSecondSectionCellListViewModel
    var changeset: Box<StagedChangeset<[ArraySection<SectionID, AnyDifferentiable>]>> = Box(StagedChangeset([]))
    var isLoaded: Box<Bool> = Box(false)
    
    init(
        firstListVM: LeaderBoardFirstSectionCellListViewModel,
        secondListVM: LeaderBoardSecondSectionCellListViewModel
    ) {
        self.firstListVM = firstListVM
        self.secondListVM = secondListVM
    }
    
    var source: [ArraySection<SectionID, AnyDifferentiable>] = []
    
    func getInitialItems(of collectionType: CollectionType, gameType: GameType) {
        
        Task {
            
            guard var firstSectionOldVal = self.firstListVM.leaderBoardFirstSectionVMList.value,
                  var secondSectionOldVal = self.secondListVM.leaderBoardVMList.value else {
                return
            }
            
            let typedErasedFirstSectionOldVal = firstSectionOldVal.map {
                return AnyDifferentiable($0)
            }
            let typedErasedSecondSectionOldVal = secondSectionOldVal.map {
                return AnyDifferentiable($0)
            }
            
            self.source = [
                ArraySection(model: .first, elements: typedErasedFirstSectionOldVal),
                ArraySection(model: .second, elements: typedErasedSecondSectionOldVal)
            ]
            
            var firstSectionNewVal: [LeaderBoardFirstSectionCellViewModel] = []
            async let firstSectionVM = self.firstListVM.getFirstSectionVM(of: collectionType, gameType: gameType)
            
            var secondSectionNewVal: [LeaderBoardSecondSectionCellViewModel] = []
            async let secondSectionVM = self.secondListVM.getInitialAddressSectionVM(of: collectionType, gameType: gameType)
            
            guard let firstVM = try await firstSectionVM else { return }
            firstSectionOldVal.append(firstVM)
            firstSectionNewVal.append(firstVM)
            
            guard let secondVM = try await secondSectionVM else { return }
            secondSectionOldVal = secondVM
            secondSectionNewVal = secondVM
            
            let typedErasedFirstSectionNewVal = firstSectionNewVal.map {
                AnyDifferentiable($0)
            }
            
            let typedErasedSecondSectionNewVal = secondSectionNewVal.map {
                return AnyDifferentiable($0)
            }
            
            let target: [ArraySection<SectionID, AnyDifferentiable>] = [
                ArraySection(model: .first, elements: typedErasedFirstSectionNewVal),
                ArraySection(model: .second, elements: typedErasedSecondSectionNewVal)
            ]
            
            self.changeset.value = StagedChangeset(source: self.source, target: target)
            self.isLoaded.value = true
        }
        
    }
    
    func getCachedItems(of collectionType: CollectionType, gameType: GameType) async throws {
        
        guard var firstSectionOldVal = self.firstListVM.leaderBoardFirstSectionVMList.value,
              var secondSectionOldVal = self.secondListVM.leaderBoardVMList.value else {
            return
        }
        
        let typedErasedFirstSectionOldVal = firstSectionOldVal.map {
            return AnyDifferentiable($0)
        }
        let typedErasedSecondSectionOldVal = secondSectionOldVal.map {
            return AnyDifferentiable($0)
        }
        
        self.source = [
            ArraySection(model: .first, elements: typedErasedFirstSectionOldVal),
            ArraySection(model: .second, elements: typedErasedSecondSectionOldVal)
        ]
        
        var firstSectionNewVal: [LeaderBoardFirstSectionCellViewModel] = []
        async let firstSectionVM = self.firstListVM.getFirstSectionVM(of: collectionType, gameType: gameType)
        
        var secondSectionNewVal: [LeaderBoardSecondSectionCellViewModel] = []
        async let secondSectionVM = self.secondListVM.getCachedAddressSectionVM(of: collectionType, gameType: gameType)
        
        guard let firstVM = try await firstSectionVM else { return }
        firstSectionOldVal.append(firstVM)
        firstSectionNewVal.append(firstVM)
        
        guard let secondVM = try await secondSectionVM else { return }
        secondSectionOldVal = secondVM
        secondSectionNewVal = secondVM
        
        let typedErasedFirstSectionNewVal = firstSectionNewVal.map {
            AnyDifferentiable($0)
        }
        
        let typedErasedSecondSectionNewVal = secondSectionNewVal.map {
            return AnyDifferentiable($0)
        }
        
        let target: [ArraySection<SectionID, AnyDifferentiable>] = [
            ArraySection(model: .first, elements: typedErasedFirstSectionNewVal),
            ArraySection(model: .second, elements: typedErasedSecondSectionNewVal)
        ]
        
        self.changeset.value = StagedChangeset(source: self.source, target: target)
        
    }
    
}

