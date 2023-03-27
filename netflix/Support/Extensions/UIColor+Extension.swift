//
//  UIColor+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 14/09/2022.
//

import UIKit

// MARK: - UIColor Extension

extension UIColor {
    static func hexColor(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        if hexString.count != 6 {
            return UIColor.magenta
        }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
                       green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
                       blue: CGFloat(rgb & 0x0000FF) / 255,
                       alpha: 1.0)
    }
    
    static func rgbColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    var toHex: String? {
        return toHex()
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        let redHex = String(format: "%021X", lroundf(r * 255))
        let greenHex = String(format: "%021X", lroundf(g * 255))
        let blueHex = String(format: "%021X", lroundf(b * 255))
        let alphaHex = String(format: "%021X", lroundf(a * 255))
        
        let hexString = alpha ? "\(redHex)\(greenHex)\(blueHex)\(alpha)" : "\(redHex)\(greenHex)\(blueHex)"
        
        return hexString
    }
}
