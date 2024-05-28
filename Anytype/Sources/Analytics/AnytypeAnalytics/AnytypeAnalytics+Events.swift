import Services
import UIKit

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
    
    func logChangeBlockStyle(_ style: BlockText.Style) {
        logEvent(
            "ChangeBlockStyle",
            withEventProperties: [AnalyticsEventsPropertiesKey.blockStyle: style.analyticsValue]
        )
    }

    func logChangeBlockStyle(_ markupType: MarkupType) {
        logEvent(
            "ChangeBlockStyle",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: markupType.analyticsValue]
        )
    }

    func logChangeTextStyle(_ markupType: MarkupType) {
        logEvent(
            "ChangeTextStyle",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: markupType.analyticsValue]
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
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: analyticsType]
        )
    }
    
    func logUnpinObjectType(analyticsType: AnalyticsObjectType) {
        logEvent(
            "UnpinObjectType",
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: analyticsType]
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

    func logChangeObjectType(_ type: AnalyticsObjectType, spaceId: String) {
        logEvent(
            "ChangeObjectType",
            spaceId: spaceId,
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type.analyticsId]
        )
    }
    
    func logSelectObjectType(_ type: AnalyticsObjectType, route: SelectObjectTypeRoute) {
        logEvent(
            "SelectObjectType",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
    }

    func logLayoutChange(_ layout: DetailsLayout) {
        logEvent("ChangeLayout",
                 withEventProperties: [AnalyticsEventsPropertiesKey.layout: layout.rawValue])
    }

    func logSetAlignment(_ alignment: LayoutAlignment, isBlock: Bool) {
        if isBlock {
            logEvent("ChangeBlockAlign",
                     withEventProperties: [AnalyticsEventsPropertiesKey.align: alignment.analyticsValue])
        } else {
            logEvent("SetLayoutAlign",
                     withEventProperties: [AnalyticsEventsPropertiesKey.align: alignment.analyticsValue])
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
    
    func logUploadMedia(type: FileContentType, spaceId: String) {
        logEvent(
            "UploadMedia",
            spaceId: spaceId,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
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
        format: RelationFormat,
        isNew: Bool,
        type: AnalyticsEventsRelationType,
        spaceId: String
    ) {
        logEvent(
            isNew ? "CreateRelation" : "AddExistingRelation",
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.format: format.analyticsName,
                AnalyticsEventsPropertiesKey.type: type.rawValue
            ]
        )
    }

    func logChangeOrDeleteRelationValue(isEmpty: Bool, type: AnalyticsEventsRelationType, spaceId: String) {
        logEvent(
            isEmpty ? "DeleteRelationValue" : "ChangeRelationValue",
            spaceId: spaceId,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }

    func logCreateObject(objectType: AnalyticsObjectType, spaceId: String, route: AnalyticsEventsRouteKind) {
        let properties = [
            AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
            AnalyticsEventsPropertiesKey.route: route.rawValue
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
    
    func logAddWidget(context: AnalyticsWidgetContext) {
        logEvent(
            "AddWidget",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logDeleteWidget(source: AnalyticsWidgetSource, context: AnalyticsWidgetContext) {
        logEvent(
            "DeleteWidget",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId,
                AnalyticsEventsPropertiesKey.context: context.rawValue
            ]
        )
    }
    
    func logSelectHomeTab(source: AnalyticsWidgetSource) {
        logEvent(
            "SelectHomeTab",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.tab: source.analyticsId
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
    
    func logScreenAuthRegistration() {
        logEvent("ScreenAuthRegistration")
    }
    
    func logMainAuthScreenShow() {
        AnytypeAnalytics.instance().logEvent("ScreenIndex")
    }
    
    func logLoginScreenShow() {
        AnytypeAnalytics.instance().logEvent("ScreenLogin")
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
    
    func logScreenSearch() {
        logEvent("ScreenSearch")
    }
    
    func logSearchResult(spaceId: String) {
        logEvent("SearchResult", spaceId: spaceId)
    }
    
    func logSearchBacklink(spaceId: String) {
        logEvent("SearchBacklink", spaceId: spaceId)
    }
    
    func logSearchInput(spaceId: String) {
        logEvent("SearchInput", spaceId: spaceId)
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
    
    func logUndo() {
        logEvent("Undo")
    }
    
    func logRedo() {
        logEvent("Redo")
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
    
    func logCopyBlock(spaceId: String) {
        logEvent("CopyBlock", spaceId: spaceId)
    }
    
    func logPasteBlock(spaceId: String) {
        logEvent("PasteBlock", spaceId: spaceId)
    }
    
    func logSetObjectDescription() {
        logEvent("SetObjectDescription")
    }
    
    func logMoveBlock() {
        logEvent("MoveBlock")
    }
    
    func logChangeBlockBackground(color: MiddlewareColor) {
        logEvent("ChangeBlockBackground", withEventProperties: [
            AnalyticsEventsPropertiesKey.color: color.rawValue
        ])
    }
    
    func logScreenSettingsStorageIndex() {
        logEvent("ScreenSettingsStorageIndex")
    }
    
    func logScreenSettingsStorageManager() {
        logEvent("ScreenSettingsStorageManager")
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
        logEvent(AnalyticsEventsName.About.whatIsNew)
    }
    
    func logAnytypeCommunity() {
        logEvent(AnalyticsEventsName.About.anytypeCommunity)
    }
    
    func logHelpAndTutorials() {
        logEvent(AnalyticsEventsName.About.helpAndTutorials)
    }
    
    func logContactUs() {
        logEvent(AnalyticsEventsName.About.contactUs)
    }
    
    func logTermsOfUse() {
        logEvent(AnalyticsEventsName.About.termsOfUse)
    }
    
    func logPrivacyPolicy() {
        logEvent(AnalyticsEventsName.About.privacyPolicy)
    }
    
    func logGetMoreSpace() {
        logEvent(AnalyticsEventsName.FileStorage.getMoreSpace)
    }
    
    func logScreenOnboarding(step: ScreenOnboardingStep) {
        logEvent(
            "ScreenOnboarding",
            withEventProperties: [AnalyticsEventsPropertiesKey.step: step.rawValue]
        )
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
    
    func logClickOnboardingTooltip(tooltip: OnboardingTooltip, type: ClickOnboardingTooltipType) {
        logEvent(
            "ClickOnboardingTooltip",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.id: tooltip.rawValue,
                AnalyticsEventsPropertiesKey.type: type.rawValue
            ]
        )
    }
    
    func logCreateLink(spaceId: String) {
        logEvent("CreateLink", spaceId: spaceId)
    }
    
    func logScreenSettingsSpaceCreate() {
        logEvent("ScreenSettingsSpaceCreate")
    }
    
    func logCreateSpace(route: CreateSpaceRoute) {
        logEvent(
            "CreateSpace",
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route.rawValue
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
    
    func logScreenSettingsSpaceShare() {
        logEvent("ScreenSettingsSpaceShare")
    }
    
    func logClickShareSpaceCopyLink() {
        logEvent("ClickShareSpaceCopyLink")
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
    
    func logApproveInviteRequest(type: PermissionAnalyticsType) {
        logEvent(
            "ApproveInviteRequest",
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
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
    
    func logScreenInviteRequest() {
        logEvent("ScreenInviteRequest")
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
    
    func logScreenQr(type: ScreenQrAnalyticsType) {
        logEvent("ScreenQr", withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logClickQr() {
        logEvent("ClickQr", withEventProperties: [AnalyticsEventsPropertiesKey.type: "Share"])
    }
    
    func logScreenSettingsSpaceMembers() {
        logEvent("ScreenSettingsSpaceMembers")
    }
    
    func logDuplicateBlock(spaceId: String) {
        logEvent("DuplicateBlock", spaceId: spaceId)
    }
    
    func logFeatureRelation(spaceId: String) {
        logEvent("FeatureRelation", spaceId: spaceId)
    }
    
    func logUnfeatureRelation(spaceId: String) {
        logEvent("UnfeatureRelation", spaceId: spaceId)
    }
    
    func logDeleteRelation(spaceId: String) {
        logEvent("DeleteRelation", spaceId: spaceId)
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
    
    func logKeyboardBarSlashMenu() {
        logEvent("KeyboardBarSlashMenu")
    }
    
    func logKeyboardBarStyleMenu() {
        logEvent("KeyboardBarStyleMenu")
    }
    
    func logKeyboardBarSelectionMenu() {
        logEvent("KeyboardBarSelectionMenu")
    }
    
    func logKeyboardBarMentionMenu() {
        logEvent("KeyboardBarMentionMenu")
    }
    
    func logKeyboardBarHideKeyboardMenu() {
        logEvent("KeyboardBarHideKeyboardMenu")
    }
}
