import Foundation
import Combine
import SwiftUI
import Amplitude
import AnytypeCore
import AudioToolbox

struct AboutView: View {
    @EnvironmentObject var viewModel: SettingSectionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        contentView
            .onAppear {
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.showAboutScreen)
            }
    }
    
    var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(70)
            title
            Spacer.fixedHeight(27)
            
            VStack(alignment: .leading, spacing: 0) {
                if let version = MetadataProvider.appVersion, version.isNotEmpty {
                    aboutRow(label: "App version", value: version)
                }
                if let buildNumber = MetadataProvider.buildNumber, buildNumber.isNotEmpty {
                    aboutRow(label: "Build number", value: buildNumber)
                }
                if let libraryVersion = MiddlewareConfigurationService.shared.libraryVersion(), libraryVersion.isNotEmpty {
                    aboutRow(label: "Library", value: libraryVersion)
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
    
    func aboutRow(label: String, value: String) -> some View {
        HStack {
            AnytypeText(label, style: .uxBodyRegular, color: .textSecondary)
            Spacer()
            AnytypeText(value, style: .uxBodyRegular, color: .textPrimary)
        }
        .padding(.vertical, 12)
        .modifier(DividerModifier(spacing: 0))
    }
    
    @State private var titleTapCount = 0
    var title: some View {
        AnytypeText("About", style: .title, color: .textPrimary)
            .onTapGesture {
                titleTapCount += 1
                if titleTapCount == 10 {
                    titleTapCount = 0
                    AudioServicesPlaySystemSound(1109)
                    presentationMode.wrappedValue.dismiss()
                    viewModel.debugMenu = true
                }
            }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
