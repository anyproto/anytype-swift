import SwiftUI
import AnytypeCore

struct SpaceHubHeader: View {

    let showLoading: Bool
    let profileIcon: Icon?
    let notificationsDenied: Bool
    @Binding var searchText: String
    let onTapSettings: () -> Void
    let onTapCreateSpace: () -> Void

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                contentIOS26
            } else {
                legacyContent
            }
        }
    }
    
    var contentIOS26: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                AnytypeText(Loc.Spaces.title, style: .title)
                
                Spacer()
                
                settingsButton(small: false)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            SpaceHubLoadingBar(showAnimation: showLoading)
        }
    }
    
    var legacyContent: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                settingsButton(small: true)

                Spacer()

                if showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer.fixedWidth(18)
                }

                AnytypeText(Loc.Spaces.title, style: .uxTitle2Semibold)

                Spacer()

                SpaceHubNewSpaceButton { onTapCreateSpace() }
            }
            .padding(.horizontal, 16)

            SearchBar(text: $searchText, focused: false)
        }
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
