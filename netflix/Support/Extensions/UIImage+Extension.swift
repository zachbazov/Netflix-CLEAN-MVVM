//
//  UIImage+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 19/09/2022.
//

import UIKit

// MARK: - Rendering

extension UIImage {
    func whiteRendering(with symbolConfiguration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        return self
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
            .withConfiguration(symbolConfiguration ?? .unspecified)
    }
    
    static func fillGradientStroke(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
    
    func setThemeTintColor(with symbolConfiguration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        return self
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(Theme.currentTheme == .dark ? .white : .black)
            .withConfiguration(symbolConfiguration ?? .unspecified)
    }
}

// MARK: - Images

extension UIImage {
    static var themeControl: UIImage? {
        return Theme.currentTheme == .dark
            ? UIImage(systemName: "sun.max")?.setThemeTintColor()
            : UIImage(systemName: "moon")?.setThemeTintColor()
    }
    
    static var pencil: UIImage? {
        return UIImage(systemName: "pencil")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
    }
    
    static func plus(withSymbolConfiguration configuration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        return UIImage(systemName: "plus")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#cacaca"))
            .withConfiguration(configuration ?? .unspecified)
    }
}

// MARK: - Color Palette

extension UIImage {
    func averageColorPalette() -> [UIColor] {
        let c1 = averageColor!
        let c2 = areaAverage().darkerColor(for: c1)
        let c3 = c2.darkerColor(for: c2)
        let c4 = UIColor.black
        return [c1, c2, c3, c4]
    }
}

// MARK: - Average Color

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    func areaAverage() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        if #available(iOS 9.0, *) {
            let context = CIContext()
            let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)
            
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
}
