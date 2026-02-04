import Foundation

@MainActor
@Observable
final class PersonalizationViewModel {

    // MARK: - DI
    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @ObservationIgnored
    private weak var output: (any PersonalizationModuleOutput)?

    // MARK: - State

    var objectType: String = ""

    init(spaceId: String, output: (any PersonalizationModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }

    func onObjectTypeTap() {
        output?.onDefaultTypeSelected()
    }

    func onWallpaperChangeTap() {
        output?.onWallpaperChangeSelected()
    }

    func startSubscription() async {
        for await defaultObjectType in objectTypeProvider.defaultObjectTypePublisher(spaceId: spaceId).values {
            objectType = defaultObjectType.displayName
        }
    }
}
