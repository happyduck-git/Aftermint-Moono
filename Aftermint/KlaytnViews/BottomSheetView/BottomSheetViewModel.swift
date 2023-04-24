//
//  BottomSheetViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/04/24.
//

import Foundation
import DifferenceKit

final class BottomSheetViewModel {
    
    private let firstListVM: LeaderBoardFirstSectionCellListViewModel
    private let secondListVM: LeaderBoardSecondSectionCellListViewModel
    var changeset: Box<StagedChangeset<[ArraySection<SectionID, AnyDifferentiable>]>> = Box(StagedChangeset([]))
    
    init(
        firstListVM: LeaderBoardFirstSectionCellListViewModel,
        secondListVM: LeaderBoardSecondSectionCellListViewModel
    ) {
        self.firstListVM = firstListVM
        self.secondListVM = secondListVM
    }
    
    var source: [ArraySection<SectionID, AnyDifferentiable>] = []
    
    func getItems() {
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
        
        let group = DispatchGroup()
        var firstSectionNewVal: [LeaderBoardFirstSectionCellViewModel] = []
        group.enter()
        self.firstListVM.getFirstSectionVM(ofCollection: .moono) {
            group.leave()
            firstSectionOldVal.append($0)
            firstSectionNewVal.append($0)
        }
        
        var secondSectionNewVal: [LeaderBoardSecondSectionCellViewModel] = []
        group.enter()
        self.secondListVM.getAddressSectionVM {
            group.leave()
            secondSectionOldVal = $0
            secondSectionNewVal = $0
        }
        
        group.notify(queue: .main) {
            
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
    
}

