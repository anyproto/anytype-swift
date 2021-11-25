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
            iconPicker
            #if !RELEASE
            clearCache
            #endif
            Spacer.fixedHeight(12)
        }
        .background(Color.background)
        .cornerRadius(16)
        .padding(.horizontal, 8)
    }
    
    private var defaultType: some View {
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
    
    private var iconPicker: some View {
        VStack(alignment: .leading) {
            AnytypeText("App icon".localized, style: .uxBodyRegular, color: .textPrimary)
            HStack(spacing: 20) {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    appIcon(icon)
                }
                Spacer()
            }
        }
        .padding(.vertical, 14)
        .modifier(DividerModifier())
        .padding(.horizontal, 20)
    }
    
    private func appIcon(_ icon: AppIcon) -> some View {
        VStack(alignment: .center) {
            Button {
                AppIconManager.shared.setIcon(icon)
                UISelectionFeedbackGenerator().selectionChanged()
                
            } label: {
                icon.preview.resizable()
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                AppIconManager.shared.currentIcon == icon ? Color.pureAmber : Color.grayscale10,
                                lineWidth: 3
                            )
                    )
            }
            AnytypeText(icon.description, style: .uxCalloutRegular, color: AppIconManager.shared.currentIcon == icon ? .textPrimary : .textSecondary)
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
