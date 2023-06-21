import Services
import UIKit

extension AnytypeAnalytics {
    func logAccountCreate(analyticsId: String) {

        logEvent(
            AnalyticsEventsName.createAccount,
            withEventProperties: [AnalyticsEventsPropertiesKey.accountId : analyticsId]
        )
    }
    
    func logAccountSelect(analyticsId: String) {
        logEvent(
            AnalyticsEventsName.openAccount,
            withEventProperties: [AnalyticsEventsPropertiesKey.accountId : analyticsId]
        )
    }
    
    func logDeletion(count: Int, route: RemoveCompletelyRoute) {
        logEvent(
            AnalyticsEventsName.objectListDelete,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.count: count,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logChangeBlockStyle(_ style: BlockText.Style) {
        logEvent(
            AnalyticsEventsName.changeBlockStyle,
            withEventProperties: [AnalyticsEventsPropertiesKey.blockStyle: style.analyticsValue]
        )
    }

    func logChangeBlockStyle(_ markupType: MarkupType) {
        logEvent(
            AnalyticsEventsName.changeBlockStyle,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: markupType.analyticsValue]
        )
    }

    func logChangeTextStyle(_ markupType: MarkupType) {
        logEvent(
            AnalyticsEventsName.changeTextStyle,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: markupType.analyticsValue]
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

    func logDefaultObjectTypeChange(_ type: AnalyticsObjectType) {
        logEvent(AnalyticsEventsName.defaultObjectTypeChange,
                 withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type.analyticsId])
    }

    func logSelectTheme(_ userInterfaceStyle: UIUserInterfaceStyle) {
        logEvent(AnalyticsEventsName.selectTheme,
                 withEventProperties: [AnalyticsEventsPropertiesKey.id: userInterfaceStyle.analyticsId])
    }

    func logShowObject(type: AnalyticsObjectType, layout: DetailsLayout) {
        logEvent(
            AnalyticsEventsName.showObject,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.analyticsId,
                                  AnalyticsEventsPropertiesKey.layout: layout.rawValue]
        )
    }

    func logObjectTypeChange(_ type: AnalyticsObjectType) {
        logEvent(AnalyticsEventsName.objectTypeChange,
                 withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type.analyticsId])
    }

    func logLayoutChange(_ layout: DetailsLayout) {
        logEvent(AnalyticsEventsName.changeLayout,
                 withEventProperties: [AnalyticsEventsPropertiesKey.layout: layout.rawValue])
    }

    func logSetAlignment(_ alignment: LayoutAlignment, isBlock: Bool) {
        if isBlock {
            logEvent(AnalyticsEventsName.blockListSetAlign,
                     withEventProperties: [AnalyticsEventsPropertiesKey.align: alignment.analyticsValue])
        } else {
            logEvent(AnalyticsEventsName.setLayoutAlign,
                     withEventProperties: [AnalyticsEventsPropertiesKey.align: alignment.analyticsValue])
        }
    }

    func logCreateBlock(type: String, style: String? = nil) {
        var props = [String: String]()
        props[AnalyticsEventsPropertiesKey.type] = type
        if let style = style {
            props[AnalyticsEventsPropertiesKey.blockStyle] = style
        }

        logEvent(AnalyticsEventsName.blockCreate, withEventProperties: props)
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

    func logAddRelation(format: RelationFormat, isNew: Bool, type: AnalyticsEventsRelationType) {
        let eventName = isNew ? AnalyticsEventsName.createRelation : AnalyticsEventsName.addExistingRelation
        logEvent(eventName,
                 withEventProperties: [AnalyticsEventsPropertiesKey.format: format.name,
                                       AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logChangeRelationValue(isEmpty: Bool, type: AnalyticsEventsRelationType) {
        logEvent(isEmpty ? AnalyticsEventsName.deleteRelationValue : AnalyticsEventsName.changeRelationValue,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logCreateObject(objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        logEvent(
            AnalyticsEventsName.createObject,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logCreateObjectNavBar(objectType: AnalyticsObjectType) {
        logEvent(AnalyticsEventsName.createObjectNavBar,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: objectType.analyticsId])
    }
    
    func logLinkToObject(type: AnalyticsEventsLinkToObjectType) {
        logEvent(
            AnalyticsEventsName.linkToObject,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.linkType: type.rawValue
            ]
        )
    }
    
    // MARK: - Collection
    func logScreenCollection() {
        logEvent(
            AnalyticsEventsName.screenCollection,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    // MARK: - Set
    func logScreenSet() {
        logEvent(
            AnalyticsEventsName.screenSet,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSetSelectQuery() {
        logEvent(
            AnalyticsEventsName.setSelectQuery,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: AnalyticsEventsSetQueryType.type,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSetTurnIntoCollection() {
        logEvent(
            AnalyticsEventsName.setTurnIntoCollection,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    // MARK: - Set/Collection views
    func logAddView(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.addView,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSwitchView(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.switchView,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logRepositionView(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.repositionView,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logRemoveView(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.removeView,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logChangeViewType(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.changeViewType,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logDuplicateView(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.duplicateView,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    // MARK: - Set/Collection filters
    func logAddFilter(condition: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.addFilter,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.condition: condition,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logChangeFilterValue(condition: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.сhangeFilterValue,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.condition: condition,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logFilterRemove(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.removeFilter,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    // MARK: - Set/Collection sorts
    func logAddSort(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.addSort,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logChangeSortValue(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.changeSortValue,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logRepositionSort(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.repositionSort,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSortRemove(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.removeSort,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logMigrationGoneWrong(type: AnalyticsEventsMigrationType?) {
        logEvent(
            AnalyticsEventsName.migrationGoneWrong,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type?.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logEditWidget() {
        logEvent(AnalyticsEventsName.Widget.edit)
    }
    
    func logAddWidget(context: AnalyticsWidgetContext) {
        logEvent(
            AnalyticsEventsName.Widget.add,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logDeleteWidget(source: AnalyticsWidgetSource, context: AnalyticsWidgetContext) {
        logEvent(
            AnalyticsEventsName.Widget.delete,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logSelectHomeTab(source: AnalyticsWidgetSource) {
        logEvent(
            AnalyticsEventsName.selectHomeTab,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.view: AnalyticsView.widget.rawValue,
                AnalyticsEventsPropertiesKey.tab: source.analyticsId
            ]
        )
    }
    
    func logShowHome(view: AnalyticsView) {
        logEvent(
            AnalyticsEventsName.homeShow,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.view: view.rawValue
            ]
        )
    }
    
    func logChangeWidgetSource(source: AnalyticsWidgetSource, route: AnalyticsWidgetRoute, context: AnalyticsWidgetContext) {
        logEvent(
            AnalyticsEventsName.Widget.changeSource,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue,
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logChangeWidgetLayout(
        source: AnalyticsWidgetSource,
        layout: BlockWidget.Layout,
        route: AnalyticsWidgetRoute,
        context: AnalyticsWidgetContext
    ) {
        logEvent(
            AnalyticsEventsName.Widget.changeLayout,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.layout: layout.analyticsValue,
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue,
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logReorderWidget(source: AnalyticsWidgetSource) {
        logEvent(
            AnalyticsEventsName.Widget.reorderWidget,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId
            ]
        )
    }
    
    func logOpenSidebarGroupToggle(source: AnalyticsWidgetSource) {
        logEvent(
            AnalyticsEventsName.Sidebar.openGroupToggle,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.view: AnalyticsView.widget.rawValue
            ]
        )
    }
    
    func logCloseSidebarGroupToggle(source: AnalyticsWidgetSource) {
        logEvent(
            AnalyticsEventsName.Sidebar.closeGroupToggle,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.view: AnalyticsView.widget.rawValue
            ]
        )
    }
    
    func logScreenAuthRegistration() {
        logEvent(AnalyticsEventsName.screenAuthRegistration)
    }
    
    func logScreenSettingsPersonal() {
        logEvent(AnalyticsEventsName.screenSettingsPersonal)
    }
    
    func logScreenSettingsDelete() {
        logEvent(AnalyticsEventsName.screenSettingsDelete)
    }
    
    func logSettingsWallpaperSet() {
        logEvent(AnalyticsEventsName.settingsWallpaperSet)
    }
    
    func logScreenSearch() {
        logEvent(AnalyticsEventsName.screenSearch)
    }
    
    func logSearchResult() {
        logEvent(AnalyticsEventsName.searchResult)
    }
    
    func logLockPage() {
        logEvent(AnalyticsEventsName.lockPage)
    }
    
    func logUnlockPage() {
        logEvent(AnalyticsEventsName.unlockPage)
    }
    
    func logUndo() {
        logEvent(AnalyticsEventsName.undo)
    }
    
    func logRedo() {
        logEvent(AnalyticsEventsName.redo)
    }
    
    func logDuplicateObject() {
        logEvent(AnalyticsEventsName.duplicateObject)
    }
    
    func logCopyBlock() {
        logEvent(AnalyticsEventsName.copyBlock)
    }
    
    func logPasteBlock() {
        logEvent(AnalyticsEventsName.pasteBlock)
    }
    
    func logSetObjectDescription() {
        logEvent(AnalyticsEventsName.setObjectDescription)
    }
    
    func logMoveBlock() {
        logEvent(AnalyticsEventsName.moveBlock)
    }
    
    func logChangeBlockBackground(color: MiddlewareColor) {
        logEvent(AnalyticsEventsName.changeBlockBackground, withEventProperties: [
            AnalyticsEventsPropertiesKey.color: color.rawValue
        ])
    }
    
    func logScreenSettingsStorageIndex() {
        logEvent(AnalyticsEventsName.screenSettingsStorageIndex)
    }
    
    func logScreenSettingsStorageManager() {
        logEvent(AnalyticsEventsName.screenSettingsStorageManager)
    }
    
    func logScreenFileOffloadWarning() {
        logEvent(AnalyticsEventsName.screenFileOffloadWarning)
    }
    
    func logSettingsStorageOffload() {
        logEvent(AnalyticsEventsName.settingsStorageOffload)
    }
    
    func logShowDeletionWarning(route: ShowDeletionWarningRoute) {
        logEvent(
            AnalyticsEventsName.showDeletionWarning,
            withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue]
        )
    }
    
    func logAboutSettingsShow() {
        logEvent(AnalyticsEventsName.aboutSettingsShow)
    }
    
    func logHelpAndCommunity(type: HelpAndCommunityType) {
        logEvent(
            AnalyticsEventsName.About.helpAndCommunity,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logLegal(type: LegalType) {
        logEvent(
            AnalyticsEventsName.About.legal,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
}
