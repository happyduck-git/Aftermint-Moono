//
//  MoonoMockMetaData.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation

/// Moono Mock MetaData Only for Game Demo;
/// Will be removed
struct MoonoMockMetaData {
    
    /// Changing this prorperty value will decide what mock Card object to use from the moonoList property
    private let mockIndex: Int = 5
    
    private let moonoList: [Card] = [
        
        Card(imageUri: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionId: K.ContractAddress.moono,
             tokenId: "Moono___81",
             count: 0),
        
        Card(imageUri: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%231126.jpeg?alt=media",
             collectionId: K.ContractAddress.moono,
             tokenId: "Moono___1126",
             count: 0),
        
        Card(imageUri: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23618.jpeg?alt=media",
             collectionId: K.ContractAddress.moono,
             tokenId: "Moono___618",
             count: 0),
        
        Card(imageUri: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23659.jpeg?alt=media",
             collectionId: K.ContractAddress.moono,
             tokenId: "Moono___659",
             count: 0),
        
        Card(imageUri: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%231202.jpeg?alt=media",
             collectionId: K.ContractAddress.moono,
             tokenId: "Moono___1202",
             count: 0),
        
        Card(imageUri: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23924.jpeg?alt=media",
             collectionId: K.ContractAddress.moono,
             tokenId: "Moono___924",
             count: 0)
        
    ]
    
    func getOneMockData() -> Card {
        let numberOfData = self.moonoList.count
        return self.moonoList[mockIndex % numberOfData]
    }

    func getRandomData() -> Card {
        let randomIndex = Int.random(in: 0..<self.moonoList.count)
        return self.moonoList[randomIndex]
    }
    
}

