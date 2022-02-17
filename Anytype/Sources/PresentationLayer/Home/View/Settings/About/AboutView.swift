import Foundation
import Combine
import SwiftUI
import Amplitude
import AnytypeCore
import AudioToolbox

struct AboutView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var homeModel: HomeViewModel
    
    var body: some View {
        contentView
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
                if let userId = UserDefaultsConfig.usersId {
                    aboutRow(label: "User Id", value: userId)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(12, corners: .top)
    }
    
    func aboutRow(label: String, value: String) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            UIPasteboard.general.string = value
            homeModel.snackBarData = .init(text: "\(label) " + "copied to clipboard".localized, showSnackBar: true)
        } label: {
            HStack {
                AnytypeText(label, style: .uxBodyRegular, color: .textSecondary)
                Spacer.fixedWidth(50)
                Spacer()
                AnytypeText(value, style: .uxBodyRegular, color: .textPrimary)
            }
            .padding(.vertical, 12)
        }
    }
    
    @State private var titleTapCount = 0
    var title: some View {
        AnytypeText("About".localized, style: .title, color: .textPrimary)
            .onTapGesture {
                titleTapCount += 1
                if titleTapCount == 10 {
                    titleTapCount = 0
                    AudioServicesPlaySystemSound(1109)
                    model.about = false
                    model.debugMenu = true
                }
            }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
