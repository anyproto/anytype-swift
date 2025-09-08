import SwiftUI

@MainActor
final class ObjectTypeWidgetViewModel: ObservableObject {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let info: ObjectTypeWidgetInfo
    
    @Published var typeIcon: Icon?
    @Published var typeName: String = ""
    
    init(info: ObjectTypeWidgetInfo) {
        self.info = info
    }
    
    func startSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            typeIcon = .object(type.icon)
            typeName = type.name
        }
    }
}
