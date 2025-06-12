import Foundation
import SwiftUI

struct SpaceNotificationsSettingsView: View {
    
    @StateObject private var model: SpaceNotificationsSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceNotificationsSettingsModuleData) {
        self._model = StateObject(wrappedValue: SpaceNotificationsSettingsViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.notifications)
            content
            Spacer()
        }
        .background(Color.Background.secondary)
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            ForEach(SpaceNotificationsSettingsState.allCases, id: \.self) { state in
                stateView(state)
            }
        }
    }
    
    private func stateView(_ state: SpaceNotificationsSettingsState) -> some View {
        Button {
            model.onStateChange(state)
        } label: {
            HStack(spacing: 0) {
                AnytypeText(state.title, style: .previewTitle1Regular)
                    .foregroundColor(.Text.primary)
                Spacer()
                if model.state == state {
                    Image(asset: .X24.tick)
                        .foregroundColor(.Control.button)
                }
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .if(!state.isLast) {
                $0.newDivider()
            }
            .padding(.horizontal, 16)
        }
    }
}
