//
//  DeviceOrientation.swift
//  netflix
//
//  Created by Zach Bazov on 03/12/2022.
//

import UIKit.UIApplication

// MARK: - DeviceOrientation Type

final class DeviceOrientation {
    
    // MARK: Singleton Pattern
    
    static let shared = DeviceOrientation()
    private init() {}
    
    // MARK: Properties
    
    private(set) var orientationLock: UIInterfaceOrientationMask = .all
    private var orientation: UIInterfaceOrientationMask = .portrait {
        didSet { set(orientation: orientation) }
    }
    private let orientationKey = "orientation"
    private var windowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
}

// MARK: - Methods

extension DeviceOrientation {
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
