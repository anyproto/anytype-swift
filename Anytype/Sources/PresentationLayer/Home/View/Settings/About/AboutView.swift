import Foundation
import Combine
import SwiftUI
import Amplitude
import AnytypeCore

struct AboutView: View {
    var body: some View {
        contentView
            .onAppear {
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.showAboutScreen)
            }
    }
    
    var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator().padding(.bottom, 70)
            title.padding(.bottom, 27)
            VStack(alignment: .leading, spacing: 30) {
                if let version = MetadataProvider.appVersion {
                    aboutRow(label: "App version", value: version)
                }
                if let buildNumber = MetadataProvider.buildNumber {
                    aboutRow(label: "Build number", value: buildNumber)
                }
                if let libraryVersion = MiddlewareConfigurationService.shared.libraryVersion() {
                    aboutRow(label: "Library", value: libraryVersion)
                }
            }.padding(.horizontal)
            Spacer()
        }
        .sheet(isPresented: $showDebugMenu) {
            FeatureFlagsView()
        }
    }
    
    func aboutRow(label: String, value: String) -> some View {
        HStack {
            AnytypeText(label, style: .uxBodyRegular, color: .textSecondary)
            Spacer()
            AnytypeText(value, style: .uxBodyRegular, color: .textPrimary)
        }
        .modifier(DividerModifier())
    }
    
    @State private var titleTapCount = 0
    @State private var showDebugMenu = false
    var title: some View {
        AnytypeText("About", style: .title, color: .textPrimary)
            .onTapGesture {
                titleTapCount += 1
                if titleTapCount == 10 {
                    titleTapCount = 0
                    showDebugMenu = true
                }
            }
    }
}
