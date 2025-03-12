import SwiftUI


struct ObjectSettingRow: View {
    
    let setting: ObjectSetting
    let showDivider: Bool
    let onTap: () async throws -> Void
    
    var body: some View {
        AsyncButton {
            try await onTap()
        } label: {
            settingButton
        }
        .if(showDivider) {
            $0.divider()
        }
    }

    private var settingButton: some View {
        HStack(spacing: 12) {
            Image(asset: setting.imageAsset)
                .resizable().scaledToFit()
                .frame(width: 24, height: 24)

            AnytypeText(setting.title, style: .previewTitle1Regular)
                .foregroundColor(.Text.primary)

            Spacer()

            decoration
        }
        .frame(height: 52)
    }
    
    private var decoration: some View {
        Group {
            switch setting {
            case .icon, .cover, .relations, .history:
                Image(asset: .arrowForward)
            case .description(let isVisible):
                AnytypeText(isVisible ? Loc.hide : Loc.show, style: .previewTitle1Regular).foregroundColor(Color.Text.secondary)
            case .resolveConflict:
                EmptyView()
            }
        }
    }
    
}

#Preview {
    VStack {
        ObjectSettingRow(setting: .cover, showDivider: true) {}
        ObjectSettingRow(setting: .relations, showDivider: true) {}
        ObjectSettingRow(setting: .description(isVisible: false), showDivider: true) {}
    }.padding()
}
