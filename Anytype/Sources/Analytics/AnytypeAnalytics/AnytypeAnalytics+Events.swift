import Services
import UIKit
import AnytypeCore

extension AnytypeAnalytics {
    func logAccountCreate(analyticsId: String, middleTime: Int) {

        logEvent(
            "CreateAccount",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.accountId : analyticsId,
                AnalyticsEventsPropertiesKey.middleTime : middleTime
            ]
        )
    }
    
    func logAccountOpen(analyticsId: String) {
        logEvent(
            "OpenAccount",
            withEventProperties: [AnalyticsEventsPropertiesKey.accountId : analyticsId]
        )
    }
    
    func logLogout(route: LogoutRoute? = nil) {
        logEvent(
            "LogOut",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route?.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logDeleteAccount() {
        logEvent("DeleteAccount")
    }
    
    func logCancelDeletion() {
        logEvent("CancelDeletion")
    }
    
    func logDeletion(count: Int, route: RemoveCompletelyRoute) {
        logEvent(
            "RemoveCompletely",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.count: count,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logChangeBlockStyle(_ style: BlockText.Style, route: AnalyticsEventsRouteKind? = nil) {
        logEvent(
            "ChangeBlockStyle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.blockStyle: style.analyticsValue,
                AnalyticsEventsPropertiesKey.route: route?.rawValue
            ].compactMapValues { $0 }
        )
    }

    func logChangeBlockStyle(_ markupType: MarkupType, route: AnalyticsEventsRouteKind? = nil) {
        logEvent(
            "ChangeBlockStyle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: markupType.analyticsValue,
                AnalyticsEventsPropertiesKey.route: route?.rawValue
            ].compactMapValues { $0 }
        )
    }

    func logChangeTextStyle(markupType: MarkupType, objectType: StyleObjectType) {
        logEvent(
            "ChangeTextStyle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: markupType.analyticsValue,
                AnalyticsEventsPropertiesKey.objectType: objectType.rawValue
            ]
        )
    }
    
    func logBlockBookmarkOpenUrl() {
        logEvent("BlockBookmarkOpenUrl")
    }
    
    func logOpenAsObject() {
        logEvent("OpenAsObject")
    }
    
    func logOpenAsSource() {
        logEvent("OpenAsSource")
    }

    func logAddToFavorites(_ isFavorites: Bool) {
        if isFavorites {
            logEvent("AddToFavorites")
        } else {
            logEvent("RemoveFromFavorites")
        }
    }

    func logMoveToBin(_ isArchived: Bool) {
        if isArchived {
            logEvent("MoveToBin")
        } else {
            logEvent("RestoreFromBin")
        }
    }
    
    func logPinObjectType(analyticsType: AnalyticsObjectType) {
        logEvent(
            "PinObjectType",
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: analyticsType.analyticsId]
        )
    }
    
    func logUnpinObjectType(analyticsType: AnalyticsObjectType) {
        logEvent(
            "UnpinObjectType",
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: analyticsType.analyticsId]
        )
    }
    
    func logTypeSearchResult() {
        logEvent("TypeSearchResult")
    }

    func logKeychainPhraseShow(_ context: AnalyticsEventsKeychainContext) {
        logEvent("ScreenKeychain",
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: context.rawValue])
    }

    func logKeychainPhraseCopy(_ context: AnalyticsEventsKeychainContext) {
        logEvent("KeychainCopy",
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: context.rawValue])
    }

    func logDefaultObjectTypeChange(_ type: AnalyticsObjectType, route: AnalyticsDefaultObjectTypeChangeRoute) {
        logEvent("DefaultTypeChange",
                 withEventProperties: [
                    AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                    AnalyticsEventsPropertiesKey.route: route.rawValue
                 ])
    }

    func logSelectTheme(_ userInterfaceStyle: UIUserInterfaceStyle) {
        logEvent("ThemeSet",
                 withEventProperties: [AnalyticsEventsPropertiesKey.id: userInterfaceStyle.analyticsId])
    }

    func logScreenObject(type: AnalyticsObjectType, layout: DetailsLayout, spaceId: String) {
        logEvent(
            "ScreenObject",
            spaceId: spaceId,
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                                  AnalyticsEventsPropertiesKey.layout: layout.rawValue]
        )
    }

    func logChangeObjectType(_ type: AnalyticsObjectType, spaceId: String, route: ChangeObjectTypeRoute? = nil) {
        logEvent(
            "ChangeObjectType",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                AnalyticsEventsPropertiesKey.route: route?.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logSelectObjectType(_ type: AnalyticsObjectType, route: SelectObjectTypeRoute) {
        logEvent(
            "SelectObjectType",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }

    func logLayoutChange(_ layout: DetailsLayout) {
        logEvent("ChangeLayout",
                 withEventProperties: [AnalyticsEventsPropertiesKey.layout: layout.rawValue])
    }

    func logSetAlignment(_ alignment: LayoutAlignment, isBlock: Bool, route: AnalyticsEventsRouteKind? = nil) {
        let properties = [
            AnalyticsEventsPropertiesKey.align: alignment.analyticsValue,
            AnalyticsEventsPropertiesKey.route: route?.rawValue
        ].compactMapValues { $0 }
        
        if isBlock {
            logEvent("ChangeBlockAlign", withEventProperties: properties)
        } else {
            logEvent("SetLayoutAlign", withEventProperties: properties)
        }
    }
    
    func logSetIcon() {
        logEvent("SetIcon")
    }
    
    func logRemoveIcon() {
        logEvent("RemoveIcon")
    }
    
    func logSetCover() {
        logEvent("SetCover")
    }
    
    func logRemoveCover() {
        logEvent("RemoveCover")
    }

    func logCreateBlock(type: BlockContentType, spaceId: String, route: AnalyticsEventsRouteKind? = nil) {
        logCreateBlock(type: type.analyticsValue, spaceId: spaceId, route: route, style: type.styleAnalyticsValue)
    }
    
    func logCreateFileBlock(type: BlockContentType, spaceId: String, route: AnalyticsEventsRouteKind, fileExtension: String) {
        logCreateBlock(type: type.analyticsValue, spaceId: spaceId, route: route, fileExtension: fileExtension)
    }
    
    func logCreateBlock(type: String, spaceId: String, route: AnalyticsEventsRouteKind? = nil, style: String? = nil, fileExtension: String? = nil) {
        var props = [String: String]()
        props[AnalyticsEventsPropertiesKey.type] = type
        if let style = style {
            props[AnalyticsEventsPropertiesKey.blockStyle] = style
        }
        
        if let fileExtension {
            props[AnalyticsEventsPropertiesKey.fileExtension] = fileExtension
        }
        
        if let route {
            props[AnalyticsEventsPropertiesKey.route] = route.rawValue
        }

        logEvent("CreateBlock", spaceId: spaceId, withEventProperties: props)
    }
    
    func logDeleteBlock() {
        logEvent("DeleteBlock")
    }
    
    func logUploadMedia(type: FileContentType, spaceId: String, route: UploadMediaRoute) {
        logEvent(
            "UploadMedia",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }

    func logDownloadMedia(type: FileContentType, spaceId: String) {
        logEvent(
            "DownloadMedia",
            spaceId: spaceId,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }

    func logReorderBlock(count: Int) {
        logEvent("ReorderBlock",
                 withEventProperties: [AnalyticsEventsPropertiesKey.count: count])
    }
    
    func logAddExistingOrCreateRelation(
        format: PropertyFormat,
        isNew: Bool,
        type: AnalyticsEventsRelationType,
        key: AnalyticsRelationKey,
        spaceId: String,
        route: AnalyticsEventsRouteKind? = nil
    ) {
        let properties = [
            AnalyticsEventsPropertiesKey.format: format.analyticsName,
            AnalyticsEventsPropertiesKey.type: type.rawValue,
            AnalyticsEventsPropertiesKey.relationKey: key.value,
            AnalyticsEventsPropertiesKey.route: route?.rawValue
        ].compactMapValues { $0 }
        
        logEvent(
            isNew ? "CreateRelation" : "AddExistingRelation",
            spaceId: spaceId,
            withEventProperties: properties
        )
    }

    func logChangeOrDeleteRelationValue(
        isEmpty: Bool,
        format: PropertyFormat,
        type: AnalyticsEventsRelationType,
        key: AnalyticsRelationKey,
        spaceId: String
    ) {
        logEvent(
            isEmpty ? "DeleteRelationValue" : "ChangeRelationValue",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.format: format.analyticsName,
                AnalyticsEventsPropertiesKey.relationKey: key.value
            ]
        )
    }

    func logCreateObject(objectType: AnalyticsObjectType, spaceId: String, route: AnalyticsEventsRouteKind) {
        logCreateObject(objectTypeId: objectType.analyticsId, spaceId: spaceId, route: route)
    }
    
    func logCreateObject(objectTypeId: String, spaceId: String, route: AnalyticsEventsRouteKind) {
        let properties = [
            AnalyticsEventsPropertiesKey.objectType: objectTypeId,
            AnalyticsEventsPropertiesKey.route: route.rawValue
        ]
        logEvent("CreateObject", spaceId: spaceId, withEventProperties: properties)
    }
    
    func logCreateObjectType(spaceId: String) {
        let properties = [
            AnalyticsEventsPropertiesKey.objectType: "_otobjectType",
            AnalyticsEventsPropertiesKey.format: "Page"
        ]
        logEvent("CreateObject", spaceId: spaceId, withEventProperties: properties)
    }
    
    func logLinkToObject(type: AnalyticsEventsLinkToObjectType, spaceId: String) {
        logEvent(
            "LinkToObject",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.linkType: type.rawValue
            ]
        )
    }
    
    // MARK: - Collection
    func logScreenCollection(with type: String, spaceId: String) {
        logEvent(
            "ScreenCollection",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object,
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    // MARK: - Type
    
    func logScreenType(objectType: AnalyticsObjectType?, spaceId: String) {
        logEvent(
            "ScreenType",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType?.analyticsId ?? ""
            ]
        )
    }
    
    func logSetObjectTitle(objectType: AnalyticsObjectType?) {
        logEvent(
            "SetObjectTitle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType?.analyticsId ?? ""
            ]
        )
    }
    
    func logChangeRecommendedLayout(objectType: AnalyticsObjectType, layout: DetailsLayout) {
        logEvent(
            "ChangeRecommendedLayout",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.layout: layout.rawValue
            ]
        )
    }
    
    func logChangeTypeSort(type: String, sort: String) {
        logEvent(
            "ChangeTypeSort",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.sort: sort
            ]
        )
    }
    
    // MARK: - Set
    func logScreenSet(with type: String, spaceId: String) {
        logEvent(
            "ScreenSet",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object,
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    func logSetSelectQuery() {
        logEvent(
            "SetSelectQuery",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: AnalyticsEventsSetQueryType.type,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSetTurnIntoCollection() {
        logEvent(
            "SetTurnIntoCollection",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    // MARK: - Set/Collection views
    func logAddView(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            "AddView",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSwitchView(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            "SwitchView",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logRepositionView(objectType: AnalyticsObjectType) {
        logEvent(
            "RepositionView",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logRemoveView(objectType: AnalyticsObjectType) {
        logEvent(
            "RemoveView",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logChangeViewType(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            "ChangeViewType",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logDuplicateView(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            "DuplicateView",
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
            "AddFilter",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.condition: condition,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logChangeFilterValue(condition: String, objectType: AnalyticsObjectType) {
        logEvent(
            "ChangeFilterValue",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.condition: condition,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logFilterRemove(objectType: AnalyticsObjectType) {
        logEvent(
            "RemoveFilter",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    // MARK: - Set/Collection sorts
    func logAddSort(objectType: AnalyticsObjectType) {
        logEvent(
            "AddSort",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logChangeSortValue(type: String, objectType: AnalyticsObjectType) {
        logEvent(
            "ChangeSortValue",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logRepositionSort(objectType: AnalyticsObjectType) {
        logEvent(
            "RepositionSort",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logSortRemove(objectType: AnalyticsObjectType) {
        logEvent(
            "RemoveSort",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object
            ]
        )
    }
    
    func logEditWidget() {
        logEvent("EditWidget")
    }
    
    func logAddWidget(context: AnalyticsWidgetContext, createType: WidgetCreateType) {
        logEvent(
            "AddWidget",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.context: context.rawValue,
                AnalyticsEventsPropertiesKey.widgetType: createType.rawValue
            ]
        )
    }
    
    func logClickAddWidget(context: AnalyticsWidgetContext) {
        logEvent(
            "ClickAddWidget",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logDeleteWidget(source: AnalyticsWidgetSource, context: AnalyticsWidgetContext, createType: WidgetCreateType) {
        logEvent(
            "DeleteWidget",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.context: context.rawValue,
                AnalyticsEventsPropertiesKey.widgetType: createType.rawValue,
            ]
        )
    }
    
    func logClickWidgetTitle(source: AnalyticsWidgetSource, createType: WidgetCreateType) {
        logEvent(
            "ClickWidgetTitle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.tab: source.analyticsId,
                AnalyticsEventsPropertiesKey.widgetType: createType.rawValue,
            ]
        )
    }
    
    func logShowHome() {
        logEvent("ScreenHome")
    }
    
    func logChangeWidgetSource(source: AnalyticsWidgetSource, route: AnalyticsWidgetRoute, context: AnalyticsWidgetContext) {
        logEvent(
            "ChangeWidgetSource",
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
            "ChangeWidgetLayout",
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
            "ReorderWidget",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId
            ]
        )
    }
    
    func logOpenSidebarGroupToggle(source: AnalyticsWidgetSource) {
        logEvent(
            "OpenSidebarGroupToggle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId
            ]
        )
    }
    
    func logCloseSidebarGroupToggle(source: AnalyticsWidgetSource) {
        logEvent(
            "CloseSidebarGroupToggle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId
            ]
        )
    }
    
    func logMainAuthScreenShow() {
        logEvent("ScreenIndex")
    }
    
    func logStartCreateAccount() {
        logEvent("StartCreateAccount")
    }
    
    func logLoginScreenShow() {
        logEvent("ScreenLogin")
    }
    
    func logScreenSettingsPersonal() {
        logEvent("ScreenSettingsPersonal")
    }
    
    func logScreenSettingsDelete() {
        logEvent("ScreenSettingsDelete")
    }
    
    func logSettingsWallpaperSet() {
        logEvent("SettingsWallpaperSet")
    }
    
    func logScreenSearch(spaceId: String, type: ScreenSearchType) {
        logEvent(
            "ScreenSearch",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue
            ])
    }
    
    func logSearchResult(spaceId: String, objectType: String? = nil) {
        logEvent(
            "SearchResult",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType
            ].compactMapValues { $0 }
        )
    }
    
    func logSearchInput(spaceId: String, route: SearchInputRoute? = nil) {
        logEvent(
            "SearchInput",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route?.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logLockPage(_ isLocked: Bool) {
        if isLocked {
            logLockPage()
        } else {
            logUnlockPage()
        }
    }
    
    func logLockPage() {
        logEvent("LockPage")
    }
    
    func logUnlockPage() {
        logEvent("UnlockPage")
    }
    
    func logUndo(resultType: UndoRedoResultType) {
        logEvent(
            "Undo",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: resultType.rawValue
            ]
        )
    }
    
    func logRedo(resultType: UndoRedoResultType) {
        logEvent(
            "Redo",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: resultType.rawValue
            ]
        )
    }
    
    func logDuplicateObject(count: Int, objectType: AnalyticsObjectType, spaceId: String) {
        logEvent(
            "DuplicateObject",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.count: count,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
            ]
        )
    }
    
    func logCopyBlock(spaceId: String, countBlocks: Int) {
        logEvent("CopyBlock", spaceId: spaceId, withEventProperties: [AnalyticsEventsPropertiesKey.count: countBlocks])
    }
    
    func logPasteBlock(spaceId: String, countBlocks: Int) {
        logEvent("PasteBlock", spaceId: spaceId, withEventProperties: [AnalyticsEventsPropertiesKey.count: countBlocks])
    }
    
    func logSetObjectDescription() {
        logEvent("SetObjectDescription")
    }
    
    func logMoveBlock() {
        logEvent("MoveBlock")
    }
    
    func logChangeBlockBackground(color: MiddlewareColor, route: AnalyticsEventsRouteKind? = nil) {
        logEvent("ChangeBlockBackground", withEventProperties: [
            AnalyticsEventsPropertiesKey.color: color.rawValue,
            AnalyticsEventsPropertiesKey.route: route?.rawValue
        ].compactMapValues { $0 })
    }
    
    func logChangeBlockColor(route: AnalyticsEventsRouteKind? = nil) {
        logEvent("ChangeBlockColor", withEventProperties: [
            AnalyticsEventsPropertiesKey.route: route?.rawValue
        ].compactMapValues { $0 })
    }
    
    func logScreenSettingsStorageIndex() {
        logEvent("ScreenSettingsStorageIndex")
    }
    
    func logScreenSettingsSpaceStorageManager() {
        logEvent("ScreenSettingsSpaceStorageManager")
    }
    
    func logScreenFileOffloadWarning() {
        logEvent("ScreenFileOffloadWarning")
    }
    
    func logSettingsStorageOffload() {
        logEvent("SettingsStorageOffload")
    }
    
    func logShowDeletionWarning(route: ShowDeletionWarningRoute) {
        logEvent(
            "ShowDeletionWarning",
            withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue]
        )
    }
    
    func logMenuHelp() {
        logEvent("MenuHelp")
    }
    
    func logWhatsNew() {
        logEvent("MenuHelpWhatsNew")
    }
    
    func logAnytypeCommunity() {
        logEvent("MenuHelpCommunity")
    }
    
    func logHelpAndTutorials() {
        logEvent("MenuHelpTutorial")
    }
    
    func logContactUs() {
        logEvent("MenuHelpContact")
    }
    
    func logTermsOfUse() {
        logEvent("MenuHelpTerms")
    }
    
    func logPrivacyPolicy() {
        logEvent("MenuHelpPrivacy")
    }
    
    func logScreenOnboarding(step: ScreenOnboardingStep) {
        logEvent(
            "ScreenOnboarding",
            withEventProperties: [AnalyticsEventsPropertiesKey.step: step.rawValue]
        )
    }
    
    func logClickOnboarding(step: ClickOnboardingStep, type: String) {
        logEvent(
            "ClickOnboarding",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.step: step.rawValue,
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    func logScreenOnboardingEnterEmail() {
        logEvent("ScreenOnboardingEnterEmail")
    }
    
    func logScreenOnboardingSkipEmail() {
        logEvent("ScreenOnboardingSkipEmail")
    }
    
    func logClickOnboarding(step: ScreenOnboardingStep, button: ClickOnboardingButton) {
        logEvent(
            "ClickOnboarding",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: button.rawValue,
                AnalyticsEventsPropertiesKey.step: step.rawValue
            ]
        )
    }
    
    func logClickLogin(button: ClickLoginButton) {
        logEvent(
            "ClickLogin",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: button.rawValue]
        )
    }
    
    func logOnboardingSkipName() {
        logEvent("ScreenOnboardingSkipName")
    }
    
    func logScreenTemplateSelector() {
        logEvent("ScreenTemplateSelector")
    }
    
    func logTemplateSelection(objectType: AnalyticsObjectType?, route: AnalyticsEventsRouteKind) {
        logEvent(
            "SelectTemplate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType?.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logChangeDefaultTemplate(objectType: AnalyticsObjectType?, route: AnalyticsEventsRouteKind) {
        logEvent(
            "ChangeDefaultTemplate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType?.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logTemplateEditing(objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        logEvent(
            "EditTemplate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logTemplateDuplicate(objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        logEvent(
            "DuplicateTemplate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logTemplateCreate(objectType: AnalyticsObjectType, spaceId: String) {
        logEvent(
            "CreateTemplate",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logOnboardingTooltip(tooltip: OnboardingTooltip) {
        logEvent(
            "OnboardingTooltip",
            withEventProperties: [AnalyticsEventsPropertiesKey.id: tooltip.rawValue]
        )
    }
    
    func logOnboardingTooltip(tooltip: OnboardingTooltip, step: Int) {
        logEvent(
            "OnboardingTooltip",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.id: tooltip.rawValue,
                AnalyticsEventsPropertiesKey.step: "\(step)"
            ]
        )
    }
    
    func logClickOnboardingTooltip(tooltip: OnboardingTooltip, type: ClickOnboardingTooltipType) {
        logEvent(
            "ClickOnboardingTooltip",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.id: tooltip.rawValue,
                AnalyticsEventsPropertiesKey.type: type.rawValue
            ]
        )
    }
    
    func logCreateLink(spaceId: String, objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        logEvent(
            "CreateLink",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logScreenSettingsSpaceCreate() {
        logEvent("ScreenSettingsSpaceCreate")
    }
    
    func logCreateSpace(spaceId: String, spaceUxType: SpaceUxType, route: CreateSpaceRoute) {
        logEvent(
            "CreateSpace",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route.rawValue,
                AnalyticsEventsPropertiesKey.uxType: spaceUxType.analyticsValue
            ]
        )
    }
    
    func logCreateSpace(spaceAccessType: SpaceAccessType, spaceUxType: SpaceUxType, route: CreateSpaceRoute) {
        logEvent(
            "CreateSpace",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.spaceType: spaceAccessType.analyticsType.rawValue,
                AnalyticsEventsPropertiesKey.route: route.rawValue,
                AnalyticsEventsPropertiesKey.uxType: spaceUxType.analyticsValue
            ]
        )
    }
    
    func logSwitchSpace() {
        logEvent("SwitchSpace")
    }
    
    func logClickDeleteSpace(route: ClickDeleteSpaceRoute) {
        logEvent("ClickDeleteSpace", withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue])
    }
    
    func logClickDeleteSpaceWarning(type: ClickDeleteSpaceWarningType) {
        logEvent("ClickDeleteSpaceWarning", withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logDeleteSpace(type: SpaceAccessAnalyticsType) {
        logEvent("DeleteSpace", withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logScreenSettingsSpaceIndex() {
        logEvent("ScreenSettingsSpaceIndex")
    }
    
    func logScreenSettingsAccount() {
        logEvent("ScreenSettingsAccount")
    }
    
    func logScreenSettingsAccountAccess() {
        logEvent("ScreenSettingsAccountAccess")
    }
    
    func logSelectNetwork(type: SelectNetworkType, route: SelectNetworkRoute) {
        logEvent(
            "SelectNetwork",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logUploadNetworkConfiguration() {
        logEvent("UploadNetworkConfiguration")
    }
    
    func logScreenGalleryInstall(name: String) {
        logEvent(
            "ScreenGalleryInstall",
            withEventProperties: [AnalyticsEventsPropertiesKey.name: name]
        )
    }
    
    func logClickGalleryInstall() {
        logEvent("ClickGalleryInstall")
    }
    
    func logClickGalleryInstallSpace(type: ClickGalleryInstallSpaceType) {
        logEvent(
            "ClickGalleryInstallSpace",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logGalleryInstall(name: String) {
        logEvent(
            "GalleryInstall",
            withEventProperties: [AnalyticsEventsPropertiesKey.name: name]
        )
    }
    
    func logShareSpace() {
        logEvent("ShareSpace")
    }
    
    func logScreenSettingsSpaceShare(route: SettingsSpaceShareRoute) {
        logEvent("ScreenSettingsSpaceShare", withEventProperties: [AnalyticsEventsPropertiesKey.route:  route.rawValue])
    }
    
    func logClickShareSpaceCopyLink(route: ClickShareSpaceCopyLinkRoute) {
        logEvent("ClickShareSpaceCopyLink", withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue])
    }
    
    func logScreenStopShare() {
        logEvent("ScreenStopShare")
    }
    
    func logStopSpaceShare() {
        logEvent("StopSpaceShare")
    }
    
    func logClickSettingsSpaceShare(type: ClickSettingsSpaceShareType) {
        logEvent(
            "ClickSettingsSpaceShare",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logScreenRevokeShareLink() {
        logEvent("ScreenRevokeShareLink")
    }
    
    func logRevokeShareLink() {
        logEvent("RevokeShareLink")
    }
    
    func logScreenInviteConfirm(route: ScreenInviteConfirmRoute) {
        logEvent(
            "ScreenInviteConfirm",
            withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue]
        )
    }
    
    func logApproveInviteRequest(type: PermissionAnalyticsType, spaceUxType: SpaceUxType?) {
        logEvent(
            "ApproveInviteRequest",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.uxType: spaceUxType?.analyticsValue
            ].compactMapValues { $0 }
        )
    }
    
    func logRejectInviteRequest() {
        logEvent("RejectInviteRequest")
    }
    
    func logChangeSpaceMemberPermissions(type: PermissionAnalyticsType) {
        logEvent(
            "ChangeSpaceMemberPermissions",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logRemoveSpaceMember() {
        logEvent("RemoveSpaceMember")
    }
    
    func logScreenInviteRequest(type: ScreenInviteRequestType) {
        logEvent("ScreenInviteRequest", withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logScreenSpaceLinkTypePicker() {
        logEvent("ScreenSpaceLinkTypePicker")
    }
    
    func logClickJoinSpaceWithoutApproval() {
        logEvent("ClickJoinSpaceWithoutApproval")
    }
    
    func logClickShareSpaceShareLink(route: ClickShareSpaceShareLinkRoute) {
        logEvent("ClickShareSpaceShareLink", withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue])
    }
    
    func logClickShareSpaceNewLink(type: ClickShareSpaceNewLinkType) {
        logEvent("ClickShareSpaceNewLink", withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logScreenRequestSent() {
        logEvent("ScreenRequestSent")
    }
    
    func logScreenSettingsSpaceList() {
        logEvent("ScreenSettingsSpaceList")
    }
    
    func logScreenLeaveSpace() {
        logEvent("ScreenLeaveSpace")
    }
    
    func logLeaveSpace() {
        logEvent("LeaveSpace")
    }
    
    func logApproveLeaveRequest() {
        logEvent("ApproveLeaveRequest")
    }
    
    func logScreenQr(type: ScreenQrAnalyticsType, route: ScreenQrRoute) {
        logEvent("ScreenQr", withEventProperties: [
            AnalyticsEventsPropertiesKey.type: type.rawValue,
            AnalyticsEventsPropertiesKey.route: route.rawValue
        ])
    }
    
    func logClickQr() {
        logEvent("ClickQr", withEventProperties: [AnalyticsEventsPropertiesKey.type: "Share"])
    }
    
    func logScreenSettingsSpaceMembers(route: SettingsSpaceMembersRoute) {
        logEvent("ScreenSettingsSpaceMembers", withEventProperties: [AnalyticsEventsPropertiesKey.route:  route.rawValue])
    }
    
    func logDuplicateBlock(spaceId: String) {
        logEvent("DuplicateBlock", spaceId: spaceId)
    }
    
    func logDeleteRelation(spaceId: String, format: PropertyFormat, key: AnalyticsRelationKey? = nil, route: DeleteRelationRoute) {
        logEvent("DeleteRelation", spaceId: spaceId, withEventProperties: [
            AnalyticsEventsPropertiesKey.relationKey: key?.value ?? "",
            AnalyticsEventsPropertiesKey.format: format.analyticsName,
            AnalyticsEventsPropertiesKey.route: route.rawValue
        ])
    }
    
    func logScreenSettingsMembership() {
        logEvent("ScreenSettingsMembership")
    }
    
    func logScreenMembership(tier: MembershipTier) {
        logEvent("ScreenMembership", withEventProperties: [AnalyticsEventsPropertiesKey.name:  tier.name])
    }
    
    func logClickMembership(type: ClickMembershipType) {
        logEvent("ClickMembership", withEventProperties: [AnalyticsEventsPropertiesKey.type:  type.rawValue])
    }
    
    func logChangePlan(tier: MembershipTier) {
        logEvent("ChangePlan", withEventProperties: [AnalyticsEventsPropertiesKey.name:  tier.name])
    }
    
    func logClickUpgradePlanTooltip(type: ClickUpgradePlanTooltipType, route: ClickUpgradePlanTooltipRoute) {
        logEvent("ClickUpgradePlanTooltip", withEventProperties: [
            AnalyticsEventsPropertiesKey.type: type.rawValue,
            AnalyticsEventsPropertiesKey.route: route.rawValue
        ])
    }
    
    func logFileOffload() {
        logEvent("FileOffload")
    }
    
    func logScreenSettingsWallpaper() {
        logEvent("ScreenSettingsWallpaper")
    }
    
    func logScreenSettingsAppearance() {
        logEvent("ScreenSettingsAppearance")
    }
    
    func logScreenObjectTypeSearch() {
        logEvent("ScreenObjectTypeSearch")
    }
    
    func logScreenObjectRelation() {
        logEvent("ScreenObjectRelation")
    }
    
    func logBlockAction(type: String) {
        logEvent("BlockAction", withEventProperties: [AnalyticsEventsPropertiesKey.type:  type])
    }
    
    func logReloadSourceData() {
        logEvent("ReloadSourceData")
    }
    
    func logRelationUrlOpen() {
        logEvent("RelationUrlOpen")
    }
    
    func logRelationUrlCopy() {
        logEvent("RelationUrlCopy")
    }
    
    func logRelationUrlEditMobile() {
        logEvent("RelationUrlEditMobile")
    }
    
    func logScreenSlashMenu(route: ScreenSlashMenuRoute) {
        logEvent("ScreenSlashMenu", withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue])
    }
    
    func logClickSlashMenu(type: SlashMenuItemType) {
        logEvent("ClickSlashMenu", withEventProperties: [AnalyticsEventsPropertiesKey.type: type.analyticsType])
    }
    
    func logKeyboardBarStyleMenu() {
        logEvent("KeyboardBarStyleMenu")
    }
    
    func logKeyboardBarSelectionMenu() {
        logEvent("KeyboardBarSelectionMenu")
    }
    
    func logKeyboardBarUndoMenu() {
        logEvent("KeyboardBarUndoMenu")
    }
    
    func logKeyboardBarMentionMenu() {
        logEvent("KeyboardBarMentionMenu")
    }
    
    func logKeyboardBarHideKeyboardMenu() {
        logEvent("KeyboardBarHideKeyboardMenu")
    }
    
    func logScreenHistory() {
        logEvent("ScreenHistory")
    }
    
    func logScreenHistoryVersion() {
        logEvent("ScreenHistoryVersion")
    }
    
    func logRestoreFromHistory() {
        logEvent("RestoreFromHistory")
    }
    
    func logScreenVault(type: String) {
        logEvent("ScreenVault", withEventProperties: [AnalyticsEventsPropertiesKey.type:  type])
    }
    
    func logHistoryBack() {
        logEvent("HistoryBack")
    }
    
    func logScreenWidget() {
        logEvent("ScreenWidget")
    }
    
    func logScreenBin() {
        logEvent("ScreenBin")
    }
    
    func logScreenLibrary() {
        logEvent("ScreenLibrary")
    }
    
    func logChangeLibraryType(type: String) {
        logEvent(
            "ChangeLibraryType",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type]
        )
    }
    
    func logChangeLibraryTypeLink(type: String) {
        logEvent(
            "ChangeLibraryTypeLink",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type]
        )
    }
    
    func logChangeLibrarySort(type: String, sort: String) {
        logEvent(
            "ChangeLibrarySort",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.sort: sort
            ]
        )
    }
    
    func logLibraryResult() {
        logEvent("LibraryResult")
    }
    
    func logScreenDate() {
        logEvent("ScreenDate")
    }
    
    func logSwitchRelationDate(key: AnalyticsRelationKey) {
        logEvent(
            "SwitchRelationDate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.relationKey: key.value
            ]
        )
    }
    
    func logClickDateForward() {
        logEvent("ClickDateForward")
    }
    
    func logClickDateBack() {
        logEvent("ClickDateBack")
    }
    
    func logClickDateCalendarView() {
        logEvent("ClickDateCalendarView")
    }
    
    func logObjectListSort(route: ObjectListSortRoute, type: String) {
        logEvent(
            "ObjectListSort",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route.rawValue,
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    func logClickQuote() {
        logEvent("ClickQuote")
    }
    
    // nil if group was not changed
    func logReorderRelation(group: String?) {
        logEvent(
            "ReorderRelation",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.id: group ?? "SameGroup",
            ]
        )
    }
    
    func logConflictFieldHelp() {
        logEvent("ClickConflictFieldHelp")
    }
    
    func logAddConflictRelation() {
        logEvent("AddConflictRelation")
    }
    
    func logScreenEditType(route: EditTypeRoute) {
        logEvent(
            "ScreenEditType",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route.rawValue,
            ]
        )
    }
    
    func logOpenObjectByLink(type: OpenObjectByLinkType, route: OpenObjectByLinkRoute) {
        logEvent(
            "OpenObjectByLink",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.route: route.rawValue,
            ]
        )
    }
    
    func logOpenSidebarObject(createType: WidgetCreateType) {
        logEvent(
            "OpenSidebarObject",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.widgetType: createType.rawValue,
            ]
        )
    }
    
    func logAutoCreateTypeWidgetToggle(value: Bool) {
        logEvent(
            "AutoCreateTypeWidgetToggle",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: value,
            ]
        )
    }
    
    func logResetToTypeDefault() {
        logEvent(
            "ResetToTypeDefault",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: ResetToTypeDefaultRoute.object.rawValue
            ]
        )
    }
    
    func logScreenTypeTemplateSelector() {
        logEvent("ScreenTypeTemplateSelector")
    }
    
    func logReorderSpace() {
        logEvent("ReorderSpace")
    }
    
    func logClickVaultCreateMenuChat() {
        logEvent("ClickVaultCreateMenuChat")
    }
    
    func logClickVaultCreateMenuSpace() {
        logEvent("ClickVaultCreateMenuSpace")
    }
    
    func logScreenVaultCreateMenu() {
        logEvent("ScreenVaultCreateMenu")
    }
    
    func logClickScrollToReply() {
        logEvent("ClickScrollToReply")
    }
    
    func logClickScrollToMention() {
        logEvent("ClickScrollToMention")
    }
    
    func logClickScrollToBottom() {
        logEvent("ClickScrollToBottom")
    }
    
    func logChangeMessageNotificationState(type: String, route: ChangeMessageNotificationStateRoute) {
        logEvent(
            "ChangeMessageNotificationState",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.route: route.rawValue,
            ]
        )
    }
    
    func logClickMessageMenuEdit() {
        logEvent("ClickMessageMenuEdit")
    }
    
    func logClickMessageMenuDelete() {
        logEvent("ClickMessageMenuDelete")
    }
    
    func logClickMessageMenuCopy() {
        logEvent("ClickMessageMenuCopy")
    }
    
    func logClickMessageMenuReaction() {
        logEvent("ClickMessageMenuReaction")
    }
    
    func logDeleteMessage() {
        logEvent("DeleteMessage")
    }
    
    func logMention() {
        logEvent("Mention")
    }
    
    func logClickMessageMenuReply() {
        logEvent("ClickMessageMenuReply")
    }
    
    func logAttachItemChat(type: ChatAttachmentType) {
        logEvent(
            "AttachItemChat",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
            ]
        )
    }
    
    func logDetachItemChat() {
        logEvent("DetachItemChat")
    }
    
    func logScreenAllowPushType(_ type: ScreenAllowPushType) {
        logEvent(
            "ScreenAllowPush",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
            ]
        )
    }
    
    func logClickAllowPushType(_ type: ClickAllowPushType) {
        logEvent(
            "ClickAllowPush",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
            ]
        )
    }
    
    func logAllowPush() {
        logEvent("AllowPush")
    }
    
    func logClickScreenChatAttach(type: ChatAttachmentType, objectType: ObjectType? = nil) {
        logEvent(
            "ClickScreenChatAttach",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.objectType: objectType?.analyticsType.analyticsId
            ].compactMapValues { $0 }
        )
    }
    
    func logSentMessage(type: SentMessageType) {
        logEvent(
            "SentMessage",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
            ]
        )
    }
    
    func logOpenChatByPush() {
        logEvent("OpenChatByPush")
    }
    
    func logScreenChat(unreadMessageCount: Int32?, hasMention: Bool?) {
        logEvent(
            "ScreenChat",
            withEventProperties: .builder {
                if let unreadMessageCount {
                    [AnalyticsEventsPropertiesKey.unreadMessageCount: unreadMessageCount]
                }
                if let hasMention {
                    [AnalyticsEventsPropertiesKey.hasMention: hasMention]
                }
            }
        )
    }
    
    func logAddReaction() {
        logEvent("AddReaction")
    }
    
    func logRemoveReaction() {
        logEvent("RemoveReaction")
    }
    
    func logToggleReaction(added: Bool) {
        if added {
            logAddReaction()
        } else {
            logRemoveReaction()
        }
    }
    
    // MARK: - Publishing to Web
    
    func logClickShareObject(objectType: AnalyticsObjectType) {
        logEvent(
            "ClickShareObject",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logClickShareObjectPublish(objectType: AnalyticsObjectType) {
        logEvent(
            "ClickShareObjectPublish",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logClickShareObjectCopyUrl(objectType: AnalyticsObjectType) {
        logEvent(
            "ClickShareObjectCopyUrl",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logJoinSpaceButtonToPublish(objectType: AnalyticsObjectType, type: Bool) {
        logEvent(
            "JoinSpaceButtonToPublish",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    
    func logShareObjectPublish(objectType: AnalyticsObjectType) {
        logEvent(
            "ShareObjectPublish",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logClickShareObjectUnpublish(objectType: AnalyticsObjectType) {
        logEvent(
            "ClickShareObjectUnpublish",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logShareObjectUnpublish(objectType: AnalyticsObjectType) {
        logEvent(
            "ShareObjectUnpublish",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logClickShareObjectUpdate(objectType: AnalyticsObjectType) {
        logEvent(
            "ClickShareObjectUpdate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logShareObjectUpdate(objectType: AnalyticsObjectType) {
        logEvent(
            "ShareObjectUpdate",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logClickShareObjectOpenPage(objectType: AnalyticsObjectType, route: ShareObjectOpenPageRoute) {
        logEvent(
            "ClickShareObjectOpenPage",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logClickShareObjectShareLink(objectType: AnalyticsObjectType) {
        logEvent(
            "ClickShareObjectShareLink",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logScreenMedia(type: String) {
        logEvent(
            "ScreenMedia",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    func logSwipeMedia(type: String, route: MediaFileScreenRoute?) {
        logEvent(
            "SwipeMedia",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type,
                AnalyticsEventsPropertiesKey.route: route?.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logPinSpace() {
        logEvent("PinSpace")
    }
    
    func logUnpinSpace() {
        logEvent("UnpinSpace")
    }
    
    func logClickNavBarAddMenu(type: ClickNavBarAddMenuType, route: ClickNavBarAddMenuRoute?) {
        logEvent("ClickNavBarAddMenu", withEventProperties: [
            AnalyticsEventsPropertiesKey.route: route?.rawValue,
            AnalyticsEventsPropertiesKey.type: type.rawValue
        ].compactMapValues { $0 })
    }
    
    func logClickNavBarAddMenu(objectType: AnalyticsObjectType, route: ClickNavBarAddMenuRoute?) {
        logEvent("ClickNavBarAddMenu", withEventProperties: [
            AnalyticsEventsPropertiesKey.route: route?.rawValue,
            AnalyticsEventsPropertiesKey.type: objectType.analyticsId
        ].compactMapValues { $0 })
    }
}
