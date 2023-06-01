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
        collectionType: CollectionType,
        totalHolders: Int64,
        totalMintedNFTs: Int64
    ) {
        
        let docRefForNftCollection = self.db
            .collection(K.FStore.nftCardCollectionName)
            .document(collectionType.rawValue)
        
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
    
    /// Save to firestore
    func save(
        actionCount: Int64,
        popScore: Int64,
        nftImageUrl: String,
        nftTokenId: String,
        ownerAddress: String,
        collectionType: CollectionType
    ) {
        
        ///Save NFT collection
        ///1st collection
        let docRefForNftCollection = self.db
            .collection(K.FStore.nftCardCollectionName)
            .document(collectionType.rawValue)
        
        docRefForNftCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
            K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
        ], merge: true)
        
        ///2nd depth collection
        let docRefForToCollection = docRefForNftCollection
            .collection(K.FStore.secondDepthCollectionName)
            .document(nftTokenId)
        
        docRefForToCollection.getDocument { document, error in
            guard let document = document else {
                return
            }
            guard document.exists else {
                docRefForToCollection.setData([
                    K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
                    K.FStore.imageUrlFieldKey: nftImageUrl,
                    K.FStore.ownerAddressFieldKey: ownerAddress,
                    K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
                ], merge: true)
                return
            }
            
            docRefForToCollection.updateData([
                K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
                K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
            ])
        }
        
        ///Save Address collection
        ///1st collection
        let docRefForAddress = self.db
            .collection(K.FStore.nftAddressCollectionName)
            .document(ownerAddress)
        
        docRefForAddress.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
            K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
        ], merge: true)
        
        ///2nd depth collection
        let docRefForCollection = docRefForAddress
            .collection(collectionType.rawValue)
            .document(nftTokenId)
        
        docRefForCollection.getDocument { document, error in
            guard let document = document else {
                return
            }
            
            /// When there is no document named with tokenId exist
            guard document.exists else {
                docRefForCollection.setData([
                    K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
                    K.FStore.imageUrlFieldKey: nftImageUrl,
                    K.FStore.popScoreFieldKey: FieldValue.increment(popScore),
                    K.FStore.tokenIdFieldKey: nftTokenId
                ], merge: true)
                return
            }
            
            /// When there is document named with tokenId exist
            docRefForCollection.updateData([
                K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
                K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
            ])
        }
    }
    
    func saveScoreCache(
        popScore: Int64,
        actionCount: Int64,
        ownerAddress: String,
        completion: @escaping (() -> Void)
    ) {
        let group = DispatchGroup()
        let collectionDocRef = baseDBPath.document(self.type.rawValue)
        
        // Save to cached_total_action_count_set
        group.enter()
        collectionDocRef
            .collection(K.FStore.cachedTotalActionCountSetField)
            .document(K.FStore.popgameField)
            .setData(
                [
                    K.FStore.totalCountField: FieldValue.increment(actionCount)
                ],
                merge: true
            )
        group.leave()
        
        // Save to cached_total_nft_score_set
        group.enter()
        collectionDocRef
            .collection(K.FStore.cachedTotalNftScoreSetField)
            .document(K.FStore.popgameField)
            .setData(
                [
                    K.FStore.totalScoreField: FieldValue.increment(popScore)
                ],
                merge: true
            )
        group.leave()
        
        group.enter()
        collectionDocRef
            .collection(K.FStore.walletAccountSetField)
            .document(ownerAddress)
            .setData(
                [
                    "wallet_address": ownerAddress
                ],
                merge: true
            )
        group.leave()
        
        // Save to wallet_account_set
        group.enter()
        collectionDocRef
            .collection(K.FStore.walletAccountSetField)
            .document(ownerAddress)
            .collection(K.FStore.cachedTotalNftScoreSetField)
            .document(K.FStore.popgameField)
            .setData(
                [
                    K.FStore.countField: FieldValue.increment(actionCount)
                ],
                merge: true
            )
        group.leave()
        
        group.enter()
        collectionDocRef
            .collection(K.FStore.walletAccountSetField)
            .document(ownerAddress)
            .collection(K.FStore.actionCountSetField)
            .document(K.FStore.popgameField)
            .setData(
                [
                    K.FStore.countField: FieldValue.increment(actionCount)
                ],
                merge: true
            )
        group.leave()
    }
    
    func saveNFTScores(
        actionCount: Int64,
        nftTokenId: [String],
        ownerAddress: String,
        completion: @escaping (() -> Void)
    ) {
        let group = DispatchGroup()
        let collectionDocRef = baseDBPath.document(self.type.rawValue)
        
        // Save to nft_set collection
        nftTokenId.forEach { tokenId in
            guard let decimalTokenId = tokenId.convertToDecimal() else { return }
      
            let nftDocRef = collectionDocRef
                .collection(K.FStore.nftSetField)
                .document(String(describing: decimalTokenId))
            
            // Save wallet address field
            group.enter()
            nftDocRef.setData(
                [
                    K.FStore.cachedWalletAddress: ownerAddress,
                    K.FStore.tokenIdField: decimalTokenId
                ],
                merge: true
            )
            group.leave()
            
            // Save nft score
            group.enter()
            nftDocRef.collection(K.FStore.nftScoreSetField)
                .document(K.FStore.popgameField)
                .setData(
                    [
                        K.FStore.scoreField: FieldValue.increment(actionCount)
                    ],
                    merge: true
                ) 
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    
    // MARK: - Retrieve data
    
    func getAllCards(ofCollectionType collectionType: CollectionType) async throws -> [Card]? {
        var cards: [Card] = []
        
        let collectionRefForNft = self.db
            .collection(K.FStore.rootV2Field)
            .document(K.FStore.nftScoreSystemField)
            .collection(K.FStore.nftCollectionSetField)
            .document(collectionType.rawValue)
            .collection(K.FStore.nftSetField)
        
        let documents = try await collectionRefForNft
            .getDocuments()
            .documents

        tokenIds = documents.map { snapshot in
            snapshot.documentID
        }
    
        for id in tokenIds {
            
            let docRef = collectionRefForNft
                .document(id)
            
            async let nftInfoData = docRef
                .getDocument()
                .data()
            
            async let nftScoreData = docRef
                .collection(K.FStore.nftScoreSetField)
                .document(K.FStore.popgameField)
                .getDocument()
                .data()
            
            let convertedId = id.convertToHex() ?? "0x219"
            async let imageUri = KlaytnNftRequester.requestMoonoNftImageUrl(
                contractAddress: collectionType.address,
                tokenId: convertedId
            )

            let ownerAddress = try await nftInfoData?[K.FStore.cachedWalletAddress] as? String ?? "N/A"
            let score = try await nftScoreData?[K.FStore.scoreField] as? Int64 ?? 0
            let imageUrl = await imageUri ?? "N/A"

            let card = Card(
                tokenId: id,
                ownerAddress: ownerAddress,
                popScore: score, // TODO: DELETE this property if it is not needed.
                actionCount: 0,
                imageUrl: imageUrl
            )
            cards.append(card)
        }
        
        return cards
    }
    
    /// Fetch all the document exists in `NFT collection` in firestore
    /// - Parameter completion: callback
    func getAllCardsFromOldScheme(ofCollectionType collectionType: CollectionType,
                     completion: @escaping(([Card]?) -> Void)) {
        
        let docRefForNft = self.db.collection(K.FStore.nftCardCollectionName)
        docRefForNft
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let filteredDocs = documents.filter { doc in
                        doc.documentID == collectionType.rawValue
                    }
                    let docRef = filteredDocs.first
                    docRef?
                        .reference
                        .collection(K.FStore.secondDepthCollectionName)
                        .order(by: K.FStore.popScoreFieldKey, descending: true)
                        .getDocuments { snapshot, error in
                            guard let snapshot = snapshot, error == nil else {
                                completion(nil)
                                return
                            }
                            let cardDocs = snapshot.documents
                            if !cardDocs.isEmpty {
                                let result = cardDocs.map { doc in
                                    // TODO: replacingOccurrences 필요한지 확인해보기
                                    let nftName = doc.documentID.replacingOccurrences(of: "___", with: "#")
                                    return Card(
                                        tokenId: nftName,
                                        ownerAddress: doc[K.FStore.ownerAddressFieldKey] as? String ?? "N/A",
                                        popScore: doc[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                                        actionCount: doc[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                                        imageUrl: doc[K.FStore.imageUrlFieldKey] as? String ?? "N/A"
                                    )
                                    
                                }
                                completion(result)
                            } else {
                                completion(nil)
                                return
                            }
                        }
                    
                } else {
                    completion(nil)
                    return
                }
            }
    }
    
    // NEW SCHEME
    func getAllCollectionFields2(ofCollectionType collectionType: CollectionType) async throws -> [NftCollection]? {
        var documentIds: [String] = []
        var imageUrls: [String] = []
        var profileNames: [String] = []
        var contractAddress: [String] = []
        var nftCollections: [NftCollection] = []
        
        let nftCollectionRef = self.db.collection(K.FStore.rootV2Field)
            .document(K.FStore.nftScoreSystemField)
            .collection(K.FStore.nftCollectionSetField)
        
        let nftCollectionDocRef = try await nftCollectionRef.getDocuments()
        
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
            async let actionCountData = nftCollectionRef
                .document(collection)
                .collection(K.FStore.cachedTotalActionCountSetField)
                .document(K.FStore.popgameField)
                .getDocument()
                .data()
            
            async let totalNftScore =  nftCollectionRef
                .document(collection)
                .collection(K.FStore.cachedTotalNftScoreSetField)
                .document(K.FStore.popgameField)
                .getDocument()
                .data()
            
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
                totalNfts: 0, //TODO: API call
                totalHolders: 0 //TODO: API call
            )
            nftCollections.append(nftCollection)
        }
        
        return nftCollections
    }
    
    // OLD SCHEME
    /// Get all the NFT Collection's fields data;
    /// [Moono's, Bellygom's, ...]
    /// - Parameters:
    ///   - collectionType: NFT Collection type
    ///   - completion: callback
    func getAllCollectionFieldsFromOldScheme(ofCollectionType collectionType: CollectionType,
                                completion: @escaping(([NftCollection]?) -> Void)) {
        
        let docRefForNft = self.db.collection(K.FStore.nftCardCollectionName)
        docRefForNft
            .order(by: K.FStore.popScoreFieldKey, descending: true)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let result = documents.map { doc in
                        
                        return NftCollection(
                            name: doc.documentID,
                            address: K.ContractAddress.moono,
                            imageUrl: doc[K.FStore.imageUrlFieldKey] as? String ?? "N/A",
                            totalPopCount: doc[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                            totalActionCount: doc[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                            totalNfts: doc[K.FStore.totalMintedNFTsFieldKey] as? Int64 ?? 0,
                            totalHolders: doc[K.FStore.totalHolderFieldKey] as? Int64 ?? 0
                        )
                        
                    }
                    completion(result)
                    return
                } else { // when documents array is empty
                    completion(nil)
                    return
                }
            }
    }
    
    // NEW SCHEME
    func getAllAddress(completion: @escaping (([Address]?) -> Void)) {
        let group = DispatchGroup()
        
        let collectionRef = self.db.collection(K.FStore.rootV2Field)
            .document(K.FStore.nftScoreSystemField)
            .collection(K.FStore.nftCollectionSetField)
            .document(CollectionType.moono.rawValue)
            .collection(K.FStore.walletAccountSetField)
            
        var docIDs: [String] = []
        group.enter()
        collectionRef.getDocuments { snapshot, error in
            guard error == nil,
                  let snapshot = snapshot else {
                return
            }
            let documents = snapshot.documents
            if !documents.isEmpty {
                docIDs = documents.map { doc in
                    doc.documentID
                }
            }
            group.leave()
        }
  
        var addressList: [Address] = []
        var actionCount: Int64 = 0
        var popScore: Int64 = 0
        group.notify(queue: .global()) {
            docIDs.forEach { walletAddress in
                group.enter()
                let docRef = collectionRef.document(walletAddress)
                docRef.collection(K.FStore.cachedTotalNftScoreSetField)
                    .document(K.FStore.popgameField)
                    .getDocument { snapshot, error in
                        group.leave()
                        guard error == nil,
                              let snapshot = snapshot else {
                            return
                        }
                        let data = snapshot.data()
                        let count = data?[K.FStore.countField] as? Int64 ?? 0
                        actionCount = count
                    }
                
                group.enter()
                docRef.collection(K.FStore.actionCountSetField)
                    .document(K.FStore.popgameField)
                    .getDocument { snapshot, error in
                        group.leave()
                        guard error == nil,
                              let snapshot = snapshot else {
                            return
                        }
                        let data = snapshot.data()
                        let count = data?[K.FStore.countField] as? Int64 ?? 0
                        popScore = count
                    }
                group.wait()
                let address = Address(
                    ownerAddress: walletAddress,
                    actionCount: actionCount,
                    popScore: popScore,
                    profileImageUrl: "no image url",
                    username: "no username",
                    ownedNFTs: 0
                )
                addressList.append(address)
            }
            group.notify(queue: .main) {
                completion(addressList)
            }
        }
        
    }
    
    // OLD SCHEME
    func getAllAddressFromOldScheme(completion: @escaping (([Address]?) -> Void)) {
        
        let docRefForAddress = self.db.collection(K.FStore.nftAddressCollectionName)
        docRefForAddress
            .order(by: K.FStore.popScoreFieldKey, descending: true)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                
                /// ============================= Adding delegate function ===================
                var diffIndices: [UInt] = []
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .modified) {
                        diffIndices.append(diff.newIndex)
                        print("Modified data new index: \(diff.newIndex)")
                    }
                }
                
                /// ================================================================
                
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let result: [Address] = documents.map { doc in
                        let ownerAddress = doc.documentID
                        
                        return Address(
                            ownerAddress: ownerAddress,
                            actionCount: doc[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                            popScore: doc[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                            profileImageUrl: doc[K.FStore.profileImageUrlFieldKey] as? String ?? LoginAsset.userPlaceHolderImage.rawValue,
                            username: doc[K.FStore.usernameFieldKey] as? String ?? "David",
                            ownedNFTs: doc[K.FStore.ownedNFTsFieldKey] as? Int64 ?? 0
                        )
                    }
                    completion(result)
                    return
                } else {
                    completion(nil)
                    return
                }
            }
    }
    
    // NEW SCHEME
    func getNftCollection(ofType collectionType: CollectionType,
                          completion: @escaping ((NftCollection?) -> ())) {
        
        var imageUrl: String = ""
        var collectionName: String = ""
        var collectionAddress: String = ""
        var totalCount: Int64 = 0
        var totalScore: Int64 = 0
        
        let group = DispatchGroup()
        
        let docRefForNftCollection = self.db.collection(K.FStore.rootV2Field)
            .document(K.FStore.nftScoreSystemField)
            .collection(K.FStore.nftCollectionSetField)
            .document(collectionType.rawValue)
        
        // collection info
        group.enter()
        docRefForNftCollection.getDocument { snapshot, error in
            group.leave()
            guard error == nil,
                  let snapshot = snapshot else {
                return
            }
            let data = snapshot.data()
            imageUrl = data?[K.FStore.profileImageField] as? String ?? "N/A"
            collectionName = data?[K.FStore.profileNameField] as? String ?? "N/A"
            collectionAddress = data?[K.FStore.contractAddressField] as? String ?? "N/A"
        }
            
        // total action count
        group.enter()
        docRefForNftCollection.collection(K.FStore.cachedTotalActionCountSetField)
            .document(K.FStore.popgameField)
            .getDocument { snapshot, error in
                group.leave()
                guard error == nil,
                      let snapshot = snapshot else {
                    return
                }
                let data = snapshot.data()
                totalCount = data?[K.FStore.totalCountField] as? Int64 ?? 0
            }
        
        // total pop count
        group.enter()
        docRefForNftCollection.collection(K.FStore.cachedTotalNftScoreSetField)
            .document(K.FStore.popgameField)
            .getDocument { snapshot, error in
                group.leave()
                guard error == nil,
                      let snapshot = snapshot else {
                    return
                }
                let data = snapshot.data()
                totalScore = data?[K.FStore.totalScoreField] as? Int64 ?? 0
            }
        
        group.notify(queue: .global()) {
            print("Collection: \(totalCount), \(totalScore)")
            let nftCollection = NftCollection(
                name: collectionName,
                address: collectionAddress,
                imageUrl: imageUrl,
                totalPopCount: totalScore,
                totalActionCount: totalCount,
                totalNfts: 0, // TODO: API call로 받아오기
                totalHolders: 0 // TODO: API call로 받아오기
            )
            completion(nftCollection)
        }
        
    }
    
    // OLD SCHEME
    //Get a specific type of collection data from Nft Collection in Firestore
    func getNftCollectionFromOldScheme(ofType collectionType: CollectionType,
                          completion: @escaping ((NftCollection?) -> ())) {
        
        let docRefForNftCollection = self.db.collection(K.FStore.nftCardCollectionName)
        docRefForNftCollection
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let moonoDocuments = documents.filter { doc in
                        return doc.documentID.uppercased() == collectionType.rawValue.uppercased()
                    }
                    if !moonoDocuments.isEmpty {
                        let moonoDocument = moonoDocuments[0]
                        ///TODO: Currently Fetching Moono Collection Data => Need to generalize this
                        let collection = NftCollection(name: moonoDocument.documentID,
                                                       address: K.ContractAddress.moono,
                                                       imageUrl: moonoDocument[K.FStore.imageUrlFieldKey] as? String ?? "N/A",
                                                       totalPopCount: moonoDocument[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                                                       totalActionCount: moonoDocument[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                                                       totalNfts: moonoDocument[K.FStore.totalMintedNFTsFieldKey] as? Int64 ?? 0,
                                                       totalHolders: moonoDocument[K.FStore.totalHolderFieldKey] as? Int64 ?? 0)
                        completion(collection)
                        return
                    } else {
                        completion(nil)
                        return
                    }
                    
                } else {
                    completion(nil)
                    return
                }
            }
    }
}

extension FirestoreRepository {
    enum FirestoreError: Error {
        case getDocumentsError
    }
}
