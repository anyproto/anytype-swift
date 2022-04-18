//
//  AnytypeAnalyticsProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

public protocol AnytypeAnalyticsProtocol {
    func initializeApiKey(_ apiKey: String)
    func setUserId(_ userId: String)
    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any]?)
    func logEvent(_ eventType: String)
}
