import Foundation
import BlocksModels
import Combine

@MainActor
final class SetWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private let blockWidgetService: BlockWidgetServiceProtocol
    private weak var output: SetWidgetModuleOutput?
    
    // MARK: - State
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    
    @Published var name: String = ""
    @Published var isExpanded: Bool = true
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        blockWidgetService: BlockWidgetServiceProtocol,
        output: SetWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.blockWidgetService = blockWidgetService
        self.output = output
    }
    
    // MARK: - Public
    
    func onAppear() {
        setupAllSubscriptions()
    }

    func onDisappear() {
        subscriptions.removeAll()
    }
    
    func onDeleteWidgetTap() {
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetBlockId
            )
        }
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
        
        widgetObject.infoContainer.publisherFor(id: widgetBlockId)
            .sink { [weak self] info in
                guard case let .widget(widget) = info?.content else { return }
                self?.isExpanded = widget.layout == .tree
            }
            .store(in: &subscriptions)
    }
}
