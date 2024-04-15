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

    func logShowObject(type: AnalyticsObjectType, layout: DetailsLayout) {
        logEvent(
            AnalyticsEventsName.showObject,
            withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
                                  AnalyticsEventsPropertiesKey.layout: layout.rawValue]
        )
    }

    func logObjectTypeChange(_ type: AnalyticsObjectType) {
        logEvent(AnalyticsEventsName.objectTypeChange,
                 withEventProperties: [AnalyticsEventsPropertiesKey.objectType: type.analyticsId])
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

    func logCreateBlock(type: BlockContentType, route: AnalyticsEventsRouteKind? = nil) {
        logCreateBlock(type: type.analyticsValue, route: route, style: type.styleAnalyticsValue)
    }
    
    func logCreateBlock(type: String,  route: AnalyticsEventsRouteKind? = nil, style: String? = nil) {
        var props = [String: String]()
        props[AnalyticsEventsPropertiesKey.type] = type
        if let style = style {
            props[AnalyticsEventsPropertiesKey.blockStyle] = style
        }
        
        if let route {
            props[AnalyticsEventsPropertiesKey.route] = route.rawValue
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
                 withEventProperties: [AnalyticsEventsPropertiesKey.format: format.analyticsName,
                                       AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logChangeRelationValue(isEmpty: Bool, type: AnalyticsEventsRelationType) {
        logEvent(isEmpty ? AnalyticsEventsName.deleteRelationValue : AnalyticsEventsName.changeRelationValue,
                 withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue])
    }

    func logCreateObject(objectType: AnalyticsObjectType, route: AnalyticsEventsRouteKind) {
        let properties = [
            AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
            AnalyticsEventsPropertiesKey.route: route.rawValue
        ]
        logEvent(AnalyticsEventsName.createObject, withEventProperties: properties)
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
    func logScreenCollection(with type: String) {
        logEvent(
            AnalyticsEventsName.screenCollection,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.embedType: AnalyticsEventsSetCollectionEmbedType.object,
                AnalyticsEventsPropertiesKey.type: type
            ]
        )
    }
    
    // MARK: - Set
    func logScreenSet(with type: String) {
        logEvent(
            AnalyticsEventsName.screenSet,
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
    
    func logSearchResult() {
        logEvent(AnalyticsEventsName.searchResult)
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
    
    func logDuplicateObject(count: Int, objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.duplicateObject,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.count: count,
                AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
            ]
        )
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
    
    func logTemplateCreate(objectType: AnalyticsObjectType) {
        logEvent(
            AnalyticsEventsName.createTemplate,
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
    
    func logCreateLink() {
        logEvent(AnalyticsEventsName.createLink)
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
    
    func logDeleteSpace(type: DeleteSpaceType) {
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
    
    func logSpaceShare() {
        logEvent(AnalyticsEventsName.shareSpace)
    }
    
    func logScreenSettingsSpaceShare() {
        logEvent(AnalyticsEventsName.screenSettingsSpaceShare)
    }
    
    func logClickShareSpaceCopyLink() {
        logEvent(AnalyticsEventsName.clickShareSpaceCopyLink)
    }
    
    func logScreenStopShare() {
        logEvent(AnalyticsEventsName.screenStopShare)
    }
    
    func logStopSpaceShare() {
        logEvent(AnalyticsEventsName.stopSpaceShare)
    }
    
    func logClickSettingsSpaceShare(type: ClickSettingsSpaceShareType) {
        logEvent(
            AnalyticsEventsName.clickSettingsSpaceShare,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logScreenRevokeShareLink() {
        logEvent(AnalyticsEventsName.screenRevokeShareLink)
    }
    
    func logRevokeShareLink() {
        logEvent(AnalyticsEventsName.revokeShareLink)
    }
    
    func logScreenInviteConfirm(route: ScreenInviteConfirmRoute) {
        logEvent(
            AnalyticsEventsName.screenInviteConfirm,
            withEventProperties: [AnalyticsEventsPropertiesKey.route: route.rawValue]
        )
    }
    
    func logApproveInviteRequest(type: PermissionAnalyticsType) {
        logEvent(
            AnalyticsEventsName.approveInviteRequest,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logRejectInviteRequest() {
        logEvent(AnalyticsEventsName.rejectInviteRequest)
    }
    
    func logChangeSpaceMemberPermissions(type: PermissionAnalyticsType) {
        logEvent(
            AnalyticsEventsName.changeSpaceMemberPermissions,
            withEventProperties: [AnalyticsEventsPropertiesKey.type: type.rawValue]
        )
    }
    
    func logRemoveSpaceMember() {
        logEvent(AnalyticsEventsName.removeSpaceMember)
    }
    
    func logScreenInviteRequest() {
        logEvent(AnalyticsEventsName.screenInviteRequest)
    }
    
    func logScreenRequestSent() {
        logEvent(AnalyticsEventsName.screenRequestSent)
    }
    
    func logScreenSettingsSpaceList() {
        logEvent(AnalyticsEventsName.screenSettingsSpaceList)
    }
    
    func logScreenLeaveSpace() {
        logEvent(AnalyticsEventsName.screenLeaveSpace)
    }
    
    func logLeaveSpace() {
        logEvent(AnalyticsEventsName.leaveSpace)
    }
    
    func logApproveLeaveRequest() {
        logEvent(AnalyticsEventsName.approveLeaveRequest)
    }
}
