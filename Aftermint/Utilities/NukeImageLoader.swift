//
//  NukeImageLoader.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/03/13.
//

import UIKit.UIImage
import Nuke

struct NukeImageLoader {
    
    static func loadImageUsingNuke(url: URL?, completion: @escaping (UIImage) -> ()) {
        guard let url = url else { return }
        
        ImagePipeline.shared.loadImage(with: url) { result in
            switch result {
            case .success(let imageResponse):
                completion(imageResponse.image)
                return
            case .failure(let failure):
                print("Nuke load image failed: \(failure)")
            }
        }
    }
    
}
