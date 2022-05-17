import BlocksModels
import UIKit

extension AnytypeAnalytics {
    func logAccountCreate(_ accountId: String) {

        logEvent(
            AnalyticsEventsName.createAccount,
            withEventProperties: [AnalyticsEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logAccountSelect(_ accountId: String) {
        logEvent(
            AnalyticsEventsName.openAccount,
            withEventProperties: [AnalyticsEventsPropertiesKey.accountId : accountId]
        )
    }
    
    func logDeletion(count: Int) {
        logEvent(
            AnalyticsEventsName.objectListDelete,
            withEventProperties: [AnalyticsEventsPropertiesKey.count : count]
        )
    }
    
    func logSetStyle(_ style: BlockText.Style) {
        logEvent(
            AnalyticsEventsName.changeBlockStyle,
            withEventProperties: [AnalyticsEventsPropertiesKey.blockStyle: String(describing: style)]
        )
    }

    func logSetMarkup(_ markupType: MarkupType) {
        logEvent(
            AnalyticsEventsName.changeBlockStyle,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: markupType.description]
        )
    }

    func logHomeTabSelection(_ selectedTab: HomeTabsView.Tab) {
        let anayliticsName: String

        switch selectedTab {
        case .favourites:
            anayliticsName = AnalyticsEventsHomeTabValue.favoritesTabSelected
        case .history:
            anayliticsName = AnalyticsEventsHomeTabValue.recentTabSelected
        case .sets:
            anayliticsName = AnalyticsEventsHomeTabValue.setsTabSelected
        case .shared:
            anayliticsName = AnalyticsEventsHomeTabValue.sharedTabSelected
        case .bin:
            anayliticsName = AnalyticsEventsHomeTabValue.archiveTabSelected
        }
        logEvent(
            AnalyticsEventsName.selectHomeTab,
            withEventProperties: [AnalyticsEventsPropertiesKey.tab: anayliticsName]
        )
    }

    func logAddToFavorites(_ isFavorites: Bool) {
        if isFavorites {
            logEvent(AnalyticsEventsName.addToFavorites)
        } else {
            logEvent(AnalyticsEventsName.removeFromFavorites)
        }
    }

    func logMoveToBin(_ isArchived: Bool) {
        if isArchived {
            logEvent(AnalyticsEventsName.moveToBin)
        } else {
            logEvent(AnalyticsEventsName.restoreFromBin)
        }
    }

    func logKeychainPhraseShow(_ context: AnalyticsEventsKeychainContext) {
        logEvent(AnalyticsEventsName.keychainPhraseScreenShow,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: context.rawValue])
    }

    func logKeychainPhraseCopy(_ context: AnalyticsEventsKeychainContext) {
        logEvent(AnalyticsEventsName.keychainPhraseCopy,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: context.rawValue])
    }

    func logDefaultObjectTypeChange(_ type: String) {
        logEvent(AnalyticsEventsName.defaultObjectTypeChange,
                 withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type])
    }

    func logSelectTheme(_ userInterfaceStyle: UIUserInterfaceStyle) {
        logEvent(AnalyticsEventsName.selectTheme,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: userInterfaceStyle.title])
    }

    func logSearchQuery(_ context: AnalyticsEventsSearchContext, length: Int) {
        logEvent(AnalyticsEventsName.searchQuery,
                 withEventProperties: [AnalyticsEventsPropertiesKey.route: context.rawValue,
                                       AnalyticsEventsPropertiesKey.length: length])
    }

    func logSearchResult(index: Int, length: Int) {
        logEvent(AnalyticsEventsName.searchQuery,
                 withEventProperties: [AnalyticsEventsPropertiesKey.index: index,
                                       AnalyticsEventsPropertiesKey.length: length])
    }

    func logShowObject(type: String, layout: DetailsLayout) {
        logEvent(
            AnalyticsEventsName.showObject,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type,
                                  AnalyticsEventsPropertiesKey.layout: layout.rawValue]
        )
    }

    func logObjectTypeChange(_ type: String) {
        logEvent(AnalyticsEventsName.objectTypeChange,
                 withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type])
    }

    func logLayoutChange(_ layout: DetailsLayout) {
        logEvent(AnalyticsEventsName.changeLayout,
                 withEventProperties: [AnalyticsEventsPropertiesKey.layout: layout.rawValue])
    }

    func logSetAlignment(_ alignment: LayoutAlignment, isBlock: Bool) {
        if isBlock {
            logEvent(AnalyticsEventsName.blockListSetAlign,
                     withEventProperties: [AnalyticsEventsPropertiesKey.align: alignment.name])
        } else {
            logEvent(AnalyticsEventsName.setLayoutAlign,
                     withEventProperties: [AnalyticsEventsPropertiesKey.align: alignment.name])
        }
    }

    func logCreateBlock(type: String, style: String) {
        logEvent(AnalyticsEventsName.blockCreate,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: type,
                                       AnalyticsEventsPropertiesKey.blockStyle: style])
    }

    func logUploadMedia(type: FileContentType) {
        logEvent(AnalyticsEventsName.blockUpload,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logDownloadMedia(type: FileContentType) {
        logEvent(AnalyticsEventsName.downloadFile,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logReorderBlock(count: Int) {
        logEvent(AnalyticsEventsName.reorderBlock,
                 withEventProperties: [AnalyticsEventsPropertiesKey.count: count])
    }

    func logAddRelation(format: RelationMetadata.Format, isNew: Bool, type: AnalyticsEventsRelationType) {
        let eventName = isNew ? AnalyticsEventsName.createRelation : AnalyticsEventsName.addExistingRelation
        logEvent(eventName,
                 withEventProperties: [AnalyticsEventsPropertiesKey.format: format.analyticString,
                                       AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logChangeRelationValue(type: AnalyticsEventsRelationType) {
        logEvent(AnalyticsEventsName.changeRelationValue,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logCreateObject(objectType: String, route: AnalyticsEventsRouteKind) {
        var objectType = objectType

        // suppose that bundled type start with underscore
        if !objectType.starts(with: "_") {
            objectType = AnalyticsEventsTypeValues.customType
        }

        logEvent(AnalyticsEventsName.createObject,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: objectType,
                                       AnalyticsEventsPropertiesKey.route: route.rawValue
                                      ])
    }
}
