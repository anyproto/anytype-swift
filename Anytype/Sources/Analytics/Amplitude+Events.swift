import Amplitude
import BlocksModels
import UIKit

extension Amplitude {
    func logAccountCreate(_ accountId: String) {
        logEvent(
            AmplitudeEventsName.createAccount,
            withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logAccountSelect(_ accountId: String) {
        logEvent(
            AmplitudeEventsName.openAccount,
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

    func logHomeTabSelection(_ selectedTab: HomeTabsView.Tab) {
        var anayliticsName = ""

        switch selectedTab {
        case .favourites:
            anayliticsName = AmplitudeEventsHomeTabValue.favoritesTabSelected
        case .history:
            anayliticsName = AmplitudeEventsHomeTabValue.recentTabSelected
        case .sets:
            anayliticsName = AmplitudeEventsHomeTabValue.setsTabSelected
        case .shared:
            anayliticsName = AmplitudeEventsHomeTabValue.sharedTabSelected
        case .bin:
            anayliticsName = AmplitudeEventsHomeTabValue.archiveTabSelected
        }
        logEvent(
            AmplitudeEventsName.selectHomeTab,
            withEventProperties: [AmplitudeEventsPropertiesKey.tab: anayliticsName]
        )
    }

    func logAddToFavorites(_ isFavorites: Bool) {
        if isFavorites {
            logEvent(AmplitudeEventsName.addToFavorites)
        } else {
            logEvent(AmplitudeEventsName.removeFromFavorites)
        }
    }

    func logMoveToBin(_ isArchived: Bool) {
        if isArchived {
            logEvent(AmplitudeEventsName.moveToBin)
        } else {
            logEvent(AmplitudeEventsName.restoreFromBin)
        }
    }

    func logKeychainPhraseShow(_ context: AmplitudeEventsKeychainContext) {
        logEvent(AmplitudeEventsName.keychainPhraseScreenShow,
                 withEventProperties: [AmplitudeEventsPropertiesKey.type: context.rawValue])
    }

    func logKeychainPhraseCopy(_ context: AmplitudeEventsKeychainContext) {
        logEvent(AmplitudeEventsName.keychainPhraseCopy,
                 withEventProperties: [AmplitudeEventsPropertiesKey.type: context.rawValue])
    }

    func logObjectTypeChange(_ type: String) {
        logEvent(AmplitudeEventsName.defaultObjectTypeChange,
                 withEventProperties: [AmplitudeEventsPropertiesKey.objectType: type])
    }

    func logSelectTheme(_ userInterfaceStyle: UIUserInterfaceStyle) {
        logEvent(AmplitudeEventsName.selectTheme,
                 withEventProperties: [AmplitudeEventsPropertiesKey.type: userInterfaceStyle.title])
    }

    func logSearchQuery(_ context: AmplitudeEventsSearchContext, length: Int) {
        logEvent(AmplitudeEventsName.searchQuery,
                 withEventProperties: [AmplitudeEventsPropertiesKey.route: context.rawValue,
                                       AmplitudeEventsPropertiesKey.length: length])
    }

    func logSearchResult(index: Int, length: Int) {
        logEvent(AmplitudeEventsName.searchQuery,
                 withEventProperties: [AmplitudeEventsPropertiesKey.index: index,
                                       AmplitudeEventsPropertiesKey.length: length])
    }
}
