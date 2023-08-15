//
//  MediaPlayerOverlayViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/10/2022.
//

import Foundation
import CoreGraphics

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var timer: ScheduledTimer { get }
    var durationThreshold: CGFloat { get }
    var repeats: Bool { get }
    var timeRemainingFormatter: DateComponentsFormatter { get }
    
    func timeString(_ time: Float) -> String
}

// MARK: - MediaPlayerOverlayViewViewModel Type

struct MediaPlayerOverlayViewViewModel {
    var timer = ScheduledTimer()
    
    var durationThreshold: CGFloat = 3.0
    var repeats: Bool = true
    
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

/*
 //
 //  MediaPlayerOverlayViewViewModel.swift
 //  netflix
 //
 //  Created by Zach Bazov on 10/10/2022.
 //

 import Foundation

 // MARK: - ViewModelProtocol Type

 private protocol ViewModelProtocol {
     var timer: ScheduledTimer { get }
     var durationThreshold: CGFloat { get }
     var repeats: Bool { get }
     var timeRemainingFormatter: DateComponentsFormatter { get }
     
     func timeString(_ time: Float) -> String
 }

 // MARK: - MediaPlayerOverlayViewViewModel Type

 struct MediaPlayerOverlayViewViewModel {
     let coordinator: DetailViewCoordinator
     
     var timer = ScheduledTimer()
     
     var durationThreshold: CGFloat = 3.0
     var repeats: Bool = true
     
     let media: Media
     
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
     
     init(with viewModel: MediaPlayerViewViewModel) {
         self.coordinator = viewModel.coordinator
         self.media = viewModel.media
     }
 }

 // MARK: - ViewModel Implementation

 extension MediaPlayerOverlayViewViewModel: ViewModel {}

 // MARK: - ViewModelProtocol Implementation

 extension MediaPlayerOverlayViewViewModel: ViewModelProtocol {}

 */
