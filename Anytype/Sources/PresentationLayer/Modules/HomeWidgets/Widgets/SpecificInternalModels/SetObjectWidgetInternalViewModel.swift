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
    @Injected(\.setContentViewDataBuilder)
    private var setContentViewDataBuilder: any SetContentViewDataBuilderProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    // MARK: - State
    private var widgetInfo: BlockWidgetInfo?
    private var setDocument: (any SetDocumentProtocol)?
    private var activeViewId: String?
    private var canEditBlocks = true
    
    var dragId: String? { widgetBlockId }
    
    @Published var name: String = ""
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
    
    // MARK: - Subscriptions
    
    func startPermissionsPublisher() async {
        for await permissions in widgetObject.permissionsPublisher.values {
            canEditBlocks = permissions.canEditBlocks
        }
    }
    
    func startInfoPublisher() async {
        for await newWidgetInfo in widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId).values {
            widgetInfo = newWidgetInfo
            if activeViewId.isNil || canEditBlocks {
                activeViewId = widgetInfo?.block.viewID
                await updateBodyState()
            }
        }
    }
    
    func startTargetDetailsPublisher() async {
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            await updateSetDocument(objectId: details.id, spaceId: details.spaceId)
        }
    }
    
    func onAppear() async {
        guard let setDocument else { return }
        await updateSetDocument(objectId: setDocument.objectId, spaceId: setDocument.spaceId)
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
        let screenData: ScreenData
        if details.editorViewType == .type && FeatureFlags.simpleSetForTypes {
            screenData = .editor(.simpleSet(EditorSimpleSetObject(objectId: details.id, spaceId: details.spaceId)))
        } else {
            screenData = ScreenData(details: details, activeViewId: activeViewId)
        }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .object(type: setDocument?.details?.analyticsType ?? .object(typeId: "")))
        output?.onObjectSelected(screenData: screenData)
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
    
    private func sortedRowDetails(_ details: [ObjectDetails]?) -> [ObjectDetails]? {
        guard let objectOrderIds = setDocument?.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId),
                objectOrderIds.isNotEmpty else {
            return details
        }
        return details?.reorderedStable(by: objectOrderIds, transform: { $0.id })
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
        name = details.title
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
        let sortedDetails = sortedRowDetails(details) ?? details
        let rowDetails = setContentViewDataBuilder.itemData(
            sortedDetails,
            dataView: setDocument.dataView,
            activeView: setDocument.activeView,
            viewRelationValueIsLocked: false, 
            canEditIcon: setDocument.setPermissions.canEditSetObjectIcon,
            storage: subscriptionStorage.detailsStorage,
            spaceId: setDocument.spaceId,
            onItemTap: { [weak self] in
                self?.output?.onObjectSelected(screenData: $0.screenData())
            }
        )
        updateRows(rowDetails: rowDetails)
    }
}
