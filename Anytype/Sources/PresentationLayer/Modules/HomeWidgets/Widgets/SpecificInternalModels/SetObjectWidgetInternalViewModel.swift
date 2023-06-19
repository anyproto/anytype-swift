import Foundation
import Services
import Combine
import UIKit

fileprivate extension SubscriptionId {
    static func setWidgetId(_ widgetId: String) -> SubscriptionId {
        SubscriptionId(value: "SetWidget-\(widgetId)")
    }
}

final class SetObjectWidgetInternalViewModel: WidgetDataviewInternalViewModelProtocol {
    
    private enum Constants {
        static let maxItems = 3
    }
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    
    // MARK: - State
    
    private var setDocument: SetDocumentProtocol?
    private var subscriptions = [AnyCancellable]()
    private var contentSubscriptions = [AnyCancellable]()
    private var activeViewId: String = ""
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
        objectDetailsStorage: ObjectDetailsStorage,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol,
        subscriptionService: SubscriptionsServiceProtocol,
        documentService: DocumentServiceProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.subscriptionService = subscriptionService
        
        if let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId) {
            setDocument = documentService.setDocument(objectId: tagetObjectId, forPreview: true)
        }
    }
    
    func startHeaderSubscription() {
        guard let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId)
            else { return }
        
        objectDetailsStorage.publisherFor(id: tagetObjectId)
            .compactMap { $0 }
            .receiveOnMain()
            .sink { [weak self] details in
                self?.name = self?.setDocument?.details?.title ?? ""
            }
            .store(in: &subscriptions)
    }
    
    func stopHeaderSubscription() {
        subscriptions.removeAll()
    }
    
    func startContentSubscription() {
        setDocument?.syncPublisher.sink { [weak self] in
            self?.updateActiveViewId()
            self?.updateDataviewState()
            self?.updateViewSubscription()
        }
        .store(in: &contentSubscriptions)
    }
    
    func stopContentSubscription() {
        contentSubscriptions.removeAll()
    }
    
    func screenData() -> EditorScreenData? {
        guard let details = setDocument?.details else { return nil }
        return EditorScreenData(pageId: details.id, type: details.editorViewType)
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
    
    // MARK: - Private
    
    private func updateActiveViewId() {
        guard activeViewId.isEmpty else { return }
        activeViewId = setDocument?.dataView.activeViewId ?? ""
    }
        
    private func updateViewSubscription() {
        guard let setDocument else { return }
        
        guard setDocument.canStartSubscription(),
              let activeView = setDocument.dataView.views.first(where: { $0.id == activeViewId }) else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubsriptionData(
                identifier: SubscriptionId.setWidgetId(widgetBlockId),
                source: setDocument.details?.setOf,
                view: activeView,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: Constants.maxItems,
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
        guard let setDocument else { return }
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
}
