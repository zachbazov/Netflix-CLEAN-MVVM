//
//  MediaPlayerOverlayViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/10/2022.
//

import Foundation

// MARK: - MediaPlayerOverlayViewViewModel Type

struct MediaPlayerOverlayViewViewModel {
    
    // MARK: Properties
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    // MARK: Methods
    
    func timeString(_ time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(.zero, time))
        return timeRemainingFormatter.string(for: components as DateComponents)!
    }
}
