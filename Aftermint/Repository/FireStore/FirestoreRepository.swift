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
    
    // MARK: - Save data
    
    
    /// Check if document with ownerAddress exist
    /// - Parameters:
    ///   - ownerAddress: Logged in user's wallet address.
    ///   - completion: Callback
    private func checkIfSavedUser(
        ownerAddress: String,
        completion: @escaping (Result<Bool, Error>) -> ()
    ) {
        
        let docRef = self.db.collection(K.FStore.nftAddressCollectionName).document(ownerAddress)
        docRef.getDocument { snapshot, error in
            
            guard error == nil else {
                completion(.failure(FirestoreError.getDocumentsError))
                return
            }
            
            if let document = snapshot, document.exists {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
        
    }
    
    /// Currently not in use.
    func saveUsername(
        ownerAddress: String,
        username: String
    ) {
        
        let docRefForAddress = self.db
            .collection(K.FStore.nftAddressCollectionName)
            .document(ownerAddress)
        
        docRefForAddress.setData([
            K.FStore.usernameFieldKey: username
        ], merge: true)
        
    }
    
    /// Save base firestore fields which are saved under documents of `Address` collection
    /// - Parameters:
    ///   - ownerAddress: Logged in user's wallet address. Set this as the name of document under Address
    ///   - username: Logged in user's username.
    func saveAddressBaseFields(
        ownerAddress: String,
        username: String,
        completion: @escaping ((Bool) -> Void)
    ) {
        self.checkIfSavedUser(ownerAddress: ownerAddress) { result in
            
            switch result {
            case .success(let isSaved):
                if isSaved {
                    completion(true)
                    return
                } else {
                    let docRefForAddress = self.db
                        .collection(K.FStore.nftAddressCollectionName)
                        .document(ownerAddress)
                    
                    docRefForAddress.setData([
                        K.FStore.usernameFieldKey: username,
                        K.FStore.popScoreFieldKey: 0,
                        K.FStore.actionCountFieldKey: 0
                    ], merge: true)
                    
                    completion(true)
                    return
                }
            case .failure(let error):
                print("Error checking saved user: \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        
    }
    
    /// Save total numbers of holders and total number of minted NFTS of a certain NFT collection
    func saveNumberOfHoldersAndMintedNfts(
        totalHolders: Int64,
        totalMintedNFTs: Int64
    ) {
        
        let docRefForNftCollection = self.db
            .collection(K.FStore.nftCardCollectionName)
            .document(self.type.rawValue)
        
        docRefForNftCollection.setData([
            K.FStore.totalHolderFieldKey: totalHolders,
            K.FStore.totalMintedNFTsFieldKey: totalMintedNFTs,
        ], merge: true)
        
    }
    
    /// Save total numbers of NFTs an owner has
    func saveTotalNumbersOfNFTs(
        ofOwner ownerAddress: String,
        ownedNFTs: Int64
    ) {
        
        let docRefForAddress = self.db
            .collection(K.FStore.nftAddressCollectionName)
            .document(ownerAddress)
        
        docRefForAddress.setData([
            K.FStore.ownedNFTsFieldKey: ownedNFTs
        ], merge: true)
        
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
                            "wallet_address": ownerAddress
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
                            K.FStore.countField: FieldValue.increment(actionCount)
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
                    guard let decimalTokenId = tokenId.convertToDecimal() else { return }
                    let nftDocRef = collectionDocRef
                        .collection(K.FStore.nftSetField)
                        .document(String(describing: decimalTokenId))
                    
                    group.addTask {
                        // Save wallet address field
                        nftDocRef.setData(
                            [
                                K.FStore.cachedWalletAddress: ownerAddress,
                                K.FStore.tokenIdField: decimalTokenId
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

    // MARK: - Retrieve data
    
    /// Get all the nft information
    /// - Parameter collectionType: NFT Collection type
    /// - Returns: Array of Cards
    func getAllCards(
        gameType: GameType
    ) async throws -> [Card]? {
        let start = CFAbsoluteTimeGetCurrent()

        var cards: [Card] = []

        let nftScoreSetColletion = self.db
            .collectionGroup(K.FStore.nftScoreSetField)
            .order(by: K.FStore.scoreField, descending: true)
        
        let groupSnapshot = try await nftScoreSetColletion.getDocuments()
   
        let groupDocuments = groupSnapshot.documents
        
        for doc in groupDocuments {
            let nftDocRef = doc.reference.parent.parent
            
            // 1. NFT Token id
            let nftTokenId = nftDocRef?.documentID ?? "N/A"
            
            // 2. Score per NFT
            guard doc.documentID == gameType.rawValue else {
                throw FirestoreError.gameTypeNotFound
            }
            let nftScoreData = doc.data()
            let score = nftScoreData[K.FStore.scoreField] as? Int64 ?? 0
            
            // 3. NFT Image URL
            let convertedId = nftTokenId.convertToHex() ?? "0x219"
            async let imageUri = KlaytnNftRequester.requestMoonoNftImageUrl(
                contractAddress: self.type.address,
                tokenId: convertedId
            )
            
            // 4. Owner address per NFT
            async let nftInfoData = nftDocRef?.getDocument().data()
            
            let imageUrl = await imageUri ?? "N/A"
            let ownerAddress = try await nftInfoData?[K.FStore.cachedWalletAddress] as? String ?? "N/A"
            
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

        print("Time consumed: \(end - start)")
        return cards
    }
 
    
    /// Get all the NFT Collection information.
    /// - Parameter collectionType: NFT Collection type.
    /// - Returns: An optional array of NftCollection.
    func getAllCollectionFields(gameType: GameType) async throws -> [NftCollection]? {
        var documentIds: [String] = []
        var imageUrls: [String] = []
        var profileNames: [String] = []
        var contractAddress: [String] = []
        var nftCollections: [NftCollection] = []
        
        let nftCollectionDocRef = try await baseDBPath.getDocuments()
        
        let documentSnapshots = nftCollectionDocRef.documents
        
        // Retrieve NFT collection info
        documentSnapshots.forEach { snapshot in
            let data = snapshot.data()
            documentIds.append(snapshot.documentID)
            imageUrls.append(data[K.FStore.profileImageField] as? String ?? "N/A")
            profileNames.append(data[K.FStore.profileNameField] as? String ?? "N/A")
            contractAddress.append(data[K.FStore.contractAddressField] as? String ?? "N/A")
        }
        
        // Retrieve NFT collection scores
        for i in 0..<documentIds.count {
            let collection = documentIds[i]
            async let actionCountData = baseDBPath
                .document(collection)
                .collection(K.FStore.cachedTotalActionCountSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            
            async let totalNftScore = baseDBPath
                .document(collection)
                .collection(K.FStore.cachedTotalNftScoreSetField)
                .document(gameType.rawValue)
                .getDocument()
                .data()
            
            async let collectionData = baseDBPath
                .document(collection)
                .getDocument()
                .data()
            let collectionAddress = try await collectionData?[K.FStore.contractAddressField] as? String
            guard let collectionAddress = collectionAddress else {
                throw FirestoreError.documenetFieldNotFound
            }
            
            async let numberOfIssuedNfts = KlaytnNftRequester
                .getNumberOfIssuedNFTs(ofCollection: collectionAddress)?
                .totalSupply
                .convertToDecimal()
            guard let numberOfNfts = try await numberOfIssuedNfts else { return nil }
            
            async let numberOfTotalHolders = KlaytnNftRequester
                .getNumberOfHolders(ofCollection: collectionAddress)?
                .totalHolder
            guard let numberOfHolders = try await numberOfTotalHolders else { return nil }
            
            let collectionName = profileNames[i]
            let imagUrl = imageUrls[i]
            let contractAddress = contractAddress[i]
            let actionCount = try await actionCountData?[K.FStore.totalCountField] as? Int64 ?? 0
            let totalScore = try await totalNftScore?[K.FStore.totalScoreField] as? Int64 ?? 0
            
            let nftCollection = NftCollection(
                name: collectionName,
                address: contractAddress,
                imageUrl: imagUrl,
                totalPopCount: totalScore,
                totalActionCount: actionCount,
                totalNfts: Int64(numberOfNfts),
                totalHolders: Int64(numberOfHolders)
            )
            nftCollections.append(nftCollection)
        }
        
        return nftCollections
    }
    
    
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
            let imageUrl = walletInfoData[K.FStore.profileImageField] as? String ?? "N/A"
            
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

}

extension FirestoreRepository {
    enum FirestoreError: Error {
        case getDocumentsError
        case gameTypeNotFound
        case documenetFieldNotFound
    }
}

extension FirestoreRepository {
    
    // TODO: 아래와 같은 쿼리로 정렬하기 | action count 정렬은 또 별도로 읽어옴?
    func getGameScoreFromGroup(_ gameType: GameType) async throws {
        let snapshots = try await db
            .collectionGroup(K.FStore.cachedTotalNftScoreSetField)
            .order(by: K.FStore.countField, descending: true)
            .getDocuments()
            .documents
       
        for snshot in snapshots {
            
            let cachedTotalNftScoreSet = snshot.reference.parent
            let documents = try await cachedTotalNftScoreSet.getDocuments().documents
            
            let filteredDocument = documents.filter { snapshot in
                snapshot.documentID == gameType.rawValue
            }
            // 현재 function에서 필요한 GameType document가 없는 경우 에러 throw.
            guard !filteredDocument.isEmpty,
                  let currentGameDoc = filteredDocument.first
            else {
                throw FirestoreError.gameTypeNotFound
            }
            
            let walletAddress = currentGameDoc.reference.parent.parent?.documentID
            let popgameData = currentGameDoc.data()
            let count = popgameData[K.FStore.countField] as? Int64 ?? 0
            
            print("Address: \(walletAddress) -- Count: \(count)")
            
        }
        
    }
    
}
