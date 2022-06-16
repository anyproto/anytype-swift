//
//  AsyncOperation.swift
//  AnytypeCore
//
//  Created by Konstantin Mordan on 27.09.2021.
//
import Foundation

open class AsyncOperation: Operation {
    
    /// The state of an operation.
    ///
    /// - waiting: An operation is waiting for execution.
    /// - ready: An operation is ready for execution.
    /// - executing: An operation is executing.
    /// - finished: An operation is finished.
    /// - cancelled: An operation is cancelled.
    public enum State: String {
        case waiting = "isWaiting"
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case cancelled = "isCancelled"
    }
    
    /// The current operation state.
    open var state: State = .waiting {
        willSet {
            switch newValue {
            case .waiting:
                willChangeValue(forKey: State.waiting.rawValue)
            case .ready:
                willChangeValue(forKey: State.ready.rawValue)
            case .executing:
                willChangeValue(forKey: State.executing.rawValue)
            case .finished:
                willChangeValue(forKey: State.finished.rawValue)
            case .cancelled:
                willChangeValue(forKey: State.cancelled.rawValue)
            }
        }
        didSet {
            switch state {
            case .waiting:
                didChangeValue(forKey: State.waiting.rawValue)
            case .ready:
                didChangeValue(forKey: State.ready.rawValue)
            case .executing:
                didChangeValue(forKey: State.executing.rawValue)
            case .finished:
                didChangeValue(forKey: State.finished.rawValue)
            case .cancelled:
                didChangeValue(forKey: State.cancelled.rawValue)
            }
        }
    }

    open override var isReady: Bool {
        if self.state == .waiting {
            return super.isReady
        } else {
            return state == .ready
        }
    }
    
    open override var isExecuting: Bool {
        if self.state == .waiting {
            return super.isExecuting
        } else {
            return state == .executing
        }
    }
    
    open override var isFinished: Bool {
        if self.state == .waiting {
            return super.isFinished
        } else {
            return state == .finished
        }
    }
    
    open override var isCancelled: Bool {
        if self.state == .waiting {
            return super.isCancelled
        } else {
            return state == .cancelled
        }
    }
    
    open override var isAsynchronous: Bool {
        true
    }
    
    open override func cancel() {
        state = .cancelled
        super.cancel()
    }
    
}
