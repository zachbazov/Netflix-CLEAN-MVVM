//
//  Color.swift
//  netflix
//
//  Created by Zach Bazov on 12/05/2023.
//

import UIKit.UIColor

struct Color {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Array where Element == Color {
    func toUIColorArray() -> [UIColor] {
        return map { $0.uiColor }
    }
}

extension Array where Element == UIColor {
    func toColorArray() -> [Color] {
        return map { Color(color: $0) }
    }
}
