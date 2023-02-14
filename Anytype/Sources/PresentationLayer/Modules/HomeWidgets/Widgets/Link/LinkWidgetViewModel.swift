import Foundation
import Combine
import BlocksModels

@MainActor
final class LinkWidgetViewModel: ObservableObject, WidgetContainerContentViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    
    @Published private(set) var name = ""
    let allowContent = false
    
    
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
    
    // MARK: - WidgetContainerContentViewModelProtocol

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
            }
            .store(in: &subscriptions)
    }
}
