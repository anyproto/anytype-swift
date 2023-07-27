import Foundation

@MainActor
final class PersonalizationViewModel: ObservableObject {
 
    // MARK: - DI
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private weak var output: PersonalizationModuleOutput?
    
    // MARK: - State
    
    @Published var objectType: String = ""
    
    init(objectTypeProvider: ObjectTypeProviderProtocol, output: PersonalizationModuleOutput?) {
        self.objectTypeProvider = objectTypeProvider
        self.output = output
        setupSubscriptions()
    }
    
    func onObjectTypeTap() {
        output?.onDefaultTypeSelected()
    }
    
    private func setupSubscriptions() {
        objectTypeProvider.defaultObjectTypePublisher
            .map { $0.name }
            .receiveOnMain()
            .assign(to: &$objectType)
    }
}
