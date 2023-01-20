import Foundation
import BlocksModels
import Combine

@MainActor
final class FavoriteWidgetViewModel: ListWidgetViewModelProtocol, ObservableObject {
        
    // MARK: - DI
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    
    @Published private(set) var name: String = Loc.favorites
    @Published var isExpanded: Bool = true
    @Published private(set) var headerItems: [ListWidgetHeaderItem.Model] = []
    @Published private(set) var rows: [ListWidgetRow.Model] = []
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.output = output
    }
    
    // MARK: - ListWidgetViewModelProtocol
    
    func onAppear() {
        setupAllSubscriptions()
    }

    func onDisappear() {
        subscriptions.removeAll()
    }
    
    func onDeleteWidgetTap() {
       // TODO: Add configuration for context menu
    }
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        updateViewState()
    }
    
    private func updateViewState() {
        rows = [
            ListWidgetRow.Model(objectId: "1", icon: .placeholder("A"), title: "Object title", description: "Object description description description description description description ", onTap: {}),
            ListWidgetRow.Model(objectId: "2", icon: .placeholder("A"), title: "Object title title title title title title title title title", description: nil, onTap: {}),
            ListWidgetRow.Model(objectId: "3", icon: nil, title: "Object title", description: "Object description", onTap: {})
        ]
    }
}
