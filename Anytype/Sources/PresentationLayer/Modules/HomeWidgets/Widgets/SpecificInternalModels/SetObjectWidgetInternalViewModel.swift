import Foundation
import Services
import Combine
import UIKit
import SwiftUI
import AnytypeCore

@MainActor
final class SetObjectWidgetInternalViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let style: SetObjecWidgetStyle
    private let widgetObject: any BaseDocumentProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    private let subscriptionStorage: any SubscriptionStorageProtocol
    private weak var output: (any CommonWidgetModuleOutput)?
    private let subscriptionId = "SetWidget-\(UUID().uuidString)"
    
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.setObjectWidgetOrderHelper)
    private var setObjectWidgetOrderHelper: any SetObjectWidgetOrderHelperProtocol
    
    // MARK: - State
    private var widgetInfo: BlockWidgetInfo?
    private var setDocument: (any SetDocumentProtocol)?
    private var activeViewId: String?
    private var canEditBlocks = true
    
    var dragId: String? { widgetBlockId }
    
    @Published var name: String = ""
    @Published var icon: Icon?
    @Published var headerItems: [ViewWidgetTabsItemModel]?
    @Published var rows: SetObjectViewWidgetRows = .list(rows: nil, id: "")
    @Published var allowCreateObject = true
    @Published var showUnsupportedBanner = false
    
    init(data: WidgetSubmoduleData, style: SetObjecWidgetStyle) {
        self.widgetBlockId = data.widgetBlockId
        self.style = style
        self.widgetObject = data.widgetObject
        self.output = data.output
        
        let storageProvider = Container.shared.subscriptionStorageProvider.resolve()
        self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: subscriptionId)
    }
    
    func startSubscriptions() async {
        async let permissionsTask: () = startPermissionsPublisher()
        async let startInfoTask: () = startInfoPublisher()
        async let targetDetailsTask: () = startTargetDetailsPublisher()
        
        _ = await (permissionsTask, startInfoTask, targetDetailsTask)
    }
    
    // MARK: - Actions
    
    func onActiveViewTap(_ viewId: String) {
        guard setDocument?.activeView.id != viewId else { return }
        Task { @MainActor in
            if canEditBlocks {
                try? await blockWidgetService.setViewId(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId, viewId: viewId)
            } else {
                activeViewId = viewId
                await updateBodyState()
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onCreateObjectTap() {
        guard let setDocument else { return }
        output?.onCreateObjectInSetDocument(setDocument: setDocument)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onOpenObjectTap() {
        guard let details = setDocument?.details else { return }
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        let screenData = ScreenData(details: details, activeViewId: activeViewId)
        AnytypeAnalytics.instance().logClickWidgetTitle(
            source: .object(type: setDocument?.details?.analyticsType ?? .object(typeId: "")),
            createType: info.widgetCreateType
        )
        output?.onObjectSelected(screenData: screenData)
    }

    // MARK: - Subscriptions
    
    private func startPermissionsPublisher() async {
        for await permissions in widgetObject.permissionsPublisher.values {
            canEditBlocks = permissions.canEditBlocks
        }
    }
    
    private func startInfoPublisher() async {
        for await newWidgetInfo in widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId).values {
            widgetInfo = newWidgetInfo
            if activeViewId.isNil || canEditBlocks {
                activeViewId = widgetInfo?.block.viewID
                await updateBodyState()
            }
        }
    }
    
    private func startTargetDetailsPublisher() async {
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            await updateSetDocument(objectId: details.id, spaceId: details.spaceId)
        }
    }
    
    // MARK: - Private for view updates
    
    private func updateRows(rowDetails: [SetContentViewItemConfiguration]?) {
        withAnimation(rows.rowsIsNil ? nil : .default) {
            showUnsupportedBanner = (style == .view) && !(setDocument?.activeView.type.isSupportedOnDevice ?? false)
         
            switch style {
            case .list:
                let listRows = rowDetails?.map { ListWidgetRowModel(details: $0) }
                rows = .list(rows: listRows, id: activeViewId ?? "")
            case .compactList:
                let listRows = rowDetails?.map { ListWidgetRowModel(details: $0) }
                rows = .compactList(rows: listRows, id: activeViewId ?? "")
            case .view:
                if isSetByImageType() {
                    // Delete with FeatureFlags.homeObjectTypeWidgets
                    let galleryRows = rowDetails?.map { details in
                        GalleryWidgetRowModel(
                            objectId: details.id,
                            title: nil,
                            icon: nil,
                            cover: .cover(.imageId(details.id)),
                            onTap: details.onItemTap
                        )
                    }
                    rows = .gallery(rows: galleryRows, id: activeViewId ?? "")
                } else {
                    switch setDocument?.activeView.type {
                    case .table, .list, .kanban, .calendar, .graph, nil:
                        let listRows = rowDetails?.map { ListWidgetRowModel(details: $0) }
                        rows = .compactList(rows: listRows, id: activeViewId ?? "")
                    case .gallery:
                        let galleryRows = rowDetails?.map { GalleryWidgetRowModel(details: $0) }
                        rows = .gallery(rows: galleryRows, id: activeViewId ?? "")
                    }
                }
            }
        }
    }
    
    private func isSetByImageType() -> Bool {
        guard let details = setDocument?.details,
              let setOf = details.setOf.first,
              let objectType = try? objectTypeProvider.objectType(id: setOf) else {
            return false
        }
        return details.editorViewType == .type && objectType.isImageLayout
    }
    
    private func updateHeader(dataviewState: WidgetDataviewState?) {
        withAnimation(headerItems.isNil ? nil : .default) {
            headerItems = dataviewState?.dataview.map { dataView in
                ViewWidgetTabsItemModel(
                    dataviewId: dataView.id,
                    title: dataView.nameWithPlaceholder,
                    isSelected: dataView.id == dataviewState?.activeViewId,
                    onTap: { [weak self] in
                        self?.onActiveViewTap(dataView.id)
                    }
                )
            }
        }
    }
    
    private func updateDone(details: ObjectDetails) {
        guard details.resolvedLayoutValue == .todo else { return }
        
        Task {
            try await objectActionsService.updateBundledDetails(contextID: details.id, details: [.done(!details.done)])
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
    
    // MARK: - Private for set logic
        
    private func updateViewSubscription() async {
        guard let setDocument, let widgetInfo else {
            try? await subscriptionStorage.stopSubscription()
            return
        }
        
        guard setDocument.canStartSubscription() else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubscriptionData(
                identifier: subscriptionId,
                document: setDocument,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: widgetInfo.fixedLimit,
                collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
                objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId)
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { [weak self] data in
            await self?.updateRowDetails(details: data.items)
        }
    }
    
    private func updateDataviewState() {
        guard let setDocument, setDocument.dataView.views.count > 1 else {
            updateHeader(dataviewState: nil)
            return
        }
        let dataviewState = WidgetDataviewState(
            dataview: setDocument.dataView.views,
            activeViewId: setDocument.activeView.id
        )
        updateHeader(dataviewState: dataviewState)
    }
    
    private func updateSetDocument(objectId: String, spaceId: String) async {
        guard objectId != setDocument?.objectId, spaceId != setDocument?.spaceId else {
            try? await setDocument?.update()
            await updateModelState()
            return
        }
        
        setDocument = documentsProvider.setDocument(objectId: objectId, spaceId: spaceId, mode: .preview)
        try? await setDocument?.open()
        
        updateRows(rowDetails: nil)
        updateHeader(dataviewState: nil)
        
        await updateModelState()
    }
    
    private func updateModelState() async {
        await updateBodyState()
    
        guard let setDocument else { return }
        allowCreateObject = setDocument.setPermissions.canCreateObject
        
        guard let details = setDocument.details else { return }
        name = details.pluralTitle
        icon = details.objectIconImage
    }
    
    
    private func updateBodyState() async {
        if let activeViewId, let setDocument, setDocument.activeView.id != activeViewId, setDocument.document.isOpened {
            setDocument.updateActiveViewIdAndReload(activeViewId)
        }
        
        updateDataviewState()
        await updateViewSubscription()
    }
    
    private func updateRowDetails(details: [ObjectDetails]) {
        guard let setDocument else { return }
        let rowDetails = setObjectWidgetOrderHelper.reorder(
            setDocument: setDocument,
            subscriptionStorage: subscriptionStorage,
            details: details,
            onItemTap: { [weak self] details, sortedDetails in
                self?.handleTapOnObject(details: details, allDetails: sortedDetails)
            }
        )
        updateRows(rowDetails: rowDetails)
    }
    
    private func handleTapOnObject(details: ObjectDetails, allDetails: [ObjectDetails]) {
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        AnytypeAnalytics.instance().logOpenSidebarObject(createType: info.widgetCreateType)
        let isAllMediaFiles = allDetails.allSatisfy { $0.editorViewType.isMediaFile }
        if FeatureFlags.mediaCarouselForWidgets, isAllMediaFiles {
            output?.onObjectSelected(screenData: .preview(
                MediaFileScreenData(selectedItem: details, allItems: allDetails, route: .widget)
            ))
        } else {
            output?.onObjectSelected(screenData: details.screenData())
        }
    }
}
