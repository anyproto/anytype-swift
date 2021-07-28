import Foundation
import Combine
import SwiftUI
import Amplitude
import AnytypeCore

struct AboutView: View {
    @ObservedObject var viewModel: AboutViewModel
    
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
            VStack(alignment: .leading, spacing: 30) {
                if let version = MetadataProvider.appVersion {
                    AnytypeText("🤖 App version: \(version)", style: .title)
                }
                if let buildNumber = MetadataProvider.buildNumber {
                    AnytypeText("🛠 Build number: \(buildNumber)", style: .title)
                }
                AnytypeText("🧙 Library: \(viewModel.libraryVersion)", style: .title)
            }.padding()
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
            title: { AnytypeText("Anytype info", style: .title).padding() },
            icon: { Image.splashLogo.resizable().frame(width: 40, height: 40) }
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
