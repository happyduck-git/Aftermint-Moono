//
//  NFTCardViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/02/25.
//

import Foundation

class NFTCardViewModel {
    
    let mockUser = MoonoMockUserData().getOneUserData()
    
    var nftCardCellViewModel: Box<[NftCardCellViewModel]> = Box([])
    var isLoaded: Box<Bool> = Box(false)
    var nftSelected: [Bool] = []
    let fireStoreRepository = FirestoreRepository.shared
    
    func numberOfItemsInSection() -> Int {
        guard let numberOfItems = self.nftCardCellViewModel.value?.count else {
            return 0
        }
        self.nftSelected = Array(repeating: false, count: numberOfItems)
        return numberOfItems
    }
    
    func itemAtIndex(_ index: Int) -> NftCardCellViewModel? {
        guard let viewModel: NftCardCellViewModel = self.nftCardCellViewModel.value?[index] else { return nil }
        return viewModel
    }
    
    func getNftCardCellViewModel(of wallet: String) async throws {
        
        async let result = withCheckedContinuation({ continuation in
            let _ = KlaytnNftRequester.requestToGetMoonoNfts(
                walletAddress: wallet
            ) { nfts in
                    
                    var tokenIds = Array<String>()
                    
                    let viewModels = nfts.map { nft in
                        let viewModel: NftCardCellViewModel = NftCardCellViewModel(
                            accDesc: nft.traits.accessories,
                            backgroundDesc: nft.traits.background,
                            bodyDesc: nft.traits.body,
                            dayDesc: nft.traits.day,
                            effectDesc: nft.traits.accessories,
                            expressionDesc: nft.traits.expression,
                            hairDesc: nft.traits.hair,
                            name: nft.name,
                            updatedAt: nft.updateAt,
                            imageUrl: nft.imageUrl
                        )
                        tokenIds.append(String(nft.tokenId.convertToDecimal() ?? 0))
                        return viewModel
                    }
                    
                continuation.resume(returning: (vms: viewModels, tokens: tokenIds))
                
                }
        })
        
        /// Check if there is any change in owned NFTs.
        async let recordedNftSet = self.fireStoreRepository
            .getCurrentUserOwnedNfts(mockUser.address)
        
        let newNfts = await result.tokens.sorted()
        let oldNfts = try await recordedNftSet.sorted()
        
        async let _ = self.checkChangesInOwnedNfts(newNfts: newNfts, oldNfts: oldNfts)
        
        /// Set owned NFTs to related variable.
        self.nftCardCellViewModel.value = await result.vms
        self.isLoaded.value = true
        
        await self.saveUserInitialInfo(
            ownerAddress: mockUser.address,
            gameType: .popgame,
            initialScore: 0,
            ownedNftList: newNfts
        )
    }
    
    func checkChangesInOwnedNfts(
        newNfts: [String],
        oldNfts: [String]
    ) async {
        let diff = newNfts.difference(from: oldNfts)
        
        if !diff.isEmpty { // When there is any change.
            for change in diff {
                switch change {
                case .remove(_, let element, _):
                    await self.fireStoreRepository.updateNftOwner(of: element, to: K.FStore.noOwnerFound)
                case .insert(_, let element, _):
                    await self.fireStoreRepository.updateNftOwner(of: element, to: mockUser.address)
                }
            }
        } else {
            return
        }
    }
    
    func saveUserInitialInfo(
        ownerAddress: String,
        gameType: GameType,
        initialScore: Int64,
        ownedNftList: [String]
    ) async {
        
        /// Save current user's nft info to UserDefaults
        var nftDictionary: [String: String] = [:]
        for i in 0..<ownedNftList.count {
            let tokenId = ownedNftList[i]
            let convertedId = tokenId.convertToHex() ?? "0x219"
            async let imageUri = KlaytnNftRequester.requestMoonoNftImageUrl(
                contractAddress: CollectionType.moono.address,
                tokenId: convertedId
            )
            
            nftDictionary[tokenId] = await imageUri
        }
        UserDefaults.standard.setValue(nftDictionary, forKey: "owned-nft-token-ids")
        
        /// Set initial NFT scores for games for a new user.
        let isOldUser = await self.fireStoreRepository.checkIfSavedUserNew(
            ownerAddress: mockUser.address,
            of: .popgame
        )
        
        if !isOldUser {
            do {
                try await self.fireStoreRepository
                    .saveNewUserInitialData(
                        ownerAddress: ownerAddress,
                        gameType: gameType,
                        initialScore: initialScore,
                        nftList: ownedNftList
                    )
            }
            catch {
                print("Error saving NFT score: \(error)")
            }
            
        } else {
            return
        }
        
    }
  
}

extension NFTCardViewModel {
    
    enum NFTCardError: Error {
        case cardFetchError
        case urlError
    }
}
