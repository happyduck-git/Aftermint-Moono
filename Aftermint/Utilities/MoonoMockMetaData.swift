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
        
        Card(ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
             tokenId: "Moono___81",
             actionCount: 0,
             popScore: 0),
        
        Card(ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
             tokenId: "Moono___1126",
             actionCount: 0,
             popScore: 0),
        
        Card(ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
             tokenId: "Moono___618",
             actionCount: 0,
             popScore: 0),
        
        Card(ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
             tokenId: "Moono___659",
             actionCount: 0,
             popScore: 0),
        
        Card(ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
             tokenId: "Moono___1202",
             actionCount: 0,
             popScore: 0),
        
        Card(ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media",
             collectionAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
             tokenId: "Moono___924",
             actionCount: 0,
             popScore: 0)
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

struct MoonoMockUserData {
    
    /// Changing this prorperty value will decide what mock AftermintUser object to use from the userList property
    private let mockIndex: Int = 2
 
    private let userList: [AfterMintUserTest] = [
        AfterMintUserTest(username: "Rebecca",
                          address: "0x015a997c4CA73F9170AE60B1e89ddF703Aa3E2a1",
                          imageUrl: "rebecca",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 12),
        AfterMintUserTest(username: "Maine",
                          address: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                          imageUrl: "maine",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 45),
        AfterMintUserTest(username: "Lucy",
                          address: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
                          imageUrl: "lucy",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 99),
        AfterMintUserTest(username: "David",
                          address: "0x0284DD66FC6D12D4ED26E81EF1c5b56B0410E914",
                          imageUrl: "david",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 12),
        AfterMintUserTest(username: "Dorio",
                          address: "0x8fB1B947E7b9e508C0a1445D1966709C069b6167",
                          imageUrl: "dorio",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 12),
        AfterMintUserTest(username: "Kiwi",
                          address: "0xcFFA6E1E4092351d58cF8e00FbC3112A13334e45",
                          imageUrl: "kiwi",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 12),
    ]
    
    func getOneUserData() -> AfterMintUserTest {
        let numberOfData = self.userList.count
        return self.userList[mockIndex % numberOfData]
    }
    
    func getAllUserData() -> [AfterMintUserTest] {
        return self.userList
    }
    
}
