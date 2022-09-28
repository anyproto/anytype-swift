//
//  AppMetricsTracker.swift
//  Anytype
//
//  Created by Konstantin Mordan on 16.09.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import MetricKit

final class AppMetricsTracker: NSObject, MXMetricManagerSubscriber {
    
    override init() {
        super.init()
        
        MXMetricManager.shared.add(self)
    }
    
    deinit {
        MXMetricManager.shared.remove(self)
    }
    
    // MARK: - MXMetricManagerSubscriber
    
    func didReceive(_ payloads: [MXMetricPayload]) {}
    
    func didReceive(_ payloads: [MXDiagnosticPayload]) {}
    
}
