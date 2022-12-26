import Foundation
import BlocksModels
import Combine

@MainActor
final class ObjectTreeWidgetViewModel: ObservableObject {
    
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private var subscriptions = [AnyCancellable]()
    
    @Published var name: String = ""
    @Published var isEexpanded: Bool = true
    
    init(widgetBlockId: BlockId, widgetObject: HomeWidgetsObjectProtocol, objectDetailsStorage: ObjectDetailsStorage) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    // MARK: - Private
    
    func onAppear() {
        // TODO: Think different after implement sets
        guard let info = widgetObject.blockInformation(id: widgetBlockId) else { return }
        guard let contentBlockId = info.childrenIds.first else { return }
        guard let contentInfo = widgetObject.blockInformation(id: contentBlockId) else { return }
        guard case let .link(link) = contentInfo.content else { return }
        
        setupSubscriptions(objectId: link.targetBlockID)
    }
    
    func onDisappear() {
        subscriptions.removeAll()
    }
    
    private func setupSubscriptions(objectId: BlockId) {
        objectDetailsStorage.publisherFor(id: objectId)
            .sink { [weak self] details in
                self?.name = details?.title ?? ""
            }
            .store(in: &subscriptions)
    }
}
