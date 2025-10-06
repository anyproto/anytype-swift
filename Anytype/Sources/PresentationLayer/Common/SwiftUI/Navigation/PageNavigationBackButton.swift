import SwiftUI

struct PageNavigationBackButton: View {
    
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.pageNavigationHiddenBackButton) private var pageNavigationHiddenBackButton
    
    var body: some View {
        IncreaseTapButton {
            pageNavigation.pop()
        } label: {
            Image(asset: .X24.back)
                .navPanelDynamicForegroundStyle()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    pageNavigation.popToFirstInSpace()
                }
        )
        .if(pageNavigationHiddenBackButton) {
            $0.hidden()
        }
        .accessibilityLabel("NavigationBack")
    }
}

extension EnvironmentValues {
    @Entry var pageNavigationHiddenBackButton = false
}

extension View {
    func pageNavigationHiddenBackButton(_ value: Bool) -> some View {
        environment(\.pageNavigationHiddenBackButton, value)
    }
}
