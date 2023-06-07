import Foundation
import Services
import Combine
import SwiftUI

fileprivate extension SubscriptionId {
    static func setWidgetId(_ widgetId: String) -> SubscriptionId {
        SubscriptionId(value: "SetWidget-\(widgetId)")
    }
}

@MainActor
final class SetListWidgetViewModel: ListWidgetViewModelProtocol, WidgetContainerContentViewModelProtocol, ObservableObject {
        
    private enum Constants {
        static let maxItems = 3
    }
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let documentService: DocumentServiceProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var contentSubscriptions = [AnyCancellable]()
    private var setDocument: SetDocumentProtocol?
    private var rowDetails: [ObjectDetails] = []
    private var activeViewId: String = ""
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    var dragId: String? { widgetBlockId }
    
    // MARK: - ListWidgetViewModelProtocol
    
    @Published private(set) var headerItems: [ListWidgetHeaderItem.Model] = []
    @Published private(set) var rows: [ListWidgetRow.Model]?
    let emptyTitle = Loc.Widgets.Empty.title
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        subscriptionService: SubscriptionsServiceProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol,
        documentService: DocumentServiceProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.subscriptionService = subscriptionService
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.documentService = documentService
        self.objectDetailsStorage = objectDetailsStorage
        self.output = output
        
        if let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId) {
            setDocument = documentService.setDocument(objectId: tagetObjectId, forPreview: true)
        }
    }
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    func startHeaderSubscription() {
        setupSubscriptions()
    }

    func stopHeaderSubscription() {
        subscriptions.removeAll()
    }
    
    func startContentSubscription() {
        setupContentSubscriptions()
    }
    
    func stopContentSubscription() {
        contentSubscriptions.removeAll()
    }
    
    func onHeaderTap() {
        guard let details = setDocument?.details else { return }
        AnytypeAnalytics.instance().logSelectHomeTab(source: .object(type: details.analyticsType))
        output?.onObjectSelected(screenData: EditorScreenData(pageId: details.id, type: details.editorViewType))
    }
    
    // MARK: - Private
    
    private func setupSubscriptions() {
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
    
    private func setupContentSubscriptions() {
        setDocument?.syncPublisher.sink { [weak self] in
            self?.updateActiveViewId()
            self?.updateHeader()
            self?.updateViewSubscription()
        }
        .store(in: &contentSubscriptions)
    }
    
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
            self?.rowDetails.applySubscriptionUpdate($1)
            self?.updateRows()
        }
    }
    
    private func updateHeader() {
        guard let blockDataView = setDocument?.dataView else { return }
        withAnimation {
            headerItems = blockDataView.views.map { dataView in
                ListWidgetHeaderItem.Model(
                    dataviewId: dataView.id,
                    title: dataView.name,
                    isSelected: dataView.id == activeViewId,
                    onTap: { [weak self] in
                        guard self?.activeViewId != dataView.id else { return }
                        UISelectionFeedbackGenerator().selectionChanged()
                        self?.activeViewId = dataView.id
                        self?.updateHeader()
                        self?.updateViewSubscription()
                    }
                )
            }
        }
    }
    
    private func updateRows() {
        withAnimation {
            rows = sortedRowDetails().map { details in
                ListWidgetRow.Model(
                    details: details,
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: $0)
                    }
                )
            }
        }
    }
    
    private func sortedRowDetails() -> [ObjectDetails] {
        guard let objectOrderIds = setDocument?.objectOrderIds(for: SubscriptionId.set.value),
                objectOrderIds.isNotEmpty else {
            return rowDetails
        }
        return rowDetails.reorderedStable(by: objectOrderIds, transform: { $0.id })
    }
}
