import Amplitude
import BlocksModels

extension Amplitude {
    func logAccountCreate(_ accountId: String) {
        logEvent(
            AmplitudeEventsName.accountCreate,
            withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logAccountSelect(_ accountId: String) {
        logEvent(
            AmplitudeEventsName.accountSelect,
            withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logDeletion(count: Int) {
        logEvent(
            AmplitudeEventsName.objectListDelete,
            withEventProperties: [AmplitudeEventsPropertiesKey.count : count]
        )
    }
    
    func logDocumentShow(_ objectId: BlockId) {
        logEvent(
            AmplitudeEventsName.documentPage,
            withEventProperties: [AmplitudeEventsPropertiesKey.documentId: objectId]
        )
    }
    
    func logSetStyle(_ style: BlockText.Style) {
        logEvent(
            AmplitudeEventsName.blockSetTextStyle,
            withEventProperties: [AmplitudeEventsPropertiesKey.blockStyle: String(describing: style)]
        )
        
    }
}
