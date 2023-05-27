//
//  DeviceOrienting.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import UIKit

// MARK: - DeviceOrienting Type

protocol DeviceOrienting {
    func deviceWillLockOrientation(_ mask: UIInterfaceOrientationMask)
}
