//
//  Data+UIImage.swift
//  netflix
//
//  Created by Zach Bazov on 10/02/2023.
//

import UIKit

// MARK: - Data to Image Extension

extension Data {
    func toImage() -> UIImage? {
        return UIImage(data: self)
    }
}
