//
//  AnytypeAnalytics.swift
//  Anytype
//
//  Created by Denis Batvinkin on 18.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Amplitude

final class AnytypeAnalytics: AnytypeAnalyticsProtocol {

    var isEnabled: Bool = true

    private static var anytypeAnalytics: AnytypeAnalytics = {
        let anytypeAnalytics = AnytypeAnalytics()
        return anytypeAnalytics
    }()

    private var eventsConfiguration: [String: EventConfigurtion] = [:]
    private var lastEvents: String = .empty

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

    func setEventConfiguartion(event: String, configuation: EventConfigurtion) {
        eventsConfiguration[event] = configuation
    }

    func initializeApiKey(_ apiKey: String) {
        Amplitude.instance().initializeApiKey(apiKey)
    }

    func setUserId(_ userId: String) {
        Amplitude.instance().setUserId(userId)
    }

    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any]?) {
        guard isEnabled else { return }
        
        let eventConfiguration = eventsConfiguration[eventType]

        if case .notInRow = eventConfiguration?.threshold, lastEvents == eventType {
            return
        }

        lastEvents = eventType
        Amplitude.instance().logEvent(eventType, withEventProperties: eventProperties)
    }

    func logEvent(_ eventType: String) {
        logEvent(eventType, withEventProperties: nil)
    }
}
