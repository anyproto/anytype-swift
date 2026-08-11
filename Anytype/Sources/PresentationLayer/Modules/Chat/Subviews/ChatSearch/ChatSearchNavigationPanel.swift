import SwiftUI

struct ChatSearchNavigationPanel: View {
    @Namespace private var glassNamespace

    let canGoOlder: Bool
    let canGoNewer: Bool
    let onTapOlder: () -> Void
    let onTapNewer: () -> Void

    var body: some View {
        GlassEffectContainerIOS26(spacing: 6) {
            VStack(spacing: 10) {
                button(asset: .X24.Arrow.up, enabled: canGoOlder, glassId: "searchUp") {
                    onTapOlder()
                }
                button(asset: .X24.Arrow.down, enabled: canGoNewer, glassId: "searchDown") {
                    onTapNewer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func button(asset: ImageAsset, enabled: Bool, glassId: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(asset: asset)
                .frame(width: 48, height: 48)
        }
        .frame(width: 48, height: 48)
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26(glassId, in: glassNamespace)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.3)
    }
}
