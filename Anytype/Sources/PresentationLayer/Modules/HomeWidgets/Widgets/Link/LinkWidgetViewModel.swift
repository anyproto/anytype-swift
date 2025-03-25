import Foundation
import Combine
import Services
import AnytypeCore


@MainActor
final class LinkWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private weak var output: (any CommonWidgetModuleOutput)?
    
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
        output?.onObjectSelected(screenData: linkedObjectDetails.screenData())
    }
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.linkedObjectDetails = details
                self?.name = FeatureFlags.pluralNames ? details.pluralTitle : details.title
            }
            .store(in: &subscriptions)
    }
}
