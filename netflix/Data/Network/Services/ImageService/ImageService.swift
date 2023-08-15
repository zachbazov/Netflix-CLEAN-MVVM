//
//  ImageService.swift
//  netflix
//
//  Created by Zach Bazov on 09/09/2022.
//

import UIKit

// MARK: - ImageService Type

final class ImageService {
    private var session: URLSession
    
    private(set) var cache = NSCache<NSString, UIImage>()
    
    init(urlService: URLImageService) {
        self.session = urlService.urlSession()
    }
}

// MARK: - URLImageTasking Implementation

extension ImageService: URLImageTasking {
    func load(url: URL, identifier: NSString, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(for: identifier) {
            mainQueueDispatch {
                completion(cachedImage)
            }
            
            return
        }
        
        session.dataTask(with: url) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return completion(nil)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.cache.set(image, forKey: identifier)
                
                mainQueueDispatch {
                    completion(image)
                }
            }
        }.resume()
    }
}
