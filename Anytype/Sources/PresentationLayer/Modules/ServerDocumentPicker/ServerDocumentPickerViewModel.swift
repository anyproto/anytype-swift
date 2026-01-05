import Foundation

@MainActor
@Observable
final class ServerDocumentPickerViewModel {

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.serverConfigurationStorage)
    private var storage: any ServerConfigurationStorageProtocol

    // MARK: - State

    var toast: ToastBarData?
    
    func onSelectFile(url: URL) {
        do {
            try storage.addConfiguration(filePath: url, setupAsCurrent: true)
            AnytypeAnalytics.instance().logUploadNetworkConfiguration()
            AnytypeAnalytics.instance().logSelectNetwork(type: .selfHost, route: .onboarding)
        } catch {
            toast = ToastBarData(Loc.error, type: .failure)
        }
    }
}
