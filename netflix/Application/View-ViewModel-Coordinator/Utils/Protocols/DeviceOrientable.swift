//
//  DeviceOrientable.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import UIKit

// MARK: - DeviceOrientable Type

protocol DeviceOrientable {
    func deviceWillLockOrientation(_ mask: UIInterfaceOrientationMask)
}
