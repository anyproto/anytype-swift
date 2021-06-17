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
        VStack {
            DragIndicator()
            AnytypeText("Anytype info", style: .title)
                .padding(.top, 34)
                .padding(.bottom, 25)
                .fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.center)
            AnytypeText("Library version", style: .body)
            AnytypeText(viewModel.libraryVersion, style: .body)
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
