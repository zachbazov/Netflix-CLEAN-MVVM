//
//  MediaPlayerOverlayViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var timeRemainingFormatter: DateComponentsFormatter { get }
    
    func timeString(_ time: Float) -> String
}

// MARK: - MediaPlayerOverlayViewViewModel Type

struct MediaPlayerOverlayViewViewModel {
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    func timeString(_ time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(.zero, time))
        return timeRemainingFormatter.string(for: components as DateComponents)!
    }
}

// MARK: - ViewModel Implementation

extension MediaPlayerOverlayViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension MediaPlayerOverlayViewViewModel: ViewModelProtocol {}
