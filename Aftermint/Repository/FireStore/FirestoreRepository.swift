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
    
    func saveCard(_ card: Card) {
        let docRefForCard = db.collection(K.FStore.nftCardCollectionName).document(card.tokenId)
        /// Save card data
        docRefForCard.setData([
            K.FStore.imageUriFieldKey: card.imageUri,
            K.FStore.countFieldKey: FieldValue.increment(card.count)
        ], merge: true)
        
    }
    
    func saveCollection(_ collection: NftCollection) {
        let docRefForCollection = db.collection(K.FStore.nftCollectionCollectionName).document(K.FStore.nftCollectionDocumentName)
        
        docRefForCollection.setData([
            K.FStore.countFieldKey: FieldValue.increment(collection.count)
        ], merge: true)
    }
    
    
    func getAllCard(completion: @escaping (([Card]?) -> ())) {

        let docRefForCard = db.collection(K.FStore.nftCardCollectionName)
        
        docRefForCard
            .order(by: K.FStore.countFieldKey, descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching cards list: \(String(describing: error))")
                    completion(nil)
                    return
                }
                
                let documents = snapshot.documents
                if !documents.isEmpty {
                    let result: [Card] = documents
                        .map { doc in
                        let data = doc.data()
                        let documentId = doc.documentID
                        let nftName = documentId.replacingOccurrences(of: "___", with: " #")
                            
                        return Card(imageUri: data[K.FStore.imageUriFieldKey] as? String ?? "N/A",
                                    collectionId: K.ContractAddress.moono,
                                    tokenId: nftName,
                                    count: data[K.FStore.countFieldKey] as? Int64 ?? 0)
                    }
 
                    completion(result)
                    return
                } else {
                    completion(nil)
                }
            }
    }
  
}
