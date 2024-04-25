import Foundation
import SwiftUI

struct HomeBottomPanelView: View {
    
    @Binding var homeState: HomeWidgetsState
    let onCreateWidgetSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if homeState.isEditWidgets {
                editButtons
            }
        }
        .animation(.default, value: homeState)
        .fitIPadToReadableContentGuide()
    }
    
    private var editButtons: some View {
        HStack(alignment: .center, spacing: 10) {
            makeButton(text: Loc.add) {
                AnytypeAnalytics.instance().logAddWidget(context: .editor)
                onCreateWidgetSelected()
            }
            makeButton(text: Loc.done) {
                homeState = .readwrite
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 10)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
    
    private func makeButton(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            AnytypeText(text, style: .uxBodyRegular)
                .foregroundColor(.Text.white)
                .frame(maxWidth: .infinity)
        })
        .frame(height: 52)
        .background(Color.Widget.bottomPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(14, style: .continuous)
    }
}
