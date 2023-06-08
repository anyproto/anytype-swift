import Foundation
import Combine
import BlocksModels

@MainActor
final class LinkWidgetViewModel: ObservableObject, WidgetContainerContentViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    
    @Published private(set) var name = ""
    let allowContent = false
    var dragId: String? { widgetBlockId }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.output = output
    }
    
    // MARK: - WidgetContainerContentViewModelProtocol

    func startHeaderSubscription() {
        setupAllSubscriptions()
    }
    
    func stopHeaderSubscription() {
        subscriptions.removeAll()
    }
    
    func startContentSubscription() {}
    
    func stopContentSubscription() {}
    
    func onHeaderTap() {
        guard let linkedObjectDetails else { return }
        AnytypeAnalytics.instance().logSelectHomeTab(source: .object(type: linkedObjectDetails.analyticsType))
        output?.onObjectSelected(screenData: EditorScreenData(pageId: linkedObjectDetails.id, type: linkedObjectDetails.editorViewType))
    }
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        
        guard let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId)
            else { return }
        
        objectDetailsStorage.publisherFor(id: tagetObjectId)
            .compactMap { $0 }
            .receiveOnMain()
            .sink { [weak self] details in
                self?.linkedObjectDetails = details
                self?.name = details.title
            }
            .store(in: &subscriptions)
    }
}
