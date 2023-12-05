import Foundation
import SwiftUI
import Combine

@MainActor
final class ServerConfigurationViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let storage: ServerConfigurationStorage
    private weak var output: ServerConfigurationModuleOutput?
    
    // MARK: - State
    
    @Published var mainRow: ServerConfigurationRow?
    @Published var rows: [ServerConfigurationRow] = []
    
    private var subscriptions = [AnyCancellable]()
    
    init(storage: ServerConfigurationStorage, output: ServerConfigurationModuleOutput?) {
        self.storage = storage
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
        
        mainRow = makeRow(config: .anytype)
        
        var otherConfigs = storage.installedConfigurations()
        otherConfigs.insert(.localOnly, at: 0)
        
        rows = otherConfigs.map { config in
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
            }
        )
    }
}
