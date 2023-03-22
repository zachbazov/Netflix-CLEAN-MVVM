//
//  Observable.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - ObserverProtocol Type

private protocol ObserverInput {
    associatedtype Value
    
    func observe(on observer: AnyObject, block: @escaping (Value) -> Void)
    func remove(observer: AnyObject)
}

private protocol ObserverOutput {
    associatedtype Value
    associatedtype T
    
    var observers: T { get }
    var value: Value { get }
    
    func notifyObservers()
}

private typealias ObserverProtocol = ObserverInput & ObserverOutput

// MARK: - Observable Type

final class Observable<Value> {
    fileprivate var observers = [Observer<Value>]()
    
    var value: Value { didSet { notifyObservers() } }
    
    init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Observer Type

extension Observable {
    fileprivate struct Observer<Value> {
        private(set) weak var observer: AnyObject?
        let block: (Value) -> Void
    }
}

// MARK: - ObserverProtocol Implementation

extension Observable: ObserverProtocol {
    fileprivate func notifyObservers() {
        for observer in observers {
            mainQueueDispatch { observer.block(self.value) }
        }
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
