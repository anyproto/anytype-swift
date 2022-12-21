import SwiftUI
import AnytypeCore

struct SettingsAppearanceView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            Spacer.fixedHeight(12)
            AnytypeText(Loc.appearance, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            wallpaper
            appearanceType
            iconPicker
            
            Spacer.fixedHeight(20)
        }
        .background(Color.BackgroundNew.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.appearanceSettingsShow)
        }
    }
    
    private var wallpaper: some View {
        SettingsSectionItemView(
            name: Loc.wallpaper,
            imageAsset: .settingsSetWallpaper,
            pressed: $model.wallpaperPicker
        )
        .sheet(isPresented: $model.wallpaperPicker) {
            WallpaperPickerView()
        }
        .padding(.horizontal, 20)
    }

    private var appearanceType: some View {
        VStack(alignment: .center) {
            AnytypeText(Loc.mode, style: .caption1Medium, color: .textSecondary)
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
                        model.currentStyle == style ? Color.System.amber25 : Color.clear,
                        lineWidth: 2
                    ).frame(width: 66, height: 66)
                )
                .padding(.bottom, 8)

            AnytypeText(
                style.title,
                style: .caption2Regular,
                color: .textSecondary
            ).frame(maxWidth: .infinity)
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .center) {
            AnytypeText(Loc.applicationIcon, style: .caption1Medium, color: .textSecondary).padding(.bottom, 6)
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
                                AppIconManager.shared.currentIcon == icon ? Color.System.amber25 : .clear,
                                lineWidth: 2
                            )
                            .frame(width: 66, height: 66)
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }

    var clearCache: some View {
        Button(action: { model.clearCacheAlert = true }) {
            HStack(spacing: 0) {
                AnytypeText(Loc.clearFileCache, style: .uxBodyRegular, color: Color.System.red)
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
