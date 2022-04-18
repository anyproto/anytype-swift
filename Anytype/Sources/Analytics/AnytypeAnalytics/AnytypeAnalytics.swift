//
//  AnytypeAnalytics.swift
//  Anytype
//
//  Created by Denis Batvinkin on 18.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Amplitude

final class AnytypeAnalytics: AnytypeAnalyticsProtocol {

    private static var anytypeAnalytics: AnytypeAnalytics = {
        let anytypeAnalytics = AnytypeAnalytics()
        return anytypeAnalytics
    }()


    init() {
        // Disable IDFA for Amplitude
        if let trackingOptions = AMPTrackingOptions().disableIDFA() {
            Amplitude.instance().setTrackingOptions(trackingOptions)
        }

        // Enable sending automatic session events
        Amplitude.instance().trackingSessionEvents = true
    }

    static func instance() -> AnytypeAnalytics {
        return AnytypeAnalytics.anytypeAnalytics
    }

    func initializeApiKey(_ apiKey: String) {
        Amplitude.instance().initializeApiKey(apiKey)
    }

    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any]?) {
        Amplitude.instance().logEvent(eventType, withEventProperties: eventProperties)
    }

    func logEvent(_ eventType: String) {
        Amplitude.instance().logEvent(eventType)
    }
}
