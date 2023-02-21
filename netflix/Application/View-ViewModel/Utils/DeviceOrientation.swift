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

private protocol OrientationInput {
    func set(orientation: UIInterfaceOrientationMask)
    func setLock(orientation: UIInterfaceOrientationMask)
}

private protocol OrientationOutput {
    var orientationLock: UIInterfaceOrientationMask { get }
    var orientation: UIInterfaceOrientationMask { get }
    var windowScene: UIWindowScene? { get }
    
    func rotate()
}

private typealias OrientationProtocol = OrientationInput & OrientationOutput

// MARK: - DeviceOrientation Type

final class DeviceOrientation {
    static let shared = DeviceOrientation()
    private init() {}
    
    private let orientationKey = "orientation"
    private(set) var orientationLock: UIInterfaceOrientationMask = .all
    fileprivate var orientation: UIInterfaceOrientationMask = .portrait {
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
        if orientationLock == .portrait { orientationLock = .all }
        
        if orientation == .landscapeLeft { orientation = .portrait }
        else { orientation = .landscapeLeft }
    }
}
