import SwiftUI
import AnytypeCore
import Amplitude

struct SettingsAppearanceView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            Spacer.fixedHeight(12)
            AnytypeText("Appearance".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            wallpaper
            appearanceType
            iconPicker
            
            Spacer.fixedHeight(20)
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            Amplitude.instance().logEvent(AmplitudeEventsName.appearanceSettingsShow)
        }
    }
    
    private var wallpaper: some View {
        SettingsSectionItemView(
            name: "Wallpaper".localized,
            icon: .settings.wallpaper,
            pressed: $model.wallpaperPicker
        )
        .sheet(isPresented: $model.wallpaperPicker) {
            WallpaperPickerView()
        }
        .padding(.horizontal, 20)
    }

    private var appearanceType: some View {
        VStack(alignment: .center) {
            AnytypeText("Mode".localized, style: .caption1Medium, color: .textSecondary)
                .frame(alignment: .center)
            HStack() {
                ForEach(UIUserInterfaceStyle.allCases) { style in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.currentStyle = style
                    } label: {
                        appearanceButton(style: style)
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding(.vertical, 14)
        .divider()
        .padding(.horizontal, 20)
    }
    
    private func appearanceButton(style: UIUserInterfaceStyle) -> some View {
        VStack {
            Image(uiImage: style.image)
                .frame(width: 60, height: 60, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius: 16).stroke(
                        model.currentStyle == style ? Color.System.yellow : Color.clear,
                        lineWidth: 2
                    ).frame(width: 66, height: 66)
                )
                .padding(.bottom, 8)

            AnytypeText(
                style.title.localized,
                style: .caption2Regular,
                color: model.currentStyle == style ? .textPrimary : .textSecondary
            ).frame(maxWidth: .infinity)
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .center) {
            AnytypeText("Application icon".localized, style: .caption1Medium, color: .textSecondary).padding(.bottom, 6)
            HStack {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    appIcon(icon)
                }
            }
        }
        .padding(.vertical, 14)
        .divider()
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
                    .cornerRadius(8)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.strokeTertiary, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                AppIconManager.shared.currentIcon == icon ? Color.System.yellow : .clear,
                                lineWidth: 2
                            )
                            .frame(width: 66, height: 66)
                    )
            }
            AnytypeText(icon.description, style: .caption2Regular, color: AppIconManager.shared.currentIcon == icon ? .textPrimary : .textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    var clearCache: some View {
        Button(action: { model.clearCacheAlert = true }) {
            HStack(spacing: 0) {
                AnytypeText("Clear file cache".localized, style: .uxBodyRegular, color: Color.System.red)
                Spacer()
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsAppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            SettingsAppearanceView()
        }
    }
}
