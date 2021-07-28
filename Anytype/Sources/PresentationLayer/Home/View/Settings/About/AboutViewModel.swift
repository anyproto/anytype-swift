import SwiftUI
import Combine

class AboutViewModel: ObservableObject {
    private var configurationService = MiddlewareConfigurationService()
    private var subscription: AnyCancellable?
    @Published var libraryVersion: String = ""

    func viewLoaded() {
        subscription = configurationService.libraryVersionPublisher().receiveOnMain()
            .sinkWithDefaultCompletion("Obtain library version") { [weak self] version in
                // Example of version string, we need only #616e707
                // build on 2021-07-22T16:28:02Z from  at #616e707(clean)
                guard let commitWithStatus = version.version.components(separatedBy: "#")[safe: 1] else {
                    self?.libraryVersion = version.version
                    return
                }
                
                guard let commit = commitWithStatus.components(separatedBy: "(")[safe: 0] else {
                    self?.libraryVersion = commitWithStatus
                    return
                }
                
                self?.libraryVersion = commit
            }
    }
}
