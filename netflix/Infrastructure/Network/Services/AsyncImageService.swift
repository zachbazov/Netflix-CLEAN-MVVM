//
//  AsyncImageService.swift
//  netflix
//
//  Created by Zach Bazov on 09/09/2022.
//

import UIKit

// MARK: - URLImageProtocol Type

class URLImageProtocol: URLProtocol {
    var cancelledOrComplete: Bool = false
    var block: DispatchWorkItem!
    
    private static let queue = DispatchQueue(label: "com.netflix.URLImageProtocol",
                                             qos: .userInitiated,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .workItem,
                                             target: .global(qos: .userInitiated))
    
    static func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLImageProtocol.classForCoder()]
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }
    
    // MARK: URLProtocol Lifecycle
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    class override func requestIsCacheEquivalent(_ aRequest: URLRequest, to bRequest: URLRequest) -> Bool {
        return false
    }
    
    final override func startLoading() {
        guard let reqURL = request.url, let urlClient = client else { return }
        // Allocate the work item.
        block = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // In-case the operation isn't completed or cancelled.
            if self.cancelledOrComplete == false {
                // Create the image url reference.
                let imageURL = URL(string: reqURL.absoluteString)!
                // In-case of a valid data object.
                if let data = try? Data(contentsOf: imageURL) {
                    // Inform the client that the data has been loaded.
                    urlClient.urlProtocol(self, didLoad: data)
                    // Inform the client that the data has finished loading.
                    urlClient.urlProtocolDidFinishLoading(self)
                }
            }
            // Operation has been complete.
            self.cancelledOrComplete = true
        }
        // Create a dispatch time value.
        let time = DispatchTime(uptimeNanoseconds: 500 * NSEC_PER_MSEC)
        // Execute the operation.
        URLImageProtocol.queue.asyncAfter(deadline: time, execute: block)
    }
    
    final override func stopLoading() {
        URLImageProtocol.queue.async { [weak self] in
            guard let self = self else { return }
            if self.cancelledOrComplete == false, let cancelBlock = self.block {
                // Cancel the operation.
                cancelBlock.cancel()
                self.cancelledOrComplete = true
            }
        }
    }
}

// MARK: - AsyncImageService Type

final class AsyncImageService {
    static var shared = AsyncImageService()
    private init() {}
    
    private(set) var cache = NSCache<NSString, UIImage>()
}

// MARK: - Methods

extension AsyncImageService {
    private func set(_ image: UIImage, forKey identifier: NSString) {
        cache.setObject(image, forKey: identifier)
    }
    
    func remove(for identifier: NSString) {
        cache.removeObject(forKey: identifier)
    }
    
    func object(for identifier: NSString) -> UIImage? {
        return cache.object(forKey: identifier)
    }
    
    func load(url: URL, identifier: NSString, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = object(for: identifier) {
            return DispatchQueue.global(qos: .userInitiated).async {
                completion(cachedImage)
            }
        }
        
        URLImageProtocol.urlSession().dataTask(with: url) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.set(image, forKey: identifier)
                
                completion(image)
            }
        }.resume()
    }
}
