import Services
import UIKit

extension AnytypeAnalytics {
    func logAccountCreate(analyticsId: String, middleTime: Int) {

        logEvent(
            AnalyticsEventsName.createAccount,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.accountId : analyticsId,
                AnalyticsEventsPropertiesKey.middleTime : middleTime
            ]
        )
    }
    
    func logAccountOpen(analyticsId: String) {
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

    func logDefaultObjectTypeChange(_ type: AnalyticsObjectType, route: AnalyticsDefaultObjectTypeChangeRoute) {
        logEvent(AnalyticsEventsName.defaultObjectTypeChange,
                 withEventProperties: [
                    AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                    AnalyticsEventsPropertiesKey.route: route.rawValue
                 ])
    }

    func logSelectTheme(_ userInterfaceStyle: UIUserInterfaceStyle) {
        logEvent(AnalyticsEventsName.selectTheme,
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
            AnalyticsEventsName.selectObjectType,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
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

    func logCreateBlock(type: BlockContentType, spaceId: String, route: AnalyticsEventsRouteKind? = nil) {
        logCreateBlock(type: type.analyticsValue, spaceId: spaceId, route: route, style: type.styleAnalyticsValue)
    }
    
    func logCreateBlock(type: String, spaceId: String, route: AnalyticsEventsRouteKind? = nil, style: String? = nil) {
        var props = [String: String]()
        props[AnalyticsEventsPropertiesKey.type] = type
        if let style = style {
            props[AnalyticsEventsPropertiesKey.blockStyle] = style
        }
        
        if let route {
            props[AnalyticsEventsPropertiesKey.route] = route.rawValue
        }

        logEvent(AnalyticsEventsName.blockCreate, spaceId: spaceId, withEventProperties: props)
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
        logEvent(AnalyticsEventsName.reorderBlock,
                 withEventProperties: [AnalyticsEventsPropertiesKey.count: count])
    }
    
    func logAddExistingOrCreateRelation(
        format: RelationFormat,
        isNew: Bool,
        type: AnalyticsEventsRelationType,
        spaceId: String
    ) {
        logEvent(
            isNew ? AnalyticsEventsName.createRelation : AnalyticsEventsName.addExistingRelation,
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.format: format.analyticsName,
                AnalyticsEventsPropertiesKey.type: type.rawValue
            ]
        )
    }

    func logChangeOrDeleteRelationValue(isEmpty: Bool, type: AnalyticsEventsRelationType, spaceId: String) {
        logEvent(
            isEmpty ? AnalyticsEventsName.deleteRelationValue : AnalyticsEventsName.changeRelationValue,
            spaceId: spaceId,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }

    func logCreateObject(objectType: AnalyticsObjectType, spaceId: String, route: AnalyticsEventsRouteKind) {
        let properties = [
            AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
            AnalyticsEventsPropertiesKey.route: route.rawValue
        ]
        logEvent(AnalyticsEventsName.createObject, spaceId: spaceId, withEventProperties: properties)
    }
    
    func logLinkToObject(type: AnalyticsEventsLinkToObjectType, spaceId: String) {
        logEvent(
            AnalyticsEventsName.linkToObject,
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.linkType: type.rawValue
            ]
        )
    }
    
    // MARK: - Collection
    func logScreenCollection(with type: String, spaceId: String) {
        logEvent(
            AnalyticsEventsName.screenCollection,
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
            AnalyticsEventsName.screenSet,
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object,
                AnalyticsEventsPropertiesKey.type: type
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
                AnalyticsEventsPropertiesKey.tab: source.analyticsId
            ]
        )
    }
    
    func logShowHome() {
        logEvent(AnalyticsEventsName.homeShow)
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
                AnalyticsEventsPropertiesKey.type: source.analyticsId
            ]
        )
    }
    
    func logCloseSidebarGroupToggle(source: AnalyticsWidgetSource) {
        logEvent(
            AnalyticsEventsName.Sidebar.closeGroupToggle,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: source.analyticsId
            ]
        )
    }
    
    func logScreenAuthRegistration() {
        logEvent(AnalyticsEventsName.screenAuthRegistration)
    }
    
    func logMainAuthScreenShow() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.mainAuthScreenShow)
    }
    
    func logLoginScreenShow() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.loginScreenShow)
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
    
    func logSearchResult(spaceId: String) {
        logEvent(AnalyticsEventsName.searchResult, spaceId: spaceId)
    }
    
    func logLockPage(_ isLocked: Bool) {
        if isLocked {
            logLockPage()
        } else {
            logUnlockPage()
        }
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
    
    func logDuplicateObject(count: Int, objectType: AnalyticsObjectType, spaceId: String) {
        logEvent(
            AnalyticsEventsName.duplicateObject,
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.count: count,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
            ]
        )
    }
    
    func logCopyBlock(spaceId: String) {
        logEvent(AnalyticsEventsName.copyBlock, spaceId: spaceId)
    }
    
    func logPasteBlock(spaceId: String) {
        logEvent(AnalyticsEventsName.pasteBlock, spaceId: spaceId)
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
    
    func logMenuHelp() {
        logEvent(AnalyticsEventsName.menuHelp)
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
            AnalyticsEventsName.screenOnboarding,
            withEventProperties: [AnalyticsEventsPropertiesKey.step: step.rawValue]
        )
    }
    
    func logClickOnboarding(step: ScreenOnboardingStep, button: ClickOnboardingButton) {
        logEvent(
            AnalyticsEventsName.clickOnboarding,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: button.rawValue,
                AnalyticsEventsPropertiesKey.step: step.rawValue
            ]
        )
    }
    
    func logClickLogin(button: ClickLoginButton) {
        logEvent(
            AnalyticsEventsName.clickLogin,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: button.rawValue]
        )
    }
    
    func logOnboardingSkipName() {
        logEvent(AnalyticsEventsName.onboardingSkipName)
    }
    
    func logTemplateSelection(objectType: AnalyticsObjectType?, route: AnalyticsEventsRouteKind) {
        logEvent(
            AnalyticsEventsName.selectTemplate,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType?.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logChangeDefaultTemplate(objectType: AnalyticsObjectType?, route: AnalyticsEventsRouteKind) {
        logEvent(
            AnalyticsEventsName.changeDefaultTemplate,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType?.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ].compactMapValues { $0 }
        )
    }
    
    func logTemplateEditing(objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        logEvent(
            AnalyticsEventsName.templateEditing,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logTemplateDuplicate(objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        logEvent(
            AnalyticsEventsName.duplicateTemplate,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: objectType.analyticsId,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logTemplateCreate(objectType: AnalyticsObjectType, spaceId: String) {
        logEvent(
            AnalyticsEventsName.createTemplate,
            spaceId: spaceId,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId
            ]
        )
    }
    
    func logOnboardingTooltip(tooltip: OnboardingTooltip) {
        logEvent(
            AnalyticsEventsName.onboardingTooltip,
            withEventProperties: [AnalyticsEventsPropertiesKey.id: tooltip.rawValue]
        )
    }
    
    func logClickOnboardingTooltip(tooltip: OnboardingTooltip, type: ClickOnboardingTooltipType) {
        logEvent(
            AnalyticsEventsName.clickOnboardingTooltip,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.id: tooltip.rawValue,
                AnalyticsEventsPropertiesKey.type: type.rawValue
            ]
        )
    }
    
    func logCreateLink(spaceId: String) {
        logEvent(AnalyticsEventsName.createLink, spaceId: spaceId)
    }
    
    func logScreenSettingsSpaceCreate() {
        logEvent(AnalyticsEventsName.screenSettingsSpaceCreate)
    }
    
    func logCreateSpace(route: CreateSpaceRoute) {
        logEvent(
            AnalyticsEventsName.createSpace,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logSwitchSpace() {
        logEvent(AnalyticsEventsName.switchSpace)
    }
    
    func logClickDeleteSpace(route: ClickDeleteSpaceRoute) {
        logEvent(AnalyticsEventsName.clickDeleteSpace, withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue])
    }
    
    func logClickDeleteSpaceWarning(type: ClickDeleteSpaceWarningType) {
        logEvent(AnalyticsEventsName.clickDeleteSpaceWarning, withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logDeleteSpace(type: SpaceAccessAnalyticsType) {
        logEvent(AnalyticsEventsName.deleteSpace, withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }
    
    func logScreenSettingsSpaceIndex() {
        logEvent(AnalyticsEventsName.screenSettingsSpaceIndex)
    }
    
    func logScreenSettingsAccount() {
        logEvent(AnalyticsEventsName.screenSettingsAccount)
    }
    
    func logScreenSettingsAccountAccess() {
        logEvent(AnalyticsEventsName.screenSettingsAccountAccess)
    }
    
    func logSelectNetwork(type: SelectNetworkType, route: SelectNetworkRoute) {
        logEvent(
            AnalyticsEventsName.selectNetwork,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.type: type.rawValue,
                AnalyticsEventsPropertiesKey.route: route.rawValue
            ]
        )
    }
    
    func logUploadNetworkConfiguration() {
        logEvent(AnalyticsEventsName.uploadNetworkConfiguration)
    }
    
    func logScreenGalleryInstall(name: String) {
        logEvent(
            AnalyticsEventsName.screenGalleryInstall,
            withEventProperties: [AnalyticsEventsPropertiesKey.name: name]
        )
    }
    
    func logClickGalleryInstall() {
        logEvent(AnalyticsEventsName.clickGalleryInstall)
    }
    
    func logClickGalleryInstallSpace(type: ClickGalleryInstallSpaceType) {
        logEvent(
            AnalyticsEventsName.clickGalleryInstallSpace,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logGalleryInstall(name: String) {
        logEvent(
            AnalyticsEventsName.galleryInstall,
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
}
