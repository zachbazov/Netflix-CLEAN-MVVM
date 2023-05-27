//
//  ScheduledTimer.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import Foundation

// MARK: - TimerProtocol Type

private protocol TimerProtocol {
    var timer: Timer? { get }
    
    func schedule(timeInterval: TimeInterval, target: Any, selector: Selector, repeats: Bool)
    func invalidate()
}

// MARK: - ScheduledTimer Type

final class ScheduledTimer {
    var timer: Timer?
    
    deinit {
        timer = nil
    }
}

// MARK: - TimerProtocol Implementation

extension ScheduledTimer: TimerProtocol {
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
        guard let timer = timer else { return }
        
        timer.invalidate()
        
        self.timer = nil
    }
}
