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
        .task {
            await model.startParticipantSpacesStorageTask()
        }
        .background(Color.Background.secondary)
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            ForEach(SpaceNotificationsSettingsMode.allCases, id: \.self) { mode in
                modeView(mode)
            }
        }
    }
    
    private func modeView(_ mode: SpaceNotificationsSettingsMode) -> some View {
        AsyncButton {
            try await model.onModeChange(mode)
        } label: {
            HStack(spacing: 0) {
                AnytypeText(mode.title, style: .previewTitle1Regular)
                    .foregroundColor(.Text.primary)
                Spacer()
                if model.mode == mode {
                    Image(asset: .X24.tick)
                        .foregroundColor(.Control.button)
                }
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .if(!mode.isLast) {
                $0.newDivider()
            }
            .padding(.horizontal, 16)
        }
    }
}
