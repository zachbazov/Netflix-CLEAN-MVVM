//
//  AsyncImageFetcher.swift
//  netflix
//
//  Created by Zach Bazov on 09/09/2022.
//

import UIKit

private protocol FetcherInput {
    static func urlSession() -> URLSession
    func set(in cache: AsyncImageFetcher.Cache, _ image: UIImage, forKey identifier: NSString)
    func remove(in cache: AsyncImageFetcher.Cache, for identifier: NSString)
    func object(in cache: AsyncImageFetcher.Cache, for identifier: NSString) -> UIImage?
    func load(in cache: AsyncImageFetcher.Cache, url: URL, identifier: NSString, completion: @escaping (UIImage?) -> Void)
}

private protocol FetcherOutput {
    static var shared: AsyncImageFetcher { get }
    var cache: NSCache<NSString, UIImage> { get }
    var queue: OS_dispatch_queue_serial { get }
}

private typealias Fetcher = FetcherInput & FetcherOutput

final class AsyncImageFetcher: Fetcher {
    static var shared = AsyncImageFetcher()
    
    fileprivate(set) var cache = NSCache<NSString, UIImage>()
    fileprivate(set) var searchCache = NSCache<NSString, UIImage>()
    fileprivate(set) var newsCache = NSCache<NSString, UIImage>()
    fileprivate let queue = OS_dispatch_queue_serial(label: "com.netflix.utils.async-image-fetcher")
    
    private init() {}
    
    fileprivate static func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 60
        return URLSession(configuration: config)
    }
    
    fileprivate func set(in cache: Cache, _ image: UIImage, forKey identifier: NSString) {
        if case .home = cache {  self.cache.setObject(image, forKey: identifier) }
        else if case .search = cache { searchCache.setObject(image, forKey: identifier) }
        else { newsCache.setObject(image, forKey: identifier) }
    }
    
    func remove(in cache: Cache, for identifier: NSString) {
        if case .home = cache { self.cache.removeObject(forKey: identifier) }
        else if case .search = cache { searchCache.removeObject(forKey: identifier) }
        else { newsCache.removeObject(forKey: identifier) }
    }
    
    func object(in cache: Cache, for identifier: NSString) -> UIImage? {
        if case .home = cache { return self.cache.object(forKey: identifier) }
        else if case .search = cache { return searchCache.object(forKey: identifier) }
        else { return newsCache.object(forKey: identifier) }
    }
    
    func load(in cache: Cache, url: URL, identifier: NSString, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = object(in: cache, for: identifier) {
            return queue.async { completion(cachedImage) }
        }
        
        AsyncImageFetcher.urlSession().dataTask(with: url) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let httpURLResponse = response as? HTTPURLResponse,
                  let mimeType = response?.mimeType,
                  let data = data,
                  let image = UIImage(data: data),
                  httpURLResponse.statusCode == 200,
                  mimeType.hasPrefix("image") else {
                return
            }
            self.set(in: cache, image, forKey: identifier)
            self.queue.async { completion(image) }
        }.resume()
    }
}

extension AsyncImageFetcher {
    /// Cache representation type.
    enum Cache {
        case home
        case search
        case news
    }
}

class ImageURLProtocol: URLProtocol {
    var cancelledOrComplete: Bool = false
    var block: DispatchWorkItem!
    
    private static let queue = DispatchQueue(label: "com.apple.imageLoaderURLProtocol",
                                             qos: .background,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .workItem,
                                             target: .global(qos: .background))
    
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
        guard let reqURL = request.url, let urlClient = client else {
            return
        }
        
        block = DispatchWorkItem(block: {
            if self.cancelledOrComplete == false {
                let fileURL = URL(string: reqURL.absoluteString)!
                if let data = try? Data(contentsOf: fileURL) {
                    urlClient.urlProtocol(self, didLoad: data)
                    urlClient.urlProtocolDidFinishLoading(self)
                }
            }
            self.cancelledOrComplete = true
        })
        
        let time = DispatchTime.now().advanced(by: .nanoseconds(500))
        ImageURLProtocol.queue.asyncAfter(deadline: time, execute: block)
    }
    
    final override func stopLoading() {
        ImageURLProtocol.queue.async {
            if self.cancelledOrComplete == false,
               let cancelBlock = self.block {
                cancelBlock.cancel()
                self.cancelledOrComplete = true
            }
        }
    }
    
    static func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ImageURLProtocol.classForCoder()]
        return  URLSession(configuration: config)
    }
}
