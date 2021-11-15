import SwiftUI
import AnytypeCore

struct OtherSettingsView: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(18)
            AnytypeText("Other settings".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            defaultType
            #if !RELEASE
            clearCache
            #endif
            Spacer.fixedHeight(12)
        }
        .background(Color.background)
        .cornerRadius(16)
        .padding(.horizontal, 8)
    }
    
    var defaultType: some View {
        Button(action: { model.defaultType = true }) {
            HStack(spacing: 0) {
                AnytypeText("Default object type".localized, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                AnytypeText(ObjectTypeProvider.defaultObjectType.name, style: .uxBodyRegular, color: .textSecondary)
                Spacer.fixedWidth(10)
                Image.arrow.foregroundColor(.textTertiary)
            }
            .padding(.vertical, 14)
            .modifier(DividerModifier())
            .padding(.horizontal, 20)
        }
    }
    
    var clearCache: some View {
        Button(action: { model.clearCacheAlert = true }) {
            HStack(spacing: 0) {
                AnytypeText("Clear file cache", style: .uxBodyRegular, color: .pureRed)
                Spacer()
            }
            .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
        }
    }
}

struct OtherSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureBlue
            OtherSettingsView()
        }
    }
}
