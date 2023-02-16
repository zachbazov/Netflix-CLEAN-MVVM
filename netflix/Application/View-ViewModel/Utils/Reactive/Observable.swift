//
//  Observable.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - Observable Type

final class Observable<Value> {
    private struct Observer<Value> {
        private(set) weak var observer: AnyObject?
        let block: (Value) -> Void
    }
    
    private var observers = [Observer<Value>]()
    var value: Value { didSet { notifyObservers() } }
    
    init(_ value: Value) { self.value = value }
}

// MARK: - Methods

extension Observable {
    private func notifyObservers() {
        for observer in observers { mainQueueDispatch { observer.block(self.value) } }
    }
    
    func observe(on observer: AnyObject, block: @escaping (Value) -> Void) {
        let observer = Observer(observer: observer, block: block)
        observers.append(observer)
        block(self.value)
    }
    
    func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
}
