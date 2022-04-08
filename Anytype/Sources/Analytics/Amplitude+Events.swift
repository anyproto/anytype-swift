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
    
    func logSetStyle(_ style: BlockText.Style) {
        logEvent(
            AmplitudeEventsName.changeBlockStyle,
            withEventProperties: [AmplitudeEventsPropertiesKey.blockStyle: String(describing: style)]
        )
    }

    func logSetMarkup(_ markupType: MarkupType) {
        logEvent(
            AmplitudeEventsName.changeBlockStyle,
            withEventProperties: [AmplitudeEventsPropertiesKey.type: markupType.description]
        )
    }

    func logHomeTabSelection(_ selectedTab: HomeTabsView.Tab) {
        let anayliticsName: String

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

    func logDefaultObjectTypeChange(_ type: String) {
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

    func logShowObject(type: String, layout: DetailsLayout) {
        logEvent(
            AmplitudeEventsName.showObject,
            withEventProperties: [AmplitudeEventsPropertiesKey.type: type,
                                  AmplitudeEventsPropertiesKey.layout: layout.rawValue]
        )
    }

    func logObjectTypeChange(_ type: String) {
        logEvent(AmplitudeEventsName.objectTypeChange,
                 withEventProperties: [AmplitudeEventsPropertiesKey.objectType: type])
    }

    func logLayoutChange(_ layout: DetailsLayout) {
        logEvent(AmplitudeEventsName.changeLayout,
                 withEventProperties: [AmplitudeEventsPropertiesKey.layout: layout.rawValue])
    }

    func logSetAlignment(_ alignment: LayoutAlignment, isBlock: Bool) {
        if isBlock {
            logEvent(AmplitudeEventsName.blockListSetAlign,
                     withEventProperties: [AmplitudeEventsPropertiesKey.align: alignment.name])
        } else {
            logEvent(AmplitudeEventsName.setLayoutAlign,
                     withEventProperties: [AmplitudeEventsPropertiesKey.align: alignment.name])
        }
    }

    func logCreateBlock(type: String, style: String) {
        logEvent(AmplitudeEventsName.blockCreate,
                 withEventProperties: [AmplitudeEventsPropertiesKey.type: type,
                                       AmplitudeEventsPropertiesKey.blockStyle: style])
    }

    func logUploadMedia(type: FileContentType) {
        logEvent(AmplitudeEventsName.blockUpload,
                 withEventProperties: [AmplitudeEventsPropertiesKey.type: type.rawValue])
    }

    func logDownloadMedia(type: FileContentType) {
        logEvent(AmplitudeEventsName.downloadFile,
                 withEventProperties: [AmplitudeEventsPropertiesKey.type: type.rawValue])
    }

    func logReorderBlock(count: Int) {
        logEvent(AmplitudeEventsName.reorderBlock,
                 withEventProperties: [AmplitudeEventsPropertiesKey.count: count])
    }

    func logAddRelation(format: RelationMetadata.Format, isNew: Bool) {
        let eventName = isNew ? AmplitudeEventsName.createRelation : AmplitudeEventsName.addExistingRelation
        logEvent(eventName,
                 withEventProperties: [AmplitudeEventsPropertiesKey.format: format.analyticString])
    }

    func logCreateObject(objectType: String) {
        logEvent(AmplitudeEventsName.createObject,
                 withEventProperties: [AmplitudeEventsPropertiesKey.objectType: objectType])
    }
}
