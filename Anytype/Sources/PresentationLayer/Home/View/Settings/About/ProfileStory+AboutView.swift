import Foundation
import Combine
import SwiftUI

struct AboutView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.viewLoaded()
            }
    }
    
    var contentView: some View {
        VStack(alignment: .center) {
            DragIndicator()
            AnytypeText("Anytype info", style: .title).padding()
            AnytypeText("Library version", style: .subheading).padding()
            AnytypeText(viewModel.libraryVersion, style: .subheading)
            Spacer()
        }
        .padding([.leading, .trailing])
    }
}

extension AboutView {
    class ViewModel: ObservableObject {
        private var configurationService: ConfigurationServiceProtocol = MiddlewareConfigurationService()
        private var subscription: AnyCancellable?
        @Published var libraryVersion: String = ""

        func viewLoaded() {
            subscription = configurationService.obtainLibraryVersion().receiveOnMain()
                .sinkWithDefaultCompletion("Obtain library version") { [weak self] version in
                    self?.libraryVersion = version.version
                }
        }
    }
}
