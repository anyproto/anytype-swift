import Amplitude
import Services

final class AnytypeAnalytics: @unchecked Sendable {

    private enum Keys {
        static let interfaceLang = "interfaceLang"
        static let networkId = "networkId"
        static let tier = "tier"
    }
    
    private var isEnabled: Bool = true
    private var eventHandler: (@Sendable (_ eventType: String, _ eventProperties: [AnyHashable : Any]?) -> Void)?
    
    private static let anytypeAnalytics = AnytypeAnalytics()

    private var eventsConfiguration: [String: EventConfigurtion] = [:]
    private var lastEvents: String = ""
    private var userProperties: [AnyHashable: Any] = [:]
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    private init() {
        // Disable IDFA/IPAddress for Amplitude
        if let trackingOptions = AMPTrackingOptions().disableIDFA().disableIPAddress() {
            Amplitude.instance().setTrackingOptions(trackingOptions)
        }
        Amplitude.instance().setServerUrl("https://amplitude.anytype.io")
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
        Amplitude.instance().initializeApiKey(apiKey)
    }

    func setUserId(_ userId: String) {
        Amplitude.instance().setUserId(userId)
    }

    func setNetworkId(_ networkId: String) {
        userProperties[Keys.networkId] = networkId
    }
    
    func setMembershipTier(tier: MembershipTier?) {
        userProperties[Keys.tier] = tier?.name
    }
    
    func logEvent(_ eventType: String, spaceId: String, withEventProperties eventProperties: [AnyHashable : Any] = [:]) {
        var eventProperties = eventProperties
        let participantSpaceView = participantSpacesStorage.participantSpaceView(spaceId: spaceId)
        
        if let permissions = participantSpaceView?.participant?.permission.analyticsType {
            eventProperties[AnalyticsEventsPropertiesKey.permissions] = permissions.rawValue
        }
        
        if let spaceType = participantSpaceView?.spaceView.spaceAccessType?.analyticsType {
            eventProperties[AnalyticsEventsPropertiesKey.spaceType] = spaceType.rawValue
        }
        
        logEvent(eventType, withEventProperties: eventProperties)
    }
    
    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any] = [:]) {
        let eventConfiguration = eventsConfiguration[eventType]

        if case .notInRow = eventConfiguration?.threshold, lastEvents == eventType {
            return
        }

        lastEvents = eventType
        
        eventHandler?(eventType, eventProperties)
        
        guard isEnabled else { return }
        Amplitude.instance().logEvent(eventType, withEventProperties: eventProperties, withUserProperties: userProperties)
    }
}
