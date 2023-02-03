//
//  ScheduledTimer.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import Foundation

// MARK: - ScheduledTimer Type

final class ScheduledTimer {
    var timer: Timer!
    
    deinit { timer = nil }
}

// MARK: - Methods

extension ScheduledTimer {
    func schedule(timeInterval: TimeInterval,
                  target: Any,
                  selector: Selector,
                  repeats: Bool) {
        invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: target,
                                     selector: selector,
                                     userInfo: nil,
                                     repeats: repeats)
    }
    
    func invalidate() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
}
