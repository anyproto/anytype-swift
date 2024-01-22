import Foundation
import Services
import Combine
import UIKit

@MainActor
final class SetObjectWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetDataviewInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let documentService: DocumentsProviderProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    private let subscriptionId = "SetWidget-\(UUID().uuidString)"
    
    // MARK: - State
    
    private var setDocument: SetDocumentProtocol?
    private var subscriptions = [AnyCancellable]()
    private var contentSubscriptions = [AnyCancellable]()
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
    var allowCreateObject = true
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol,
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        documentService: DocumentsProviderProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.documentService = documentService
        self.blockWidgetService = blockWidgetService
        self.output = output
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    override func startHeaderSubscription() {
        super.startHeaderSubscription()
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.allowCreateObject = details.canCreateObject
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
        guard setDocument?.activeView.id != viewId else { return }
        Task { @MainActor in
            try await blockWidgetService.setViewId(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId, viewId: viewId)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onCreateObjectTap() {
        guard let setDocument else { return }
        output?.onCreateObjectInSetDocument(setDocument: setDocument)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        super.widgetInfoUpdated()
        setActiveViewId()
    }
    
    // MARK: - Private
        
    private func updateViewSubscription() async {
        guard let setDocument, let widgetInfo else {
            try? await subscriptionStorage.stopSubscription()
            return
        }
        
        guard setDocument.canStartSubscription() else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubscriptionData(
                identifier: subscriptionId,
                source: setDocument.details?.setOf,
                view: setDocument.activeView,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: widgetInfo.fixedLimit,
                collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
                objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId)
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { [weak self] data in
            guard let self else { return }
            details = data.items
        }
    }
    
    private func updateDataviewState() {
        guard let setDocument, setDocument.dataView.views.count > 1 else {
            dataview = nil
            return
        }
        dataview = WidgetDataviewState(
            dataview: setDocument.dataView.views,
            activeViewId: setDocument.activeView.id
        )
    }
    
    private func sortedRowDetails(_ details: [ObjectDetails]?) -> [ObjectDetails]? {
        guard let objectOrderIds = setDocument?.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId),
                objectOrderIds.isNotEmpty else {
            return details
        }
        return details?.reorderedStable(by: objectOrderIds, transform: { $0.id })
    }
    
    private func updateSetDocument(objectId: String) async {
        guard objectId != setDocument?.objectId else {
            try? await setDocument?.openForPreview()
            setActiveViewId()
            return
        }
        
        setDocument = documentService.setDocument(objectId: objectId, forPreview: true, inlineParameters: nil)
        try? await setDocument?.openForPreview()
        setActiveViewId()
        
        details = nil
        dataview = nil
        
        guard contentIsAppear else { return }
        
        await stopContentSubscription()
        await startContentSubscription()
    }
    
    
    private func setActiveViewId() {
        guard let widgetInfo, setDocument?.activeView.id != widgetInfo.block.viewId else { return }
        setDocument?.updateActiveViewId(widgetInfo.block.viewId)
    }
}
