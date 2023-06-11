//
//  FIrestoreRepository.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation
import FirebaseCore
import FirebaseFirestore


class FirestoreRepository {
    
    static let shared: FirestoreRepository = FirestoreRepository(of: .moono)
    
    let db = Firestore.firestore()
    
    let firestoreCacheManager = FirestoreCacheManager()
    
    private var tokenIds: [String] = []
    private let baseDBPath = Firestore.firestore()
        .collection(K.FStore.rootV2Field)
        .document(K.FStore.nftScoreSystemField)
        .collection(K.FStore.nftCollectionSetField)
    
    // MARK: - Init
    let type: CollectionType
    private init(of type: CollectionType) {
        self.type = type
    }
    
}

// MARK: - Save data
extension FirestoreRepository {

    func checkIfSavedUserNew(
        ownerAddress: String,
        of gameType: GameType
    ) async -> Bool {
        
        var userExists: Bool = true
        
        do {
            userExists = try await baseDBPath
                .document(self.type.rawValue)
                .collection(K.FStore.walletAccountSetField)
                .document(ownerAddress)
                .getDocument()
                .exists
        }
        catch {
            print("Error cheching user's document: \(error)")
        }
        
        if userExists {
           return true
        } else {
            return false
        }
    }
    
    func saveScoreCache(
        of gameType: GameType,
        popScore: Int64,
        actionCount: Int64,
        ownerAddress: String
    ) async throws {
        let collectionDocRef = baseDBPath.document(self.type.rawValue)
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            // Save to cached_total_action_count_set
            group.addTask {
                collectionDocRef
                    .collection(K.FStore.cachedTotalActionCountSetField)
                    .document(gameType.rawValue)
                    .setData(
                        [
                            K.FStore.totalCountField: FieldValue.increment(actionCount)
                        ],
                        merge: true
                    )
            }
            
            // Save to cached_total_nft_score_set
            group.addTask {
                collectionDocRef
                    .collection(K.FStore.cachedTotalNftScoreSetField)
                    .document(gameType.rawValue)
                    .setData(
                        [
                            K.FStore.totalScoreField: FieldValue.increment(popScore)
                        ],
                        merge: true
                    )
            }
            
            // Save wallet_address field TODO: Need to add other fields as well.
            group.addTask {
                collectionDocRef
                    .collection(K.FStore.walletAccountSetField)
                    .document(ownerAddress)
                    .setData(
                        [
                            K.FStore.walletAddressField: ownerAddress
                        ],
                        merge: true
                    )
            }
            
            // Save to wallet_account_set
            group.addTask {
                collectionDocRef
                    .collection(K.FStore.walletAccountSetField)
                    .document(ownerAddress)
                    .collection(K.FStore.cachedTotalNftScoreSetField)
                    .document(gameType.rawValue)
                    .setData(
                        [
                            K.FStore.countField: FieldValue.increment(popScore)
                        ],
                        merge: true
                    )
            }
            
            group.addTask {
                async let _ = collectionDocRef
                    .collection(K.FStore.walletAccountSetField)
                    .document(ownerAddress)
                    .collection(K.FStore.actionCountSetField)
                    .document(gameType.rawValue)
                    .setData(
                        [
                            K.FStore.countField: FieldValue.increment(actionCount)
                        ],
                        merge: true
                    )
            }
            
        })
    }
    
    func saveNFTScores(
        of gameType: GameType,
        actionCount: Int64,
        nftTokenId: [String],
        ownerAddress: String
    ) async throws {
        
        let collectionDocRef = baseDBPath.document(self.type.rawValue)
        
        await withThrowingTaskGroup(
            of: Void.self,
            body: { group in
                // Save to nft_set collection
                for tokenId in nftTokenId {
                    let nftDocRef = collectionDocRef
                        .collection(K.FStore.nftSetField)
                        .document(String(describing: tokenId))
                    
                    group.addTask {
                        // Save wallet address field
                        nftDocRef.setData(
                            [
                                K.FStore.cachedWalletAddress: ownerAddress,
                                K.FStore.tokenIdField: tokenId
                            ],
                            merge: true
                        )
                    }
                    
                    group.addTask {
                        // Save nft score
                        nftDocRef.collection(K.FStore.nftScoreSetField)
                            .document(gameType.rawValue)
                            .setData(
                                [
                                    K.FStore.scoreField: FieldValue.increment(actionCount)
                                ],
                                merge: true
                            )
                    }
                }
            })
        
    }
    
    func saveNewUserInitialData(
        ownerAddress: String,
        gameType: GameType,
        initialScore: Int64,
        nftList: [String]
    ) async throws {
        
        async let _ = try self.saveNFTScores(
            of: .popgame,
            actionCount: initialScore,
            nftTokenId: nftList,
            ownerAddress: ownerAddress
        )
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            
            let userDoc = baseDBPath
                .document(self.type.rawValue)
                .collection(K.FStore.walletAccountSetField)
                .document(ownerAddress)

            group.addTask {
                userDoc
                    .setData([
                        K.FStore.walletAddressField: ownerAddress
                    ], merge: true)
            }
            
            group.addTask {
                userDoc.collection(K.FStore.actionCountSetField)
                    .document(gameType.rawValue)
                    .setData([
                        K.FStore.countField: FieldValue.increment(initialScore)
                    ], merge: true)
            }
            
            group.addTask {
                userDoc.collection(K.FStore.cachedTotalNftScoreSetField)
                    .document(gameType.rawValue)
                    .setData([
                        K.FStore.countField: FieldValue.increment(initialScore)
                    ], merge: true)
            }
        })
    }

}

// MARK: - Retrieve data

extension FirestoreRepository {
    
    // MARK: - Get Cards
    
    /// Get all the nft information
    /// - Parameter collectionType: NFT Collection type
    /// - Returns: Array of Cards
    func getAllCards(
        gameType: GameType
    ) async throws -> [Card]? {
        
        var cards: [Card] = []
        
        /* nft 별 점수 Dictionary 생성 */
        let ownerAddStart = CFAbsoluteTimeGetCurrent()
        var addressDictionary: [String: String] = [:]
        
        let nftDocuments = try await baseDBPath.document(self.type.rawValue)
            .collection(K.FStore.nftSetField)
            .getDocuments()
            .documents
        
        for doc in nftDocuments {
            
            let tokenId = doc.documentID
            let ownerAddress = doc.data()[K.FStore.cachedWalletAddress] as? String ?? K.FStore.noOwnerFound
            addressDictionary[tokenId] = ownerAddress
            
        }
        
        let nftScoreSetColletion = self.db
            .collectionGroup(K.FStore.nftScoreSetField)
            .order(by: K.FStore.scoreField, descending: true)
            .limit(to: 7)
        
        let groupDocuments = try await nftScoreSetColletion
            .getDocuments()
            .documents

        let ownerAddEnd = CFAbsoluteTimeGetCurrent()

        for doc in groupDocuments {

            guard doc.documentID == gameType.rawValue else {
                throw FirestoreError.gameTypeNotFound
            }

            let nftDocRef = doc.reference.parent.parent

            // 1. NFT Token id
            let nftTokenId = nftDocRef?.documentID ?? "N/A"

            // 2. Score per NFT
            let nftScoreData = doc.data()
            let score = nftScoreData[K.FStore.scoreField] as? Int64 ?? 0

            // 3. NFT Image URL
            let convertedId = nftTokenId.convertToHex() ?? "0x219"
            async let imageUri = KlaytnNftRequester.requestMoonoNftImageUrl(
                contractAddress: self.type.address,
                tokenId: convertedId
            )
            let imageUrl = await imageUri ?? "N/A"

            // 4. Owner address
            let ownerAddress = addressDictionary[nftTokenId] ?? "N/A"

            let card = Card(
                tokenId: nftTokenId,
                ownerAddress: ownerAddress,
                popScore: score,
                actionCount: 0, // TODO: DELETE this property if it is not needed.
                imageUrl: imageUrl
            )
            cards.append(card)

        }
        let end = CFAbsoluteTimeGetCurrent()

        return cards
    }
    
    // MARK: - Get Collections
    
    /// Get all the NFT Collection information.
    /// - Parameter collectionType: NFT Collection type.
    /// - Returns: An optional array of NftCollection.
    func getAllCollections(
        gameType: GameType
    ) async throws -> [NftCollection]? {
        
        var nftCollections: [NftCollection] = []
        
        async let cachedTotalNftSetDoc = db.collectionGroup(K.FStore.cachedTotalNftScoreSetField)
            .order(by: K.FStore.totalScoreField, descending: true)
            .getDocuments()
            .documents
        
        if try await cachedTotalNftSetDoc.isEmpty {
            print("Is empty")
            return nil
        }
        
        for doc in try await cachedTotalNftSetDoc {
      
            if doc.documentID != gameType.rawValue {
                continue
            }
            
            // pop score
            let gameData = doc.data()
            let totalScore = gameData[K.FStore.totalScoreField] as? Int64 ?? 0
            
            let collectionRef = doc.reference
                .parent
                .parent
            
            // action count
            async let cachedTotalActionData = collectionRef?
                .collection(K.FStore.cachedTotalActionCountSetField)
                .document(gameType.rawValue)
                .getDocument()
            
            let actionCount = try await cachedTotalActionData?[K.FStore.totalCountField] as? Int64 ?? 0
            
            // collection
            async let collectionData = collectionRef?
                .getDocument()
                .data()
            
            let contractAddress = try await collectionData?[K.FStore.contractAddressField] as? String ?? "N/A"
            let imageUrl = try await collectionData?[K.FStore.profileImageField] as? String ?? "N/A"
            let profileName = try await collectionData?[K.FStore.profileNameField] as? String ?? "N/A"
            
            // number of nfts
            async let numberOfIssuedNfts = KlaytnNftRequester
                .getNumberOfIssuedNFTs(ofCollection: contractAddress)?
                .totalSupply
                .convertToDecimal()
            guard let numberOfNfts = try await numberOfIssuedNfts else { return nil }
            
            // number of total holders
            async let numberOfTotalHolders = KlaytnNftRequester
                .getNumberOfHolders(ofCollection: contractAddress)?
                .totalHolder
            guard let numberOfHolders = try await numberOfTotalHolders else { return nil }
            
            
            let nftCollection = NftCollection(
                name: profileName,
                address: contractAddress,
                imageUrl: imageUrl,
                totalPopCount: totalScore,
                totalActionCount: actionCount,
                totalNfts: Int64(numberOfNfts),
                totalHolders: Int64(numberOfHolders)
            )
            nftCollections.append(nftCollection)
            
        }
        return nftCollections
    }
    
    func getCurrentNftCollection(
        gameType: GameType
    ) async throws -> NftCollection {

        let docRefForNftCollection = baseDBPath
            .document(self.type.rawValue)
        
        // collection info
        async let nftCollectionDocData = docRefForNftCollection
            .getDocument()
            .data()
        let imageUrl = try await nftCollectionDocData?[K.FStore.profileImageField] as? String ?? "N/A"
        let collectionName = try await nftCollectionDocData?[K.FStore.profileNameField] as? String ?? "N/A"
        let collectionAddress = try await nftCollectionDocData?[K.FStore.contractAddressField] as? String ?? "N/A"
        
        // total action count
        async let totalActionCountData = docRefForNftCollection
            .collection(K.FStore.cachedTotalActionCountSetField)
            .document(gameType.rawValue)
            .getDocument()
        let totalCount = try await totalActionCountData[K.FStore.totalCountField] as? Int64 ?? 0
        
        // total pop count
        async let totalNftScoreData = docRefForNftCollection
            .collection(K.FStore.cachedTotalNftScoreSetField)
            .document(gameType.rawValue)
            .getDocument()
        let nftTotalScore = try await totalNftScoreData[K.FStore.totalScoreField] as? Int64 ?? 0
        
        let nftCollection = NftCollection(
            name: collectionName,
            address: collectionAddress,
            imageUrl: imageUrl,
            totalPopCount: nftTotalScore,
            totalActionCount: totalCount,
            totalNfts: 0, // TODO: API call로 받아오기
            totalHolders: 0 // TODO: API call로 받아오기
        )
        
        return nftCollection
    }
    // MARK: - Get Address
    
    /// Get all the owner(address) information.
    /// - Parameters:
    ///   - collectionType: Collection type.
    ///   - gameType: Game type.
    /// - Returns: An array of Address objects.
    func getAllAddress(
        gameType: GameType
    ) async throws -> [Address]? {
        
        var addressList: [Address] = []
        
        let walletSetCollectionDocs = try await self.db
            .collectionGroup(K.FStore.walletAccountSetField)
            .getDocuments()
            .documents
        
        guard !walletSetCollectionDocs.isEmpty else {
            return nil
        }
        
        for doc in walletSetCollectionDocs {
            let docId = doc
                .reference
                .documentID
            
            // 1. profile_image_url, profile_nickname
            let walletInfoData = doc.data()
            let username = walletInfoData[K.FStore.profileNicknameField] as? String ?? "N/A"
            let imageUrl = walletInfoData[K.FStore.profileImageField] as? String ?? LeaderBoardAsset.userImagePlaceHolder.rawValue
            
            // 2. total_nft_score
            async let cachedTotalScoreData = doc.reference
                .collection(K.FStore.cachedTotalNftScoreSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            let totalScore = try await cachedTotalScoreData?[K.FStore.countField] as? Int64 ?? 0
            
            // 3. action_count
            async let actionCountSetData = doc.reference
                .collection(K.FStore.actionCountSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            let actionCount = try await actionCountSetData?[K.FStore.countField] as? Int64 ?? 0
            
            // 4. number of owned nfts
            let numberOfNfts = await withCheckedContinuation({ continuation in
                let _ = KlaytnNftRequester.requestToGetNfts(
                    contractAddress: self.type.address,
                    walletAddress: docId) { nfts, error in
                        guard let nfts = nfts else { return }
                        continuation.resume(returning: nfts.items.count)
                    }
            })
            
            let address = Address(
                ownerAddress: docId,
                actionCount: actionCount,
                popScore: totalScore,
                profileImageUrl: imageUrl,
                username: username,
                ownedNFTs: Int64(numberOfNfts)
            )
            addressList.append(address)
        }
        return addressList
    }
    
    func getAllCachedAddress(
        gameType: GameType
    ) async throws -> [Address]? {
        
        var addressList: [Address] = []
        
        let snapshots = try await db
            .collectionGroup(K.FStore.cachedTotalNftScoreSetField)
            .order(by: K.FStore.countField, descending: true)
            .getDocuments()
            .documents
       
        for snshot in snapshots {
            guard snshot.reference.documentID == gameType.rawValue else {
                throw FirestoreError.gameTypeNotFound
            }
            
            // wallet_account_set 내 document가 없는 경우 에러 throw.
            guard let wallet = snshot.reference.parent.parent else {
                throw FirestoreError.walletNotFound
            }
            let walletAddress = wallet.documentID
            
            // 1. profile_image_url, profile_nickname
            let userData = try await wallet.getDocument().data()
            let username = userData?[K.FStore.profileNicknameField] as? String ?? LeaderBoardAsset.usernamePlaceHolder.rawValue
            let imageUrl = userData?[K.FStore.profileImageField] as? String ?? LeaderBoardAsset.userImagePlaceHolder.rawValue
            
            // 2. total_nft_score
            let popgameData = snshot.data()
            let totalScore = popgameData[K.FStore.countField] as? Int64 ?? 0
            
            // 3. action_count
            async let cachedTotalScoreData = wallet
                .collection(K.FStore.actionCountSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            let actionCount = try await cachedTotalScoreData?[K.FStore.countField] as? Int64 ?? 0
            
            // 4. number of owned nfts
            let numberOfNfts = await withCheckedContinuation({ continuation in
                let _ = KlaytnNftRequester.requestToGetNfts(
                    contractAddress: self.type.address,
                    walletAddress: walletAddress) { nfts, error in
                        guard let nfts = nfts else { return }
                        continuation.resume(returning: nfts.items.count)
                    }
            })
  
            let address = Address(
                ownerAddress: walletAddress,
                actionCount: actionCount,
                popScore: totalScore,
                profileImageUrl: imageUrl,
                username: username,
                ownedNFTs: Int64(numberOfNfts)
            )
            
            addressList.append(address)
            
        }
        firestoreCacheManager.setAddressCache(for: .getAllAddress, data: addressList)
        return addressList
    }
 
    func getAllInitialAddress(
        gameType: GameType,
        currentUserAddress: String
    ) async throws -> [Address]? {
        let start = CFAbsoluteTimeGetCurrent()
        
        let cachedData = firestoreCacheManager.getAddressCache(for: .getAllAddress, key: "AddressList")
        if cachedData != nil {
            LLog.i("Using address cache...")
            return cachedData
        }
        
        /* wallet address dictionary */
        async let walletDocs = baseDBPath.document(self.type.rawValue)
            .collection(K.FStore.walletAccountSetField)
            .getDocuments()
            .documents
        
        var userNameDictionary: [String: String] = [:]
        var imageUrlDictionary: [String: String] = [:]
        var popScoreDictionary: [String: Int64] = [:]
        var actionCountDictionary: [String: Int64] = [:]
        
        for wallet in try await walletDocs {

            let address = wallet.documentID
            
            async let popScoreData = wallet.reference.collection(K.FStore.cachedTotalNftScoreSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            
            async let actionCountData = wallet.reference.collection(K.FStore.actionCountSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            
            let data = wallet.data()
            let username = data[K.FStore.profileNicknameField] as? String ?? LeaderBoardAsset.usernamePlaceHolder.rawValue
            let imageUrl = data[K.FStore.profileImageField] as? String ?? LeaderBoardAsset.userImagePlaceHolder.rawValue

            userNameDictionary[address] = username
            imageUrlDictionary[address] = imageUrl
            
            let popScore = try await popScoreData?[K.FStore.countField] as? Int64 ?? 0
            popScoreDictionary[address] = popScore
            
            let actionCount = try await actionCountData?[K.FStore.countField] as? Int64 ?? 0
            actionCountDictionary[address] = actionCount
        }
        
        var currentUserScore: Int64 = 0
        
        async let nftSet = db
            .collectionGroup(K.FStore.nftSetField)
            .getDocuments()
            .documents
        
        for doc in try await nftSet {
            let nftData = doc.data()
            // Check nft owner.
            let owner = nftData[K.FStore.cachedWalletAddress] as? String ?? "N/A"
            guard owner == currentUserAddress else {
                continue
            }

            let popgameData = try await doc.reference
                .collection(K.FStore.nftScoreSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()

            let score = popgameData?[K.FStore.scoreField] as? Int64 ?? 0
            currentUserScore += score
        }
        
        var addressList: [Address] = []
        
        async let snapshots = db
            .collectionGroup(K.FStore.cachedTotalNftScoreSetField)
            .order(by: K.FStore.countField, descending: true)
            .getDocuments()
            .documents

        for snshot in try await snapshots {
            
            guard snshot.reference.documentID == gameType.rawValue else {
                throw FirestoreError.gameTypeNotFound
            }

            // wallet_account_set 내 document가 없는 경우 에러 throw.
            guard let currentWallet = snshot.reference.parent.parent else {
                throw FirestoreError.walletNotFound
            }
            let walletAddress = currentWallet.documentID
            
            // 1. profile_image_url, profile_nickname
            let username = userNameDictionary[walletAddress] ?? "N/A"
            let imageUrl = imageUrlDictionary[walletAddress] ?? "N/A"
            
            // 2. total_nft_score
            var totalScore: Int64 = 0
            if walletAddress == currentUserAddress { // 현재 유저의 doc인 경우
                totalScore = currentUserScore
            } else {
                totalScore = popScoreDictionary[walletAddress] ?? 0
            }
            
            // 3. action_count
            let actionCount = actionCountDictionary[walletAddress] ?? 0
            
            // 4. number of owned nfts
            let numberOfNfts = await withCheckedContinuation({ continuation in
                let _ = KlaytnNftRequester.requestToGetNfts(
                    contractAddress: self.type.address,
                    walletAddress: walletAddress) { nfts, error in
                        guard let nfts = nfts else { return }
                        continuation.resume(returning: nfts.items.count)
                    }
            })
            
            let address = Address(
                ownerAddress: walletAddress,
                actionCount: actionCount,
                popScore: totalScore,
                profileImageUrl: imageUrl,
                username: username,
                ownedNFTs: Int64(numberOfNfts)
            )
            
            addressList.append(address)
            
        }
        firestoreCacheManager.setAddressCache(for: .getAllAddress, data: addressList)
        let end = CFAbsoluteTimeGetCurrent()
        print("Time for get all initial address: \(end - start)")
        return addressList
    }
    
    // MARK: - Others
    
    /// Get nft list of nfts that the current user owned.
    /// - Parameter address: User wallet address.
    /// - Returns: Set of nfts.
    func getCurrentUserOwnedNfts(_ address: String) async throws -> [String] {
        
        var ownedNfts: [String] = []
        
        async let nftSet = db
            .collectionGroup(K.FStore.nftSetField)
            .getDocuments()
            .documents
        
        for doc in try await nftSet {
            let nftData = doc.data()
            // Check nft owner.
            let owner = nftData[K.FStore.cachedWalletAddress] as? String ?? "N/A"
            guard owner == address else {
                continue
            }
            ownedNfts.append(doc.documentID)
        }
        
        return ownedNfts
    }
    
}

// MARK: - Update NFT owner address

extension FirestoreRepository {
    
    /// Update the owner of a certain NFT.
    /// - Parameters:
    ///   - tokenId: NFT token id.
    ///   - newOwnerddress: New owner's wallet address.
    func updateNftOwner(
        of tokenId: String,
        to newOwnerddress: String
    ) async {
        do {
            try await baseDBPath
                .document(self.type.rawValue)
                .collection(K.FStore.nftSetField)
                .document(tokenId)
                .setData(
                    [K.FStore.cachedWalletAddress: newOwnerddress],
                    merge: true
                )
        }
        catch {
            print("Error updating the owner of the token to \(K.FStore.nftSetField) - \(error)")
        }
    }
    
}

// MARK: - Firestore Error

extension FirestoreRepository {
    enum FirestoreError: Error {
        case getDocumentsError
        case gameTypeNotFound
        case documentFieldNotFound
        case walletNotFound
        case collectionTypeNotFoynd
    }
}
