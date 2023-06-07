//
//  NftCardCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/03/13.
//

import Foundation

final class NftCardCellViewModel {
    
    var accDesc: String
    var backgroundDesc: String
    var bodyDesc: String
    var dayDesc: String
    var effectDesc: String
    var expressionDesc: String
    var hairDesc: String
    
    var name: String
    var updatedAt: Int64
    
    var imageUrl: String
    
    init(accDesc: String, backgroundDesc: String, bodyDesc: String, dayDesc: String, effectDesc: String, expressionDesc: String, hairDesc: String, name: String, updatedAt: Int64, imageUrl: String) {
        self.accDesc = accDesc
        self.backgroundDesc = backgroundDesc
        self.bodyDesc = bodyDesc
        self.dayDesc = dayDesc
        self.effectDesc = effectDesc
        self.expressionDesc = expressionDesc
        self.hairDesc = hairDesc
        self.name = name
        self.updatedAt = updatedAt
        self.imageUrl = imageUrl
    }
}

extension NftCardCellViewModel: Hashable {
   
    static func == (lhs: NftCardCellViewModel, rhs: NftCardCellViewModel) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}
