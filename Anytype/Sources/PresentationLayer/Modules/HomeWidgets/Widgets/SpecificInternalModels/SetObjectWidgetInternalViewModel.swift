import Foundation
import Services
import Combine
import UIKit

final class SetObjectWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetDataviewInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    private let documentService: DocumentServiceProtocol
    
    private let subscriptionId = SubscriptionId(value: "SetWidget-\(UUID().uuidString)")
    
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
        subscriptionService: SubscriptionsServiceProtocol,
        documentService: DocumentServiceProtocol
    ) {
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.subscriptionService = subscriptionService
        self.documentService = documentService
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    override func startHeaderSubscription() {
        super.startHeaderSubscription()
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.name = details.title
                self?.updateSetDocument(objectId: details.id)
            }
            .store(in: &subscriptions)
    }
    
    override func stopHeaderSubscription() {
        super.stopHeaderSubscription()
        subscriptions.removeAll()
    }
    
    override func startContentSubscription() {
        super.startContentSubscription()
        setDocument?.syncPublisher.sink { [weak self] in
            self?.updateActiveViewId()
            self?.updateDataviewState()
            self?.updateViewSubscription()
        }
        .store(in: &contentSubscriptions)
    }
    
    override func stopContentSubscription() {
        super.stopContentSubscription()
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
        UISelectionFeedbackGenerator().selectionChanged()
        activeViewId = viewId
        updateDataviewState()
        updateViewSubscription()
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        updateViewSubscription()
    }
    
    // MARK: - Private
    
    private func updateActiveViewId() {
        guard let setDocument else {
            activeViewId = nil
            return
        }
        
        let containsViewId = setDocument.dataView.views.contains { $0.id == activeViewId }
        guard !containsViewId else { return }
        
        activeViewId = setDocument.dataView.activeViewId
    }
        
    private func updateViewSubscription() {
        guard let setDocument, let widgetInfo else {
            subscriptionService.stopAllSubscriptions()
            return
        }
        
        guard setDocument.canStartSubscription(),
              let activeView = setDocument.dataView.views.first(where: { $0.id == activeViewId }) else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubsriptionData(
                identifier: subscriptionId,
                source: setDocument.details?.setOf,
                view: activeView,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: widgetInfo.fixedLimit,
                collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
                objectOrderIds: setDocument.objectOrderIds(for: SubscriptionId.set.value)
            )
        )
        
        subscriptionService.updateSubscription(data: subscriptionData, required: false) { [weak self] in
            var details = self?.details ?? []
            details.applySubscriptionUpdate($1)
            self?.details = details
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
        guard let objectOrderIds = setDocument?.objectOrderIds(for: SubscriptionId.set.value),
                objectOrderIds.isNotEmpty else {
            return details
        }
        return details?.reorderedStable(by: objectOrderIds, transform: { $0.id })
    }
    
    private func updateSetDocument(objectId: String) {
        guard objectId != setDocument?.objectId else { return }
        
        setDocument = documentService.setDocument(objectId: objectId, forPreview: true)
        
        details = nil
        dataview = nil
        
        guard contentIsAppear else { return }
        
        stopContentSubscription()
        startContentSubscription()
    }
}
