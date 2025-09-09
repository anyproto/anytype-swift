import SwiftUI

@MainActor
final class ObjectTypeWidgetViewModel: ObservableObject {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private let blockWidgetExpandedService: any BlockWidgetExpandedServiceProtocol
    
    private let info: ObjectTypeWidgetInfo
    
    @Published var typeIcon: Icon?
    @Published var typeName: String = ""
    @Published var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    @Published var canCreateObject: Bool = false
    
    init(info: ObjectTypeWidgetInfo) {
        self.info = info
        blockWidgetExpandedService = Container.shared.blockWidgetExpandedService.resolve()
        isExpanded = blockWidgetExpandedService.isExpanded(id: info.objectTypeId)
    }
    
    func startSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            typeIcon = .object(type.icon)
            typeName = type.name
        }
    }
    
    func onCreateObject() {
        
    }
    
    func onHeaderTap() {
        
    }
    
    private func expandedDidChange() {
        UISelectionFeedbackGenerator().selectionChanged()
        blockWidgetExpandedService.setState(id: info.objectTypeId, isExpanded: isExpanded)
    }
}
