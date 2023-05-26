import Foundation
import AnytypeCore
import UIKit

struct AboutRowModel: Identifiable {
    let title: String
    let value: String
    let onTap: () -> Void
    
    var id: String { title }
}

@MainActor
final class AboutLegacyViewModel: ObservableObject {
    
    // MARK: - DI
    
    private weak var output: AboutModuleOutput?
    
    // MARK: - Private
    
    private var appVersion: String? = MetadataProvider.appVersion
    private var buildNumber: String? = MetadataProvider.buildNumber
    private var analyticsId: String?
    private var libraryVersion: String?
    
    // MARK: - Public
    
    @Published var snackBarData = ToastBarData.empty
    @Published private(set) var rows: [AboutRowModel] = []
    
    init(middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol, accountManager: AccountManagerProtocol, output: AboutModuleOutput?) {
        self.libraryVersion = middlewareConfigurationProvider.libraryVersion()
        self.analyticsId = accountManager.account.info.analyticsId
        self.output = output
        setupView()
    }
    
    func onDebugMenuTap() {
        output?.onDebugMenuSelected()
    }
    
    // MARK: - Private
    
    private func setupView() {
        rows = .builder {
            if let version = appVersion, version.isNotEmpty {
                createRow(title: Loc.About.appVersionLegacy, value: version)
            }
            if let buildNumber = buildNumber, buildNumber.isNotEmpty {
                createRow(title: Loc.About.buildNumberLegacy, value: buildNumber)
            }
            if let libraryVersion = libraryVersion, libraryVersion.isNotEmpty {
                createRow(title: Loc.About.libraryLegacy, value: libraryVersion)
            }
            if let analyticsId = analyticsId, analyticsId.isNotEmpty {
                createRow(title: Loc.About.analyticsIdLegacy, value: analyticsId)
            }
        }
    }
    
    private func createRow(title: String, value: String) -> AboutRowModel {
        return AboutRowModel(title: title, value: value) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            UIPasteboard.general.string = value
            self?.snackBarData = .init(text: Loc.copiedToClipboard(title), showSnackBar: true)
        }
    }
}
