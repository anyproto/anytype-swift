import Foundation
import Services
import Combine
import UIKit
import SwiftUI
import AnytypeCore

@MainActor
@Observable
final class SetObjectWidgetInternalViewModel {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let style: SetObjecWidgetStyle
    private let widgetObject: any BaseDocumentProtocol
    @Injected(\.setSubscriptionDataBuilder) @ObservationIgnored
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    private let subscriptionStorage: any SubscriptionStorageProtocol
    @ObservationIgnored
    private weak var output: (any CommonWidgetModuleOutput)?
    private let subscriptionId: String

    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.setObjectWidgetOrderHelper) @ObservationIgnored
    private var setObjectWidgetOrderHelper: any SetObjectWidgetOrderHelperProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @Injected(\.chatMessagesPreviewsStorage) @ObservationIgnored
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.objectsWithUnreadDiscussionsSubscription) @ObservationIgnored
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol
    @Injected(\.widgetRowModelBuilder) @ObservationIgnored
    private var widgetRowModelBuilder: any WidgetRowModelBuilderProtocol

    // MARK: - State
    @ObservationIgnored
    private var widgetInfo: BlockWidgetInfo?
    @ObservationIgnored
    private var setDocument: (any SetDocumentProtocol)?
    @ObservationIgnored
    private var activeViewId: String?
    @ObservationIgnored
    private var canEditBlocks = true
    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []
    @ObservationIgnored
    private var unreadDiscussionsBySpace: [String: SpaceDiscussionsUnreadInfo] = [:]
    @ObservationIgnored
    private var dataviewUpdateTask: Task<Void, Never>?
    /// Skip the very first `setDocument.update()` after a fresh open: that emission
    /// is the publisher's initial replay, not a real change event. Subsequent emissions
    /// are remote edits — `.preview` mode docs need explicit `update()` to refresh.
    @ObservationIgnored
    private var setDocumentJustOpened = false

    var dragId: String? { widgetBlockId }
    
    var name: String = ""
    var icon: Icon?
    var headerItems: [ViewWidgetTabsItemModel]?
    var rows: SetObjectViewWidgetRows = .list(rows: nil, id: "")
    var allowCreateObject = true
    var showUnsupportedBanner = false
    var availableMoreObjects = false
    
    init(data: WidgetSubmoduleData, style: SetObjecWidgetStyle) {
        self.widgetBlockId = data.widgetBlockId
        self.style = style
        self.widgetObject = data.channelWidgetsObject
        self.output = data.output

        if let prefetched = data.prefetchedSetSubscription {
            // Reuse the loader's storage so the VM's later `startOrUpdateSubscription`
            // with matching data short-circuits — no duplicate ObjectSearchSubscribe.
            self.subscriptionStorage = prefetched.subscriptionStorage
            self.subscriptionId = prefetched.subscriptionStorage.subId
            self.setDocument = prefetched.setDocument
            self.activeViewId = prefetched.setDocument.activeView.id
            self.setDocumentJustOpened = true
        } else {
            let id = "SetWidget-\(UUID().uuidString)"
            self.subscriptionId = id
            let storageProvider = Container.shared.subscriptionStorageProvider.resolve()
            self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: id)
        }

        // Avoid a frame of empty row before `targetDetailsPublisher` first ticks.
        if let details = data.prefetchedDetails {
            self.name = details.pluralTitle
            self.icon = details.objectIconImage
        }

        if let prefetched = data.prefetchedSetSubscription {
            updateRowDetails(data: prefetched.state)
        }
    }
    
    func startSubscriptions() async {
        async let permissionsTask: () = startPermissionsPublisher()
        async let startInfoTask: () = startInfoPublisher()
        async let targetDetailsTask: () = startTargetDetailsPublisher()
        async let chatPreviewsTask: () = startChatPreviewsSequence()
        async let unreadDiscussionsTask: () = startUnreadDiscussionsSequence()

        _ = await (permissionsTask, startInfoTask, targetDetailsTask, chatPreviewsTask, unreadDiscussionsTask)
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
        defer { dataviewUpdateTask?.cancel() }
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            await updateSetDocument(objectId: details.id, spaceId: details.spaceId)
        }
    }

    private func startChatPreviewsSequence() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            await updateBodyState()
        }
    }

    private func startUnreadDiscussionsSequence() async {
        for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
            unreadDiscussionsBySpace = unreadBySpace
            await updateBodyState()
        }
    }
    
    // MARK: - Private for view updates
    
    private func updateRows(rowDetails: [SetContentViewItemConfiguration]?) {
        let newShowUnsupportedBanner = (style == .view) && !(setDocument?.activeView.type.isSupportedOnDevice ?? false)
        if showUnsupportedBanner != newShowUnsupportedBanner {
            showUnsupportedBanner = newShowUnsupportedBanner
        }

        let newRows: SetObjectViewWidgetRows
        switch style {
        case .list:
            let listRows = buildListRows(from: rowDetails)
            newRows = .list(rows: listRows, id: activeViewId ?? "")
        case .compactList:
            let listRows = buildListRows(from: rowDetails)
            newRows = .compactList(rows: listRows, id: activeViewId ?? "")
        case .view:
            if isSetByImageType() {
                let galleryRows = rowDetails.map { widgetRowModelBuilder.buildGalleryRows(from: $0) }
                newRows = .gallery(rows: galleryRows, id: activeViewId ?? "")
            } else {
                switch setDocument?.activeView.type {
                case .table, .list, .kanban, .calendar, .graph, nil:
                    let listRows = buildListRows(from: rowDetails)
                    newRows = .compactList(rows: listRows, id: activeViewId ?? "")
                case .gallery:
                    let galleryRows = rowDetails.map { widgetRowModelBuilder.buildGalleryRows(from: $0) }
                    newRows = .gallery(rows: galleryRows, id: activeViewId ?? "")
                }
            }
        }

        guard newRows != rows else { return }
        rows = newRows
    }

    private func buildListRows(from configs: [SetContentViewItemConfiguration]?) -> [ListWidgetRowModel]? {
        guard let configs, let setDocument else { return nil }
        let spaceView = spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)

        return widgetRowModelBuilder.buildListRows(
            from: configs,
            spaceView: spaceView,
            chatPreviews: chatPreviews,
            unreadParents: unreadDiscussionsBySpace[setDocument.spaceId]?.parents ?? []
        )
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
        let newHeaderItems = dataviewState?.dataview.map { dataView in
            ViewWidgetTabsItemModel(
                dataviewId: dataView.id,
                title: dataView.nameWithPlaceholder,
                isSelected: dataView.id == dataviewState?.activeViewId,
                onTap: { [weak self] in
                    self?.onActiveViewTap(dataView.id)
                }
            )
        }
        if headerItems != newHeaderItems {
            headerItems = newHeaderItems
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

        // Wait for dataView blocks to sync; otherwise view.sorts is empty and
        // SetSubscriptionData falls back to createdDate.
        guard setDocument.dataView.views.isNotEmpty else { return }

        let subscriptionData = setSubscriptionDataBuilder.widgetSubscriptionData(
            widgetInfo: widgetInfo,
            setDocument: setDocument,
            identifier: subscriptionId,
            spaceType: spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)?.spaceType
        )

        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { [weak self] data in
            await self?.updateRowDetails(data: data)
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
            if setDocumentJustOpened {
                setDocumentJustOpened = false
            } else {
                try? await setDocument?.update()
            }
            await updateModelState()
            return
        }

        dataviewUpdateTask?.cancel()

        let newSetDocument = documentsProvider.setDocument(objectId: objectId, spaceId: spaceId, mode: .preview)
        setDocument = newSetDocument
        try? await newSetDocument.open()
        setDocumentJustOpened = true

        // dataView blocks and permissions sync after open(); re-pull on emit.
        dataviewUpdateTask = Task { [weak self] in
            for await update in newSetDocument.setUpdatePublisher.values {
                guard case .dataviewUpdated = update else { continue }
                guard let self else { continue }
                await updateBodyState()
                let nextAllowCreate = newSetDocument.setPermissions.canCreateObject
                if allowCreateObject != nextAllowCreate {
                    allowCreateObject = nextAllowCreate
                }
            }
        }

        updateRows(rowDetails: nil)
        updateHeader(dataviewState: nil)

        await updateModelState()
    }
    
    private func updateModelState() async {
        await updateBodyState()
        // setPermissions is assigned async by SetDocument.updateData(); read it in dataviewUpdateTask.
        guard let setDocument, let details = setDocument.details else { return }
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
    
    private func updateRowDetails(data: SubscriptionStorageState) {
        guard let setDocument else { return }

        let newAvailableMoreObjects = data.total > data.items.count
        if availableMoreObjects != newAvailableMoreObjects {
            availableMoreObjects = newAvailableMoreObjects
        }

        let spaceView = spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)
        let rowDetails = setObjectWidgetOrderHelper.reorder(
            setDocument: setDocument,
            subscriptionStorage: subscriptionStorage,
            details: data.items,
            chatPreviews: chatPreviews,
            spaceView: spaceView,
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
        if isAllMediaFiles {
            output?.onObjectSelected(screenData: .preview(
                MediaFileScreenData(selectedItem: details, allItems: allDetails, route: .widget)
            ))
        } else {
            output?.onObjectSelected(screenData: details.screenData())
        }
    }
}
