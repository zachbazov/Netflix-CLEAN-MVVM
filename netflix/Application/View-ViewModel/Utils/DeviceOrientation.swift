//
//  DeviceOrientation.swift
//  netflix
//
//  Created by Zach Bazov on 03/12/2022.
//

import UIKit

// MARK: - DeviceOrienting Type

protocol DeviceOrienting {
    func didLockDeviceOrientation(_ mask: UIInterfaceOrientationMask)
}

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
        if #available(iOS 16.0, *) {
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            return
        }
        
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

//class RotationManager: NSObject {
//    override init() {
//        super.init()
//        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
//        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
//    }
//
//    @objc func deviceOrientationDidChange() {
//        switch UIDevice.current.orientation {
//        case .portrait:
//            // Set interface to portrait mode
//            printIfDebug(.debug, "port")
//            break
//        case .portraitUpsideDown:
//            // Set interface to upside down portrait mode
//            printIfDebug(.debug, "portUpsideDown")
//            break
//        case .landscapeLeft:
//            // Set interface to landscape left mode
//            printIfDebug(.debug, "landLeft")
//            break
//        case .landscapeRight:
//            // Set interface to landscape right mode
//            printIfDebug(.debug, "landRight")
//            break
//        default:
//            printIfDebug(.debug, "def")
//            break
//        }
//    }
//
//    deinit {
//        UIDevice.current.endGeneratingDeviceOrientationNotifications()
//        NotificationCenter.default.removeObserver(self)
//    }
//}
