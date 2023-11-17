import Foundation
import Services
import Combine
import UIKit

@MainActor
final class SetObjectWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetDataviewInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let documentService: OpenedDocumentsProviderProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let subscriptionId = "SetWidget-\(UUID().uuidString)"
    
    // MARK: - State
    
    private var setDocument: SetDocumentProtocol?
    private var subscriptions = [AnyCancellable]()
    private var contentSubscriptions = [AnyCancellable]()
    private var activeViewId: String?
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = ""
    @Published var dataview: WidgetDataviewState?

    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> {
        $details
            .map { [weak self] in self?.sortedRowDetails($0) }
            .eraseToAnyPublisher()
    }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var dataviewPublisher: AnyPublisher<WidgetDataviewState?, Never> { $dataview.eraseToAnyPublisher() }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol,
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        documentService: OpenedDocumentsProviderProtocol,
        blockWidgetService: BlockWidgetServiceProtocol
    ) {
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.documentService = documentService
        self.blockWidgetService = blockWidgetService
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    override func startHeaderSubscription() {
        super.startHeaderSubscription()
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.name = details.title
                Task { await self?.updateSetDocument(objectId: details.id) }
            }
            .store(in: &subscriptions)
    }
    
    override func stopHeaderSubscription() {
        super.stopHeaderSubscription()
        subscriptions.removeAll()
    }
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        setDocument?.syncPublisher.sink { [weak self] in
            self?.updateActiveViewId()
            self?.updateDataviewState()
            Task { await self?.updateViewSubscription() }
        }
        .store(in: &contentSubscriptions)
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        contentSubscriptions.removeAll()
    }
    
    func screenData() -> EditorScreenData? {
        guard let details = setDocument?.details else { return nil }
        return details.editorScreenData()
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .object(type: setDocument?.details?.analyticsType ?? .object(typeId: ""))
    }
    
    func onActiveViewTap(_ viewId: String) {
        guard activeViewId != viewId else { return }
        Task { @MainActor in
            try await blockWidgetService.setViewId(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId, viewId: viewId)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        super.widgetInfoUpdated()
        updateActiveViewId()
        updateDataviewState()
        Task { await updateViewSubscription() }
    }
    
    // MARK: - Private
    
    private func updateActiveViewId() {
        guard let setDocument else {
            activeViewId = nil
            return
        }
        
        activeViewId = widgetInfo?.block.viewId
        
        let containsViewId = setDocument.dataView.views.contains { $0.id == activeViewId }
        guard !containsViewId else { return }
        
        activeViewId = setDocument.dataView.activeViewId
    }
        
    private func updateViewSubscription() async {
        guard let setDocument, let widgetInfo else {
            try? await subscriptionStorage.stopSubscription()
            return
        }
        
        guard setDocument.canStartSubscription(),
              let activeView = setDocument.dataView.views.first(where: { $0.id == activeViewId }) else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubscriptionData(
                identifier: subscriptionId,
                source: setDocument.details?.setOf,
                view: activeView,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: widgetInfo.fixedLimit,
                collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
                objectOrderIds: setDocument.objectOrderIds(for: SetSubscriptionData.setId)
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { [weak self] data in
            guard let self else { return }
            details = data.items
        }
    }
    
    private func updateDataviewState() {
        guard let setDocument, let activeViewId else {
            dataview = nil
            return
        }
        dataview = WidgetDataviewState(
            dataview: setDocument.dataView.views,
            activeViewId: activeViewId
        )
    }
    
    private func sortedRowDetails(_ details: [ObjectDetails]?) -> [ObjectDetails]? {
        guard let objectOrderIds = setDocument?.objectOrderIds(for: SetSubscriptionData.setId),
                objectOrderIds.isNotEmpty else {
            return details
        }
        return details?.reorderedStable(by: objectOrderIds, transform: { $0.id })
    }
    
    private func updateSetDocument(objectId: String) async {
        guard objectId != setDocument?.objectId else {
            Task { @MainActor in
                try await setDocument?.openForPreview()
            }
            return
        }
        
        setDocument = documentService.setDocument(objectId: objectId, forPreview: true)
        
        details = nil
        dataview = nil
        
        guard contentIsAppear else { return }
        
        await stopContentSubscription()
        await startContentSubscription()
    }
}
