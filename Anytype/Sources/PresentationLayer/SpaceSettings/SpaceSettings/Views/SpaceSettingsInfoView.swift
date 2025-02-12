import SwiftUI

struct SpaceSettingsInfoView: View {
    let info: [SettingsInfoModel]
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.SpaceSettings.info, style: .uxTitle1Semibold)
            Spacer.fixedHeight(12)
            ForEach(0..<info.count, id:\.self) { index in
                SettingsInfoBlockView(model: info[index])
            }
            Spacer.fixedHeight(12)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
    }
}

#Preview {
    SpaceSettingsInfoView(info: [])
}
