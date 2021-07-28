import Foundation
import Combine
import SwiftUI
import Amplitude


struct AboutView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        contentView
            .onAppear {
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.showAboutScreen)

                viewModel.viewLoaded()
            }
    }
    
    var contentView: some View {
        VStack(alignment: .center) {
            DragIndicator()
            title
            AnytypeText("Library version", style: .subheading).padding()
            AnytypeText(viewModel.libraryVersion, style: .subheading)
            Spacer()
        }
        .padding([.leading, .trailing])
        .sheet(isPresented: $showDebugMenu) {
            FeatureFlagsView()
        }
    }
    
    @State private var titleTapCount = 0
    @State private var showDebugMenu = false
    var title: some View {
        Label(
            title: {
                AnytypeText("Anytype info", style: .title).padding()
            }, icon: {
                Image.splashLogo
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        )
        .onTapGesture {
            titleTapCount += 1
            if titleTapCount == 10 {
                titleTapCount = 0
                showDebugMenu = true
            }
        }
    }
}

extension AboutView {
    class ViewModel: ObservableObject {
        private var configurationService = MiddlewareConfigurationService()
        private var subscription: AnyCancellable?
        @Published var libraryVersion: String = ""

        func viewLoaded() {
            subscription = configurationService.libraryVersionPublisher().receiveOnMain()
                .sinkWithDefaultCompletion("Obtain library version") { [weak self] version in
                    self?.libraryVersion = version.version
                }
        }
    }
}
