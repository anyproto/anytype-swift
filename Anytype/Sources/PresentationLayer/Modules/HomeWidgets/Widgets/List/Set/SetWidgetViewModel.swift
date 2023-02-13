import Foundation
import BlocksModels
import Combine

fileprivate extension SubscriptionId {
    static func setWidgetId(_ widgetId: String) -> SubscriptionId {
        SubscriptionId(value: "SetWidget-\(widgetId)")
    }
}

@MainActor
final class SetWidgetViewModel: ListWidgetViewModelProtocol, WidgetContainerContentViewModelProtocol, ObservableObject {
        
    private enum Constants {
        static let maxItems = 3
    }
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let documentService: DocumentServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var contentSubscriptions = [AnyCancellable]()
    private var setDocument: SetDocumentProtocol?
    private var rowDetails: [ObjectDetails] = []
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    
    // MARK: - ListWidgetViewModelProtocol
    
    @Published private(set) var headerItems: [ListWidgetHeaderItem.Model] = []
    @Published private(set) var rows: [ListWidgetRow.Model] = []
    let minimimRowsCount = Constants.maxItems
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        subscriptionService: SubscriptionsServiceProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol,
        documentService: DocumentServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.subscriptionService = subscriptionService
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.documentService = documentService
        self.output = output
        
        if let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId) {
            setDocument = documentService.setDocument(objectId: tagetObjectId, forPreview: true)
        }
    }
    
    // MARK: - ListWidgetViewModelProtocol
    
    func onAppear() {
        setupSubscriptions()
    }

    func onDisappear() {
        subscriptions.removeAll()
    }
    
    func onAppearContent() {
        setupContentSubscriptions()
    }
    
    func onDisappearContent() {
        contentSubscriptions.removeAll()
    }
    
    func onHeaderTap() {
        guard let details = setDocument?.details else { return }
        output?.onObjectSelected(screenData: EditorScreenData(pageId: details.id, type: details.editorViewType))
    }
    
    // MARK: - Private
    
    private func setupSubscriptions() {
        setDocument?.document.syncPublisher.sink { [weak self] in
            self?.name = self?.setDocument?.details?.title ?? ""
        }
        .store(in: &subscriptions)
    }
    
    private func setupContentSubscriptions() {
        setDocument?.dataviewPublisher.sink { [weak self] in
            self?.updateViewState(blockDataView: $0)
        }
        .store(in: &contentSubscriptions)
        
        setDocument?.setUpdatePublisher.sink { [weak self] _ in
            self?.updateViewSubscription()
        }.store(in: &contentSubscriptions)
    }
    
    private func updateViewSubscription() {
        guard let setDocument else { return }
        
        guard let source = setDocument.details?.setOf, source.isNotEmpty else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubsriptionData(
                identifier: SubscriptionId.setWidgetId(widgetBlockId),
                source: source,
                view: setDocument.activeView,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: Constants.maxItems
            )
        )
        
        if subscriptionService.hasSubscriptionDataDiff(with: subscriptionData) {
            subscriptionService.stopAllSubscriptions()
            subscriptionService.startSubscription(data: subscriptionData) { [weak self] in
                self?.rowDetails.applySubscriptionUpdate($1)
                self?.updateRows()
            }
        }
    }
    
    private func updateViewState(blockDataView: BlockDataview) {
        
        headerItems = blockDataView.views.map { dataView in
            ListWidgetHeaderItem.Model(
                dataviewId: dataView.id,
                title: dataView.name,
                isSelected: dataView.id == blockDataView.activeViewId,
                onTap: { [weak self] in
                    self?.setDocument?.updateActiveViewId(dataView.id)
                }
            )
        }
    }
    
    private func updateRows() {
        rows = rowDetails.map { details in
            ListWidgetRow.Model(
                details: details,
                onTap: { [weak self] in
                    self?.output?.onObjectSelected(screenData: $0)
                }
            )
        }
    }
}
