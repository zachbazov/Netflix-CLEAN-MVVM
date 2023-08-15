//
//  URLImageService.swift
//  netflix
//
//  Created by Developer on 13/06/2023.
//

import UIKit

// MARK: - URLImageTasking Type

protocol URLImageTasking {
    func load(url: URL, identifier: NSString, completion: @escaping (UIImage?) -> Void)
}

// MARK: - URLImageSessionable Type

protocol URLImageSessionable {
    func urlSession() -> URLSession
}

// MARK: - URLImageService Type

final class URLImageService: URLProtocol {
    var cancelledOrComplete: Bool = false
    var block: DispatchWorkItem!
    
    private let queue = DispatchQueue(label: "com.netflix.URLImageSessionable",
                                      qos: .userInitiated,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .workItem)
    
    // MARK: URLProtocol Lifecycle
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    class override func requestIsCacheEquivalent(_ aRequest: URLRequest, to bRequest: URLRequest) -> Bool {
        return aRequest == bRequest
    }
    
    final override func startLoading() {
        guard let reqURL = request.url, let urlClient = client else { return }
        
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
        
        queue.asyncAfter(deadline: time, execute: block)
    }
    
    final override func stopLoading() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if self.cancelledOrComplete == false, let cancelBlock = self.block {
                cancelBlock.cancel()
                
                self.cancelledOrComplete = true
            }
        }
    }
}

// MARK: - URLImageSessionable Implementation

extension URLImageService: URLImageSessionable {
    func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLImageService.classForCoder()]
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }
}
