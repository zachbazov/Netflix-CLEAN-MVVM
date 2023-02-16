//
//  QoS.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - Main Queue Dispatch Block

func mainQueueDispatch(_ block: @escaping () -> Void) {
    DispatchQueue.main.async { block() }
}

func mainQueueDispatch(delayInSeconds delay: Int, _ block: @escaping () -> Void) {
    let time = DispatchTime.now().advanced(by: .seconds(delay))
    DispatchQueue.main.asyncAfter(deadline: time, execute: block)
}
