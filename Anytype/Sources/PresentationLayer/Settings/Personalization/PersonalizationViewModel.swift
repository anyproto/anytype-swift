import Foundation

@MainActor
final class PersonalizationViewModel: ObservableObject {
 
    // MARK: - DI
    private let spaceId: String
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private weak var output: PersonalizationModuleOutput?
    
    // MARK: - State
    
    @Published var objectType: String = ""
    
    init(spaceId: String, objectTypeProvider: ObjectTypeProviderProtocol, output: PersonalizationModuleOutput?) {
        self.spaceId = spaceId
        self.objectTypeProvider = objectTypeProvider
        self.output = output
        setupSubscriptions()
    }
    
    func onObjectTypeTap() {
        output?.onDefaultTypeSelected()
    }
    
    func onWallpaperChangeTap() {
        output?.onWallpaperChangeSelected()
    }
    
    private func setupSubscriptions() {
        objectTypeProvider.defaultObjectTypePublisher(spaceId: spaceId)
            .map { $0.name }
            .receiveOnMain()
            .assign(to: &$objectType)
    }
}
