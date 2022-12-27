import Foundation
import BlocksModels
import Combine

@MainActor
final class ObjectTreeWidgetViewModel: ObservableObject {
    
    // TODO: For debug. Make private
    let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private var subscriptions = [AnyCancellable]()
    
    @Published var name: String = ""
    @Published var isExpanded: Bool = true
    @Published var rows: [ObjectTreeWidgetRowViewModel] = []
    
    init(widgetBlockId: BlockId, widgetObject: HomeWidgetsObjectProtocol, objectDetailsStorage: ObjectDetailsStorage) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    // MARK: - Private
    
    func onAppear() {
        guard let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId)
            else { return }
        setupSubscriptions(tagetObjectId: tagetObjectId)
    }
    
    func onDisappear() {
        subscriptions.removeAll()
    }
    
    private func setupSubscriptions(tagetObjectId: BlockId) {
        objectDetailsStorage.publisherFor(id: tagetObjectId)
            .sink { [weak self] details in
                self?.name = details?.title ?? ""
                print("Handle details widgetBlockId - \(self?.widgetBlockId)")
            }
            .store(in: &subscriptions)
        
        widgetObject.infoContainer.publisherFor(id: widgetBlockId)
            .sink { [weak self] info in
                guard case let .widget(widget) = info?.content else { return }
                self?.isExpanded = widget.layout == .tree
                print("Handle infoContainer widgetBlockId - \(self?.widgetBlockId)")
            }
            .store(in: &subscriptions)
        
        rows = (0..<5).map { id in
            ObjectTreeWidgetRowViewModel(
                id: "\(id)",
                title: "Item \(id)",
                expandedType: .dot,
                level: 0
            )
        }
    }
}
