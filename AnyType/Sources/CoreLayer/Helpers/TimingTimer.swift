//
//  TimingTimer.swift
//  AnyType
//
//  Created by Denis Batvinkin on 10.01.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Combine
import Foundation


private var scrollModelInst: Int = 0


class TimingTimer {
    private var numberOfInstance: Int = 0
    private var timer = Timer.publish(every: 1, on: .main, in: .common)
    private var cancellableTimer: AnyCancellable?
    
    var fireTimer: (() -> Void)?
    var cancelTimer: (() -> Void)?
    
    var timing: TimeInterval = .zero {
        didSet {
            guard oldValue != timing else { return }
            
            self.cancellableTimer?.cancel()
            DispatchQueue.main.async {
                self.cancelTimer?()
            }
            
            if timing != 0 {
                timer = Timer.publish(every: abs(timing), tolerance: 0, on: .main, in: .common)
                cancellableTimer = timer.autoconnect().sink { [weak self] _ in
                    self?.fireTimer?()
                }
                print("start timer: \(timing)")
            }
        }
    }
    
    init() {
        scrollModelInst += 1
        numberOfInstance = scrollModelInst
        print("init \(numberOfInstance)")
    }
    
    deinit {
        print("deinit \(numberOfInstance)")
        self.cancellableTimer?.cancel()
        self.cancelTimer?()
    }
}
