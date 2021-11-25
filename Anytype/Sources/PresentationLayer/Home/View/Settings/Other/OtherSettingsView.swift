import SwiftUI
import AnytypeCore

enum AppIcon {
    case oldSchool
    case gradient
    case art
    
    var description: String {
        switch self {
        case .oldSchool:
            return "Old School".localized
        case .gradient:
            return "Gradient".localized
        case .art:
            return "Art".localized
        }
    }
}

struct OtherSettingsView: View {
    @EnvironmentObject private var model: SettingsViewModel
    // TODO: User defaults
    @State var appIcon = AppIcon.gradient
    
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
                appIcon(type: .oldSchool)
                appIcon(type: .gradient)
                appIcon(type: .art)
                Spacer()
            }
        }
        .padding(.vertical, 14)
        .modifier(DividerModifier())
        .padding(.horizontal, 20)
    }
    
    private func appIcon(type: AppIcon) -> some View {
        VStack(alignment: .center) {
            Button(action: {
                appIcon = type
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Image.appIcon.resizable().frame(width: 64, height: 64)
                    .if(appIcon == type) {
                        $0.overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.pureAmber, lineWidth: 3)
                        )
                    }
            }
            AnytypeText(type.description, style: .uxCalloutRegular, color: appIcon == type ? .textPrimary : .textSecondary)
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
