import Foundation

@MainActor
final class PersonalizationViewModel: ObservableObject {
 
    // MARK: - DI
    private let spaceId: String
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    private weak var output: PersonalizationModuleOutput?
    
    // MARK: - State
    
    @Published var objectType: String = ""
    
    init(spaceId: String, output: PersonalizationModuleOutput?) {
        self.spaceId = spaceId
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
