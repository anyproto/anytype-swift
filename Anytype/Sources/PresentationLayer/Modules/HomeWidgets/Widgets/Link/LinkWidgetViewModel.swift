import Foundation
import Combine
import Services

@MainActor
final class LinkWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    
    @Published private(set) var name = ""
    var dragId: String? { widgetBlockId }
    
    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.output = data.output
        setupAllSubscriptions()
    }
    
    func onHeaderTap() {
        guard let linkedObjectDetails else { return }
        AnytypeAnalytics.instance().logSelectHomeTab(source: .object(type: linkedObjectDetails.analyticsType))
        output?.onObjectSelected(screenData: linkedObjectDetails.editorScreenData())
    }
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.linkedObjectDetails = details
                self?.name = details.title
            }
            .store(in: &subscriptions)
    }
}
