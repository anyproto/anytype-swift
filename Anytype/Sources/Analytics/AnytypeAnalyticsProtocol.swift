//
//  AnytypeAnalyticsProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

protocol AnytypeAnalyticsProtocol {
    var isEnabled: Bool { get set }
    var eventHandler: ((_ eventType: String, _ eventProperties: [AnyHashable : Any]?) -> Void)? { get set }
    
    func initializeApiKey(_ apiKey: String)
    func setUserId(_ userId: String)
    func setEventConfiguartion(event: String, configuation: EventConfigurtion)
    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any]?)
    func logEvent(_ eventType: String)
}
