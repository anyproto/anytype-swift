import Foundation
import SwiftUI
import Combine

@MainActor
final class ServerConfigurationViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.serverConfigurationStorage)
    private var storage: ServerConfigurationStorageProtocol
    private weak var output: ServerConfigurationModuleOutput?
    
    // MARK: - State
    
    @Published var mainRows: [ServerConfigurationRow] = []
    @Published var rows: [ServerConfigurationRow] = []
    
    private var subscriptions = [AnyCancellable]()
    
    init(output: ServerConfigurationModuleOutput?) {
        self.output = output
        storage.installedConfigurationsPublisher.receiveOnMain().sink { [weak self] _ in
            withAnimation {
                self?.updateRows()
            }
        }.store(in: &subscriptions)
    }
    
    func onTapAddServer() {
        output?.onAddServerSelected()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        mainRows = [makeRow(config: .anytype), makeRow(config: .localOnly)]
        rows = storage.installedConfigurations().map { config in
            makeRow(config: config)
        }
    }
    
    private func makeRow(config: NetworkServerConfig) -> ServerConfigurationRow {
        ServerConfigurationRow(
            title: config.title,
            isSelected: config == storage.currentConfiguration(),
            onTap: { [weak self] in
                self?.storage.setupCurrentConfiguration(config: config)
                self?.updateRows()
                AnytypeAnalytics.instance().logSelectNetwork(type: config.analyticsType, route: .onboarding)
            }
        )
    }
}
