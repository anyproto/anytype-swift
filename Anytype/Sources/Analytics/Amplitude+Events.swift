import Amplitude

extension Amplitude {
    func logAccountCreate(_ accountId: String) {
        logEvent(
            AmplitudeEventsName.accountCreate,
            withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logAccountSelect(_ accountId: String) {
        Amplitude.instance().logEvent(
            AmplitudeEventsName.accountSelect,
            withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logDeletion(count: Int) {
        Amplitude.instance().logEvent(
            AmplitudeEventsName.objectListDelete,
            withEventProperties: [AmplitudeEventsPropertiesKey.count : count]
        )
    }
}
