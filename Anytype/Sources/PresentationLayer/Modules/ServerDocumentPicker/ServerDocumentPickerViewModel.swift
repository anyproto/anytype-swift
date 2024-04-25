import Foundation

@MainActor
final class ServerDocumentPickerViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.serverConfigurationStorage)
    private var storage: ServerConfigurationStorageProtocol
    
    // MARK: - State
    
    @Published var toast = ToastBarData.empty
    
    func onSelectFile(url: URL) {
        do {
            try storage.addConfiguration(filePath: url, setupAsCurrent: true)
            AnytypeAnalytics.instance().logUploadNetworkConfiguration()
            AnytypeAnalytics.instance().logSelectNetwork(type: .selfHost, route: .onboarding)
        } catch {
            toast = ToastBarData(text: Loc.error, showSnackBar: true, messageType: .failure)
        }
    }
}
