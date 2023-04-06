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

class FirestoreRepository {

    static let shared: FirestoreRepository = FirestoreRepository()
    private init() {}
    
    let db = Firestore.firestore()
    
    ///Model 대신 property를 arguments로 받는 function으로 대체
    func save(actionCount: Int64,
              popScore: Int64,
              collectionImageUrl: String,
              nftImageUrl: String,
              nftTokenId: String,
              ownerAddress: String,
              ownerProfileImage: String,
              collectionType: CollectionType
    ) {
        ///Save NFT collection
        ///1st collection
        let docRefForNftCollection = db.collection(K.FStore.nftCardCollectionName).document(collectionType.rawValue)
        docRefForNftCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
            K.FStore.imageUrlFieldKey: collectionImageUrl,
            K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
        ], merge: true)
        
        ///2nd depth collection
        let docRefForToCollection = docRefForNftCollection.collection(K.FStore.secondDepthCollectionName).document(nftTokenId)
        docRefForToCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
            K.FStore.imageUrlFieldKey: nftImageUrl,
            K.FStore.ownerAddressFieldKey: ownerAddress,
            K.FStore.popScoreFieldKey: FieldValue.increment(popScore)
        ], merge: true)
        
        ///Save Address collection
        ///1st collection
        let docRefForAddress = db.collection(K.FStore.nftAddressCollectionName).document(ownerAddress)
        docRefForAddress.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
            K.FStore.popScoreFieldKey: FieldValue.increment(popScore),
            K.FStore.profileImageUrlFieldKey: ownerProfileImage
        ], merge: true)
        
        ///2nd depth collection
        let docRefForCollection = docRefForAddress.collection(collectionType.rawValue).document() //Autogenerate docID로 merge=true 가능?
        docRefForCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(actionCount),
            K.FStore.imageUrlFieldKey: nftImageUrl,
            K.FStore.popScoreFieldKey: FieldValue.increment(popScore),
            K.FStore.tokenIdFieldKey: nftTokenId
        ], merge: true)
    }
    
    func save(collection: NftCollection,
              card: Card,
              address: Address,
              ofType collectionType: CollectionType) {
        
        ///Save NFT collection
        ///1st collection
        let docRefForNftCollection = db.collection(K.FStore.nftCardCollectionName).document(collectionType.rawValue)
        docRefForNftCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(collection.totalActionCount),
            K.FStore.imageUrlFieldKey: collection.imageUrl,
            K.FStore.popScoreFieldKey: FieldValue.increment(collection.totalPopCount)
        ], merge: true)
        
        ///2nd depth collection
        let docRefForToCollection = docRefForNftCollection.collection(K.FStore.secondDepthCollectionName).document(card.tokenId)
        docRefForToCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(card.actionCount),
            K.FStore.imageUrlFieldKey: card.imageUrl,
            K.FStore.ownerAddressFieldKey: card.ownerAddress,
            K.FStore.popScoreFieldKey: FieldValue.increment(card.popScore)
        ], merge: true)
        
        ///Save Address collection
        ///1st collection
        let docRefForAddress = db.collection(K.FStore.nftAddressCollectionName).document(address.ownerAddress)
        docRefForAddress.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(address.actionCount),
            K.FStore.popScoreFieldKey: FieldValue.increment(address.popScore)
        ], merge: true)
        
        ///2nd depth collection
        let docRefForCollection = docRefForAddress.collection(collectionType.rawValue).document() //Autogenerate docID로 merge=true 가능?
        docRefForCollection.setData([
            K.FStore.actionCountFieldKey: FieldValue.increment(card.actionCount),
            K.FStore.imageUrlFieldKey: card.imageUrl,
            K.FStore.popScoreFieldKey: FieldValue.increment(card.popScore),
            K.FStore.tokenIdFieldKey: card.tokenId
        ], merge: true)
        
    }
    
    
    /// Fetch fields of a specific `NFT collection` type
    /// - Parameters:
    ///   - collectionType: Type of collection
    ///   - completion: callback
    func getAllNftData(ofCollectionType collectionType: CollectionType, completion: @escaping(([CardTest]?) -> Void)) {
        let mockUser = MoonoMockUserData().getOneUserData()
        
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
                        .getDocuments { snapshot, error in
                            guard let snapshot = snapshot, error == nil else {
                                completion(nil)
                                return
                            }
                            let cardDocs = snapshot.documents
                            if !cardDocs.isEmpty {
                                let result = cardDocs.map { doc in
                                    return CardTest(ownerAddress: mockUser.address,
                                                    popScore: doc[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                                                    actionCount: doc[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                                                    imageUrl: doc[K.FStore.imageUrlFieldKey] as? String ?? "N/A")
                                    
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
    
    
    /// Fetch all the document exists in `NFT collection` in firestore
    /// - Parameter completion: callback
    func getAllNftData(completion: @escaping(([CardTest]?) -> Void)) {
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
                    let result = documents.map { doc in
                        return CardTest(
                            ownerAddress: "N/A", //ownerAddress is not necessary in this case
                            popScore: doc[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                            actionCount: doc[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                            imageUrl: doc[K.FStore.imageUrlFieldKey] as? String ?? "N/A"
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
    
    func getAllAddress(completion: @escaping (([AddressTest]?) -> Void)) {
        let docRefForAddress = db.collection(K.FStore.nftAddressCollectionName)
        docRefForAddress
            .order(by: K.FStore.popScoreFieldKey, descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let result: [AddressTest] = documents.map { doc in
                        let ownerAddress = doc.documentID
                        
                        return AddressTest(
                            ownerAddress: ownerAddress,
                            actionCount: doc[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                            popScore: doc[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                            profileImageUrl: doc[K.FStore.profileImageUrlFieldKey] as? String ?? "david",
                            username: doc[K.FStore.usernameFieldKey] as? String ?? "David",
                            card: []
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
    func getNftCollection(ofType collectionType: CollectionType, completion: @escaping ((NftCollectionTest?) -> ())) {
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
                        let collection = NftCollectionTest(name: moonoDocument.documentID,
                                                           address: K.ContractAddress.moono,
                                                           imageUrl: moonoDocument[K.FStore.imageUrlFieldKey] as? String ?? "N/A",
                                                           totalPopCount: moonoDocument[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                                                           totalActionCount: moonoDocument[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                                                           totalNfts: 1000, //NOTE: Need to add to firestore later on?
                                                           totalHolders: 200) //NOTE: Need to add to firestore later on?
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
    
//    func getAllCard(completion: @escaping (([Card]?) -> ())) {
//
//        let docRefForCard = db.collection(K.FStore.nftCardCollectionName)
//        
//        docRefForCard
//            .order(by: K.FStore.countFieldKey, descending: true)
//            .addSnapshotListener { snapshot, error in
//                guard let snapshot = snapshot, error == nil else {
//                    print("Error fetching cards list: \(String(describing: error))")
//                    completion(nil)
//                    return
//                }
//                
//                let documents = snapshot.documents
//                if !documents.isEmpty {
//                    let result: [Card] = documents
//                        .map { doc in
//                        let data = doc.data()
//                        let documentId = doc.documentID
//                        let nftName = documentId.replacingOccurrences(of: "___", with: " #")
//                            
//                        return Card(imageUri: data[K.FStore.imageUriFieldKey] as? String ?? "N/A",
//                                    collectionId: K.ContractAddress.moono,
//                                    tokenId: nftName,
//                                    count: data[K.FStore.countFieldKey] as? Int64 ?? 0)
//                    }
// 
//                    completion(result)
//                    return
//                } else {
//                    completion(nil)
//                }
//            }
//    }
  
}
