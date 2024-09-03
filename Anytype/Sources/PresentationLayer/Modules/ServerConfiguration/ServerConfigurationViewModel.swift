import Foundation
import SwiftUI
import Combine

@MainActor
final class ServerConfigurationViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.serverConfigurationStorage)
    private var storage: any ServerConfigurationStorageProtocol
    private weak var output: (any ServerConfigurationModuleOutput)?
    
    // MARK: - State
    
    @Published var mainRows: [ServerConfigurationRow] = []
    @Published var rows: [ServerConfigurationRow] = []
    @Published var showLocalConfigurationAlert = false
    
    private var subscriptions = [AnyCancellable]()
    
    init(output: (any ServerConfigurationModuleOutput)?) {
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
    
    func setup(config: NetworkServerConfig) {
        storage.setupCurrentConfiguration(config: config)
        updateRows()
        AnytypeAnalytics.instance().logSelectNetwork(type: config.analyticsType, route: .onboarding)
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
                self?.handleOnTap(config: config)
            }
        )
    }
    
    private func handleOnTap(config: NetworkServerConfig) {
        guard config != storage.currentConfiguration() else { return }
        if config.isLocalOnly {
            showLocalConfigurationAlert.toggle()
        } else {
            setup(config: config)
        }
    }
}
