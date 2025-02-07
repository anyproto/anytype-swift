//import Foundation
//import Services
//
//final class AnytypeAnalytics: Sendable {
//    
//    private static let anytypeAnalytics = AnytypeAnalytics()
//    
//    static func instance() -> AnytypeAnalytics {
//        return AnytypeAnalytics.anytypeAnalytics
//    }
//    
//    func setIsEnabled(_ isEnabled: Bool) {
//        Task {
//            await AnytypeAnalyticsCore.instance().setIsEnabled(isEnabled)
//        }
//    }
//    
//    func setEventHandler(_ eventHandler: (@Sendable (_ eventType: String, _ eventProperties: [AnyHashable : Any]?) -> Void)?) {
//        Task {
//            await AnytypeAnalyticsCore.instance().setEventHandler(eventHandler)
//        }
//    }
//    
//    func setEventConfiguartion(event: String, configuation: EventConfigurtion) {
//        Task {
//            await AnytypeAnalyticsCore.instance().setEventConfiguartion(event: event, configuation: configuation)
//        }
//    }
//
//    func initializeApiKey(_ apiKey: String) {
//        Task {
//            await AnytypeAnalyticsCore.instance().initializeApiKey(apiKey)
//        }
//    }
//
//    func setUserId(_ userId: String) async {
//        await AnytypeAnalyticsCore.instance().setUserId(userId)
//    }
//
//    func setNetworkId(_ networkId: String) async {
//        await AnytypeAnalyticsCore.instance().setNetworkId(networkId)
//    }
//    
//    func setMembershipTier(tier: MembershipTier?) async {
//        await AnytypeAnalyticsCore.instance().setMembershipTier(tier: tier)
//    }
//    
//    func logEvent(_ eventType: String, spaceId: String, withEventProperties eventProperties: [AnyHashable : Any]?) {
//        Task {
//            await AnytypeAnalyticsCore.instance().logEvent(eventType, spaceId: spaceId, withEventProperties: eventProperties)
//        }
//    }
//    
//    func logEvent(_ eventType: String, withEventProperties eventProperties: [AnyHashable : Any]?) {
//        Task {
//            await AnytypeAnalyticsCore.instance().logEvent(eventType, withEventProperties: eventProperties)
//        }
//    }
//
//    func logEvent(_ eventType: String) {
//        logEvent(eventType, withEventProperties: nil)
//    }
//    
//    func logEvent(_ eventType: String, spaceId: String) {
//        logEvent(eventType, spaceId: spaceId, withEventProperties: nil)
//    }
//}
