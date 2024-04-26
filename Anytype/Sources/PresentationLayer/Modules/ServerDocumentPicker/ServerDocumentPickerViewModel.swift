import Foundation

@MainActor
final class ServerDocumentPickerViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let storage: ServerConfigurationStorage
    
    // MARK: - State
    
    @Published var toast = ToastBarData.empty
    
    init(storage: ServerConfigurationStorage) {
        self.storage = storage
    }
    
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
