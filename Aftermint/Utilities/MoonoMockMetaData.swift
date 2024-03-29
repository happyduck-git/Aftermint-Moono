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
    private let mockIndex: Int = 0
    
    private let moonoList: [Card] = [
        
        Card(tokenId: "81",
             ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             popScore: 0,
             actionCount: 0,
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%2381.jpeg?alt=media"),
   
        Card(tokenId: "1126",
             ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             popScore: 0,
             actionCount: 0,
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%231126.jpeg?alt=media"),
   
        Card(tokenId: "618",
             ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             popScore: 0,
             actionCount: 0,
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23618.jpeg?alt=media"),
   
        Card(tokenId: "659",
             ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             popScore: 0,
             actionCount: 0,
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23659.jpeg?alt=media"),
   
        Card(tokenId: "1202",
             ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             popScore: 0,
             actionCount: 0,
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%231202.jpeg?alt=media"),
   
        Card(tokenId: "924",
             ownerAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
             popScore: 0,
             actionCount: 0,
             imageUrl: "https://firebasestorage.googleapis.com/v0/b/moono-aftermint-storage.appspot.com/o/Moono%23924.jpeg?alt=media")
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
    private let mockIndex: Int = 6
 
    private let userList: [AfterMintUser] = [
        AfterMintUser(username: "Rebecca",
                          address: "0x015a997c4CA73F9170AE60B1e89ddF703Aa3E2a1",
                          imageUrl: "rebecca",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 1),
        AfterMintUser(username: "Maine",
                          address: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                          imageUrl: "maine",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 0),
        AfterMintUser(username: "Lucy",
                          address: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
                          imageUrl: "lucy",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 17),
        AfterMintUser(username: "David",
                          address: "0x0284DD66FC6D12D4ED26E81EF1c5b56B0410E914",
                          imageUrl: "david",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 15),
        AfterMintUser(username: "차가운 화요일",
                          address: "0x8fB1B947E7b9e508C0a1445D1966709C069b6167",
                          imageUrl: "dorio",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 13),
        AfterMintUser(username: "sori",
                          address: "0xcFFA6E1E4092351d58cF8e00FbC3112A13334e45",
                          imageUrl: "kiwi",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 7),
        AfterMintUser(username: "miniminimi",
                          address: "0xD6d98ee36a4fC08A4916f6b90D75A273554Df4b7",
                          imageUrl: "miniminimi",
                          popCount: 0,
                          actionCount: 0,
                          totalNfts: 4),

    ]
    
    func getOneUserData() -> AfterMintUser {
        let numberOfData = self.userList.count
        return self.userList[mockIndex % numberOfData]
    }
    
    func getAllUserData() -> [AfterMintUser] {
        return self.userList
    }
    
}
