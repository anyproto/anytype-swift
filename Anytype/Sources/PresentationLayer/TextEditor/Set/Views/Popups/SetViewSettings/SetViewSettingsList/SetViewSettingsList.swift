import SwiftUI

struct SetViewSettingsList: View {
    @StateObject var model: SetViewSettingsListModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(
                "SetViewSettings",
                style: .uxBodyRegular,
                color: .Text.primary
            )
        }
        .frame(height: 400)
    }
}
