//
//  FIrestoreRepository.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
//import FirebaseFirestoreSwift

protocol FirestoreRepositoryDelegate: AnyObject {
    func dataChangedIndex(indices: [UInt])
}

class FirestoreRepository {

    static let shared: FirestoreRepository = FirestoreRepository()
    private init() {}
    
    weak var delegate: FirestoreRepositoryDelegate?
    
    let db = Firestore.firestore()
    
    // MARK: - Save data
   
    /// Check if document with ownerAddress exist
    /// - Parameters:
    ///   - ownerAddress: Logged in user's wallet address.
    ///   - completion: Callback
    private func checkIfSavedUser(
        ownerAddress: String,
        completion: @escaping (Result<Bool, Error>) -> ()
    ) {
        db.collection(K.FStore.nftAddressCollectionName)
            .whereField(K.FStore.actionCountFieldKey, isNotEqualTo: 0)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(.failure(FirestoreError.getDocumentsError))
                    return
                }
                let docs = snapshot.documents
                for doc in docs {
                    if doc.documentID == ownerAddress {
                        completion(.success(true))
                        return
                    }
                }
                completion(.success(false))
            }
    }
    
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
        username: String
    ) {
        self.checkIfSavedUser(ownerAddress: ownerAddress) { result in
            switch result {
            case .success(let isSaved):
                if isSaved {
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
                    return
                }
            case .failure(let error):
                print("Error checking saved user: \(error.localizedDescription)")
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
        let docRefForNftCollection = db
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
        let docRefForAddress = db
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
        let docRefForNftCollection = db
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
        let docRefForAddress = db
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
    
    // MARK: - Retrieve data
    
    /// Fetch all the document exists in `NFT collection` in firestore
    /// - Parameter completion: callback
    func getAllCards(ofCollectionType collectionType: CollectionType,
                     completion: @escaping(([Card]?) -> Void)) {
        
        let docRefForNft = db.collection(K.FStore.nftCardCollectionName)
        docRefForNft
            .addSnapshotListener { snapshot, error in
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
    
    /// Get all the NFT Collection's fields data;
    /// [Moono's, Bellygom's, ...]
    /// - Parameters:
    ///   - collectionType: NFT Collection type
    ///   - completion: callback
    func getAllCollectionFields(ofCollectionType collectionType: CollectionType,
                       completion: @escaping(([NftCollection]?) -> Void)) {
        let docRefForNft = db.collection(K.FStore.nftCardCollectionName)
        docRefForNft
            .order(by: K.FStore.popScoreFieldKey, descending: true)
            .addSnapshotListener { snapshot, error in
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
    
    func getAllAddress(completion: @escaping (([Address]?) -> Void)) {
        let docRefForAddress = db.collection(K.FStore.nftAddressCollectionName)
        docRefForAddress
            .order(by: K.FStore.popScoreFieldKey, descending: true)
            .addSnapshotListener { snapshot, error in
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
                
                self.delegate?.dataChangedIndex(indices: diffIndices)
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
    
    //Get a specific type of collection data from Nft Collection in Firestore
    func getNftCollection(ofType collectionType: CollectionType,
                          completion: @escaping ((NftCollection?) -> ())) {
        let docRefForNftCollection = db.collection(K.FStore.nftCardCollectionName)
        docRefForNftCollection
            .addSnapshotListener { snapshot, error in
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
