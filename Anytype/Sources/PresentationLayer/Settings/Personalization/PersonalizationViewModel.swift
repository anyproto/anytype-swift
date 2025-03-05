import Foundation

@MainActor
final class PersonalizationViewModel: ObservableObject {
 
    // MARK: - DI
    private let spaceId: String
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private weak var output: (any PersonalizationModuleOutput)?
    
    // MARK: - State
    
    @Published var objectType: String = ""
    
    init(spaceId: String, output: (any PersonalizationModuleOutput)?) {
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
            .map { $0.displayName }
            .receiveOnMain()
            .assign(to: &$objectType)
    }
}
