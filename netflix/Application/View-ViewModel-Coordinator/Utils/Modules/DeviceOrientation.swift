//
//  DeviceOrientation.swift
//  netflix
//
//  Created by Zach Bazov on 03/12/2022.
//

import UIKit

// MARK: - OrientationProtocol Type

private protocol OrientationProtocol {
    var orientationLock: UIInterfaceOrientationMask { get }
    var orientation: UIInterfaceOrientationMask { get }
    var windowScene: UIWindowScene? { get }
    
    func set(orientation: UIInterfaceOrientationMask)
    func setLock(orientation: UIInterfaceOrientationMask)
    func rotate()
}

// MARK: - DeviceOrientation Type

final class DeviceOrientation {
    static let shared = DeviceOrientation()
    private init() {}
    
    private let orientationKey = "orientation"
    
    private(set) var orientationLock: UIInterfaceOrientationMask = .all
    
    var orientation: UIInterfaceOrientationMask = .portrait {
        didSet { set(orientation: orientation) }
    }
    
    fileprivate var windowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
}

// MARK: - OrientationProtocol Implementation

extension DeviceOrientation: OrientationProtocol {
    func set(orientation: UIInterfaceOrientationMask) {
//        if #available(iOS 16.0, *) {
//            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
//            return
//        }
        
        UIDevice.current.setValue(orientation.rawValue, forKey: orientationKey)
    }
    
    func setLock(orientation: UIInterfaceOrientationMask) {
        orientationLock = orientation
    }
    
    func rotate() {
        if orientation == .landscapeLeft {
            orientation = .portrait
            
            return
        }
        
        if orientation == .portrait {
            orientation = .landscapeLeft
        }
    }
}
