import Foundation
import Services
import Combine
import UIKit

@MainActor
final class SetObjectWidgetLegacyInternalViewModel: ObservableObject, WidgetDataviewInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let subscriptionStorage: SubscriptionStorageProtocol
    private weak var output: CommonWidgetModuleOutput?
    private let subscriptionId = "SetWidget-\(UUID().uuidString)"
    
    @Injected(\.documentsProvider)
    private var documentService: DocumentsProviderProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    
    
    // MARK: - State
    private var widgetInfo: BlockWidgetInfo?
    private var setDocument: SetDocumentProtocol?
    private var activeViewId: String?
    private var subscriptions = [AnyCancellable]()
    private var contentSubscriptions = [AnyCancellable]()
    private var canEditBlocks = true
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
    
    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.output = data.output
        
        let storageProvider = Container.shared.subscriptionStorageProvider.resolve()
        self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: subscriptionId)
    }
    
    func startHeaderSubscription() {
        widgetObject.permissionsPublisher.receiveOnMain()
            .sink { [weak self] permissions in
                self?.canEditBlocks = permissions.canEditBlocks
            }
            .store(in: &subscriptions)
        
        widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] newWidgetInfo in
                guard let self else { return }
                widgetInfo = newWidgetInfo
                if activeViewId.isNil || canEditBlocks {
                    activeViewId = widgetInfo?.block.viewID
                    setActiveViewId()
                }
            }
            .store(in: &subscriptions)
        
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                Task {
                    await self?.updateSetDocument(objectId: details.id)
                }
            }
            .store(in: &subscriptions)
    }
    
    func startContentSubscription() async {
        setDocument?.syncPublisher.receiveOnMain().sink { [weak self] in
            self?.updateDataviewState()
            Task { await self?.updateViewSubscription() }
        }
        .store(in: &contentSubscriptions)
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
            if canEditBlocks {
                try? await blockWidgetService.setViewId(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId, viewId: viewId)
            } else {
                activeViewId = viewId
                setActiveViewId()
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onCreateObjectTap() {
        guard let setDocument else { return }
        output?.onCreateObjectInSetDocument(setDocument: setDocument)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    
    private func stopContentSubscription() async {
        contentSubscriptions.removeAll()
    }
        
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
            updateModelState()
            return
        }
        
        setDocument = documentService.setDocument(objectId: objectId, forPreview: true, inlineParameters: nil)
        try? await setDocument?.openForPreview()
        updateModelState()
        
        details = nil
        dataview = nil
        
        await stopContentSubscription()
        await startContentSubscription()
    }
    
    private func updateModelState() {
        setActiveViewId()
        
        guard let setDocument else { return }
        allowCreateObject = setDocument.setPermissions.canCreateObject
        
        guard let details = setDocument.details else { return }
        name = details.title
    }
    
    
    private func setActiveViewId() {
        guard let activeViewId, setDocument?.activeView.id != activeViewId else { return }
        setDocument?.updateActiveViewIdAndReload(activeViewId)
    }
}
