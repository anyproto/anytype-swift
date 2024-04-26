//
//  AnytypeAnalytics.swift
//  Anytype
//
//  Created by Denis Batvinkin on 18.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Amplitude

final class AnytypeAnalytics: AnytypeAnalyticsProtocol {

    private enum Keys {
        static let interfaceLang = "interfaceLang"
        static let networkId = "networkId"
    }
    
    var isEnabled: Bool = true
    var eventHandler: ((_ eventType: String, _ eventProperties: [AnyHashable : Any]?) -> Void)?
    
    private static var anytypeAnalytics: AnytypeAnalytics = {
        let anytypeAnalytics = AnytypeAnalytics()
        return anytypeAnalytics
    }()

    private var eventsConfiguration: [String: EventConfigurtion] = [:]
    private var lastEvents: String = .empty
    private var userProperties: [AnyHashable: Any] = [:]
    
    private init() {
        // Disable IDFA/IPAddress for Amplitude
        if let trackingOptions = AMPTrackingOptions().disableIDFA().disableIPAddress(){
            Amplitude.instance().setTrackingOptions(trackingOptions)
        }

        // Enable sending automatic session events
        Amplitude.instance().trackingSessionEvents = true
        
        userProperties[Keys.interfaceLang] = Locale.current.languageCode
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

    func setNetworkId(_ networkId: String) {
        userProperties[Keys.networkId] = networkId
    }
    
    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any]?) {
        
        let eventConfiguration = eventsConfiguration[eventType]

        if case .notInRow = eventConfiguration?.threshold, lastEvents == eventType {
            return
        }

        lastEvents = eventType
        
        eventHandler?(eventType, eventProperties)
        
        guard isEnabled else { return }
        Amplitude.instance().logEvent(eventType, withEventProperties: eventProperties, withUserProperties: userProperties)
    }

    func logEvent(_ eventType: String) {
        logEvent(eventType, withEventProperties: nil)
    }
}
