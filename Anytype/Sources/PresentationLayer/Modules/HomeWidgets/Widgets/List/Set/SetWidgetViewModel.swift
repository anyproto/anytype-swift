import Foundation
import BlocksModels
import Combine

@MainActor
final class SetWidgetViewModel: ListWidgetViewModelProtocol, WidgetContainerContentViewModelProtocol, ObservableObject {
        
    private enum Constants {
        static let maxItems = 3
    }
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    
    // MARK: - ListWidgetViewModelProtocol
    
    @Published private(set) var headerItems: [ListWidgetHeaderItem.Model] = []
    @Published private(set) var rows: [ListWidgetRow.Model] = []
    let minimimRowsCount = Constants.maxItems
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.output = output
    }
    
    // MARK: - ListWidgetViewModelProtocol
    
    func onAppear() {
        setupAllSubscriptions()
    }

    func onDisappear() {
        subscriptions.removeAll()
    }
    
    func onHeaderTap() {
        guard let linkedObjectDetails else { return }
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
                self?.updateViewState()
            }
            .store(in: &subscriptions)
    }
    
    private func updateViewState() {
        headerItems = [
            ListWidgetHeaderItem.Model(dataviewId: "1", title: "Last Edited", onTap: {}, isSelected: false),
            ListWidgetHeaderItem.Model(dataviewId: "2", title: "New movies", onTap: {}, isSelected: true),
            ListWidgetHeaderItem.Model(dataviewId: "3", title: "To watch", onTap: {}, isSelected: false),
            ListWidgetHeaderItem.Model(dataviewId: "4", title: "To watch", onTap: {}, isSelected: false),
            ListWidgetHeaderItem.Model(dataviewId: "5", title: "My Collection", onTap: {}, isSelected: false),
            ListWidgetHeaderItem.Model(dataviewId: "6", title: "My Collection 2", onTap: {}, isSelected: false),
            ListWidgetHeaderItem.Model(dataviewId: "7", title: "My Collection 3", onTap: {}, isSelected: false)
        ]
        
        rows = [
            ListWidgetRow.Model(objectId: "1", icon: .placeholder("A"), title: "Object title", description: "Object description description description description description description ", type: nil, onTap: {}),
            ListWidgetRow.Model(objectId: "2", icon: .placeholder("A"), title: "Object title title title title title title title title title", description: nil, type: nil, onTap: {}),
            ListWidgetRow.Model(objectId: "3", icon: nil, title: "Object title", description: "Object description", type: nil, onTap: {})
        ]
    }
}
