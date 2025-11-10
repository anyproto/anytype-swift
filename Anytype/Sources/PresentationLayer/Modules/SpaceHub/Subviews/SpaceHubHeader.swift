import SwiftUI
import AnytypeCore

struct SpaceHubHeader: View {

    let showLoading: Bool
    let profileIcon: Icon?
    let notificationsDenied: Bool
    let onTapSettings: () -> Void
    let onTapCreateSpace: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 26, *) {
                contentIOS26
            } else {
                legacyContent
            }

            ProgressBar(showAnimation: showLoading)
        }
    }
    
    var contentIOS26: some View {
        HStack(spacing: 0) {
            AnytypeText(Loc.Spaces.title, style: .title)

            Spacer()

            settingsButton(small: false)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    var legacyContent: some View {
        HStack(spacing: 0) {
            settingsButton(small: true)

            Spacer()

            AnytypeText(Loc.Spaces.title, style: .uxTitle2Semibold)

            Spacer()

            SpaceHubNewSpaceButton { onTapCreateSpace() }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    private func settingsButton(small: Bool) -> some View {
        Button {
            onTapSettings()
        } label: {
            IconView(icon: profileIcon)
                .foregroundStyle(Color.Control.secondary)
                .frame(width: small ? 28 : 44, height: small ? 28 : 44)
                .overlay(alignment: .topTrailing) {
                    if notificationsDenied {
                        attentionDotView
                    }
                }
                .padding(.vertical, 8)
        }
    }

    private var attentionDotView: some View {
        SpaceHubAttentionDotView()
            .padding([.top, .trailing], 1)
    }
}
