//
//  FirebaseStorageService.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/17.
//

import Foundation

import FirebaseStorage

final class FirebaseStorageService {
    
    // MARK: - Enum
    enum FirebaseUrlPath: String {
        case font = "/font"
        case jsonTemplate = "/template/lottie_resources"
        case pngTemplate = "/template/lottie_thumbnails"
    }
    

    static let shared = FirebaseStorageService()

    private let queue = DispatchQueue(label: "StorageService", attributes: .concurrent)
    private let storage: StorageReference

    private init() {
        self.storage = Storage.storage().reference()
    }
    /// Currently not in use: Consider using this method instead of the one below
    func getFile(folderPath: FirebaseUrlPath, fileName: String, completion: @escaping (Data?) -> Void) {
        let urlString = folderPath.rawValue + "/" + fileName
        self.getFile(urlString: urlString, completion: completion)
    }

    func getFile(urlString: String, completion: @escaping (Data?) -> Void) {
        let gsReferecnce = storage.child(urlString)

        queue.async {
            gsReferecnce.getData(maxSize: 1024 * 1024 * 4) { (data, error) in
                if let error = error  {
                    print("Download template from Stoarge")
                    dump(error)
                }
                completion(data)
            }
        }
    }
}
