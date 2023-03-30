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
    private let mockIndex: Int = 0
    
    private let userList: [AftermintUser] = [
        AftermintUser(walletAddress: "0x6a5fe8B4718bC147ba13BD8Dfb31eC6097bfabcB",
                      username: "Rebecca",
                      userProfileImageUrl: "rebecca",
                      totalOwned: 10,
                      popScore: 0),
        AftermintUser(walletAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                      username: "Maine",
                      userProfileImageUrl: "maine",
                      totalOwned: 45,
                      popScore: 0),
        AftermintUser(walletAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                      username: "Lucy",
                      userProfileImageUrl: "lucy",
                      totalOwned: 99,
                      popScore: 0),
        AftermintUser(walletAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                      username: "David",
                      userProfileImageUrl: "david",
                      totalOwned: 23,
                      popScore: 0),
        AftermintUser(walletAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                      username: "Dorio",
                      userProfileImageUrl: "dorio",
                      totalOwned: 71,
                      popScore: 0),
        AftermintUser(walletAddress: "0xdc96292cDf56d0607552359b555D4EDFa99D7B65",
                      username: "Kiwi",
                      userProfileImageUrl: "kiwi",
                      totalOwned: 2,
                      popScore: 0)
    ]
    
    func getOneUserData() -> AftermintUser {
        let numberOfData = self.userList.count
        return self.userList[mockIndex % numberOfData]
    }
    
    func getAllUserData() -> [AftermintUser] {
        return self.userList
    }
    
}
