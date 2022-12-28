import Foundation
import BlocksModels
import Combine

@MainActor
final class ObjectTreeWidgetViewModel: ObservableObject {
    
    // TODO: For debug. Make private
    let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private let subscriptionManager: ObjectTreeSubscriptionManagerProtocol
    
    private var subscriptions = [AnyCancellable]()
    private var subscriptionData: [ObjectDetails] = []
    private var widgetBlockLinkedObjectId: String?
    private var widgetBlockObjectDetails: ObjectDetails?
    
    @Published var name: String = ""
    @Published var isExpanded: Bool = true
    @Published var rows: [ObjectTreeWidgetRowViewModel] = []
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        subscriptionManager: ObjectTreeSubscriptionManagerProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.subscriptionManager = subscriptionManager
    }
    
    // MARK: - Private
    
    func onAppear() {
        guard let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId)
            else { return }
        setupSubscriptions(tagetObjectId: tagetObjectId)
    }
    
    func onDisappear() {
        subscriptions.removeAll()
        subscriptionManager.stopAllSubscriptions()
    }
    
    private func setupSubscriptions(tagetObjectId: BlockId) {
        
        widgetBlockLinkedObjectId = tagetObjectId
        
        objectDetailsStorage.publisherFor(id: tagetObjectId)
            .compactMap { $0 }
            .receiveOnMain()
            .sink { [weak self] details in
                let oldLinks = self?.widgetBlockObjectDetails?.links
                self?.widgetBlockObjectDetails = details
                self?.name = details.title
                if oldLinks != details.links {
                    self?.updateSubscriptions(links: details.links)
                }
                print("Handle details widgetBlockId - \(self?.widgetBlockId)")
            }
            .store(in: &subscriptions)
        
//        objectDetailsStorage.publisherFor(id: tagetObjectId)
//            .compactMap { $0?.links }
//            .removeDuplicates()
//            .sink { [weak self] in self?.updateSubscriptions(links: $0) }
//            .store(in: &subscriptions)
        
        widgetObject.infoContainer.publisherFor(id: widgetBlockId)
            .sink { [weak self] info in
                guard case let .widget(widget) = info?.content else { return }
                self?.isExpanded = widget.layout == .tree
                print("Handle infoContainer widgetBlockId - \(self?.widgetBlockId)")
            }
            .store(in: &subscriptions)
        
        subscriptionManager.handler = { [weak self] details in
            self?.subscriptionData = details
//            self?.subscriptionData[objectId] = details
            self?.updateTree()
        }
        
//        if subscriptionData.isEmpty {
//            subscriptionManager.startSubscription(objectId: tagetObjectId)
//        } else {
//            subscriptionData.keys.forEach {
//                subscriptionManager.startSubscription(objectId: $0)
//            }
//        }
    }
    
    private func updateSubscriptions(links: [String]) {
        subscriptionManager.stopAllSubscriptions()
        subscriptionManager.startSubscription(objectIds: links)
    }
    
    private func updateTree() {
        guard let details = widgetBlockObjectDetails else { return }
        updateRows(links: details.links)
    }
    
    private func updateRows(links: [String]) {
        
        let rowsDetails = subscriptionData
            .filter { links.contains($0.id) }
            .reordered(by: links, transform: { $0.id })
        
        rows = rowsDetails.map { details in
            ObjectTreeWidgetRowViewModel(
                id: "\(details.id)",
                title: details.title,
                expandedType: .dot,
                level: 0
            )
        }
    }
}
