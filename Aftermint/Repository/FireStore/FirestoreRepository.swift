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
    
//    func saveAddress(_ address: Address, collection: NftCollection, ofType collectionType: CollectionType) {
//
//        ///1st collection
//        let docRefForAddress = db.collection(K.FStore.nftAddressCollectionName).document(address.walletAddress)
//        docRefForAddress.setData([
//            K.FStore.actionCountFieldKey: FieldValue.increment(address.actionCount),
//            K.FStore.popScoreFieldKey: FieldValue.increment(address.popScore)
//        ], merge: true)
//
//        ///2nd depth collection
//        let docRefForCollection = docRefForAddress.collection(collectionType.rawValue).document()
//        docRefForCollection.setData([
//            K.FStore.actionCountFieldKey: FieldValue.increment(collection.totalActionCount),
//            K.FStore.imageUrlFieldKey: collection.imageUrl,
//            "score": FieldValue.increment(collection.totalPopCount),
//            K.FStore.tokenIdFieldKey: collection.card.
//        ], merge: true)
//    }
    
    func getAllAddress(ofNftCollectionType collectionType: CollectionType, completion: @escaping (([Address]?) -> ())) {
        
//        let docRefForCollection = db.collection(K.FStore.nftCardCollectionName)
//        var nftCollection: [NftCollection] = []
//        docRefForCollection
//            .addSnapshotListener { snapshot, error in
//                guard let snapshot = snapshot, error == nil else {
//                    print("Error fetching cards list: \(String(describing: error))")
//                    completion(nil)
//                    return
//                }
//                let documents = snapshot.documents
//                if !documents.isEmpty {
//                    nftCollection = documents
//                        .map { doc in
//                            let data = doc.data()
//                            let documentId = doc.documentID
//                            return NftCollection(name: documentId,
//                                                 address: collectionType.rawValue,
//                                                 imageUrl: data[K.FStore.actionCountFieldKey] as? String ?? "N/A",
//                                                 totalPopCount: data[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
//                                                 totalActionCount: data[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
//                                                 card: data[K.FStore.secondDepthCollectionName] as? [Card] ?? [],
//                                                 totalNfts: 0)
//                        }
//                }
//            }
        
        let docRefForAddress = db.collection(K.FStore.nftAddressCollectionName)
        
        docRefForAddress
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let address: [Address] = documents
                        .map{ doc in
                            let data = doc.data()
                            let documentId = doc.documentID
                            return Address(ownerAddress: documentId,
                                           actionCount: data[K.FStore.actionCountFieldKey] as? Int64 ?? 0,
                                           popScore: data[K.FStore.popScoreFieldKey] as? Int64 ?? 0,
                                           collections: [])
                        }
                    completion(address)
                    return
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
