import SwiftUI
import Services
import AnytypeCore


@MainActor
final class PublishedSitesViewModel: ObservableObject {
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    
    
    @Published var sites: [PublishState]?
    @Published var error: String?
    
    init() { }
    
    func loadData() async {
        do {
            sites = try await publishingService.list()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
