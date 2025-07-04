import AmplitudeSwift
import Services
import AnytypeCore
import Foundation

final class AnytypeAnalytics: @unchecked Sendable {

    private enum Keys {
        static let interfaceLang = "interfaceLang"
        static let networkId = "networkId"
        static let tier = "tier"
        static let tierId = "tierId"
    }
    
    private enum Constants {
        static let url = "https://amplitude.anytype.io/2/httpapi"
    }
    
    private var isEnabled: Bool = true
    private var eventHandler: (@Sendable (_ eventType: String, _ eventProperties: [AnyHashable : Any]?) -> Void)?
    
    private static let anytypeAnalytics = AnytypeAnalytics()

    private var eventsConfiguration: [String: EventConfigurtion] = [:]
    private var lastEvents: String = ""
    private var userProperties: [String: Any] = [:]
    private var amplitude: Amplitude?
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    private init() {
        userProperties[Keys.interfaceLang] = Locale.current.language.languageCode?.identifier
    }

    static func instance() -> AnytypeAnalytics {
        return AnytypeAnalytics.anytypeAnalytics
    }

    func setIsEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    func setEventHandler(_ eventHandler: (@Sendable (_ eventType: String, _ eventProperties: [AnyHashable : Any]?) -> Void)?) {
        self.eventHandler = eventHandler
    }
    
    func setEventConfiguartion(event: String, configuation: EventConfigurtion) {
        eventsConfiguration[event] = configuation
    }

    func initializeApiKey(_ apiKey: String) {
        guard amplitude.isNil else {
            anytypeAssertionFailure("Try to setup amplitude multiple times")
            return
        }
        
        amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey,
            serverUrl: Constants.url,
            trackingOptions: TrackingOptions().disableTrackIpAddress(),
            minTimeBetweenSessionsMillis: 5 * 60 * 1000,
            autocapture: [.sessions, .appLifecycles]
        ))
    }

    func setUserId(_ userId: String) {
        guard let amplitude else {
            anytypeAssertionFailure("Amplitude is not loaded")
            return
        }
        amplitude.setUserId(userId: userId)
    }

    func setNetworkId(_ networkId: String) {
        userProperties[Keys.networkId] = networkId
    }
    
    func setMembershipTier(tier: MembershipTier?) {
        userProperties[Keys.tier] = tier?.analyticsName ?? "None"
        userProperties[Keys.tierId] = tier?.type.id
    }
    
    func logEvent(_ eventType: String, spaceId: String, withEventProperties eventProperties: [String : Any] = [:]) {
        var eventProperties = eventProperties
        let participantSpaceView = participantSpacesStorage.participantSpaceView(spaceId: spaceId)
        
        if let permissions = participantSpaceView?.participant?.permission.analyticsType {
            eventProperties[AnalyticsEventsPropertiesKey.permissions] = permissions.rawValue
        }
        
        if let spaceType = participantSpaceView?.spaceView.spaceAccessType?.analyticsType {
            eventProperties[AnalyticsEventsPropertiesKey.spaceType] = spaceType.rawValue
        }
        
        if let uxType = participantSpaceView?.spaceView.uxType.analyticsValue {
            eventProperties[AnalyticsEventsPropertiesKey.uxType] = uxType
        }
        
        logEvent(eventType, withEventProperties: eventProperties)
    }
    
    func logEvent(_ eventType: String, withEventProperties eventProperties: [String : Any] = [:]) {
        let eventConfiguration = eventsConfiguration[eventType]

        if case .notInRow = eventConfiguration?.threshold, lastEvents == eventType {
            return
        }

        lastEvents = eventType
        
        eventHandler?(eventType, eventProperties)
        
        guard isEnabled else { return }
        
        guard let amplitude else {
            anytypeAssertionFailure("Amplitude is not loaded")
            return
        }
        
        let event = BaseEvent(
          eventType: eventType,
          eventProperties: eventProperties,
          userProperties: userProperties
        )
        amplitude.track(event: event)
    }
}
