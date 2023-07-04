import SwiftUI
import AnytypeCore

struct SettingsAppearanceView: View {
    
    @ObservedObject var model: SettingsAppearanceViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer.fixedHeight(12)
            AnytypeText(Loc.appearance, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            
            wallpaper
            appearanceType
            iconPicker
            
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.appearanceSettingsShow)
        }
    }
    
    private var wallpaper: some View {
        SettingsSectionItemView(
            name: Loc.wallpaper,
            imageAsset: .SettingsOld.setWallpaper,
            onTap: { model.onWallpaperChangeTap() }
        )
        .padding(.horizontal, 20)
    }

    private var appearanceType: some View {
        VStack(alignment: .center) {
            AnytypeText(Loc.mode, style: .caption1Medium, color: .Text.secondary)
                .frame(alignment: .center)
            HStack() {
                ForEach(UIUserInterfaceStyle.allCases) { style in
                    Button {
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
            Image(asset: style.imageAsset)
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
                color: .Text.secondary
            ).frame(maxWidth: .infinity)
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .center) {
            AnytypeText(Loc.applicationIcon, style: .caption1Medium, color: .Text.secondary).padding(.bottom, 6)
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
                model.updateIcon(icon)
            } label: {
                Image(asset: icon.previewAsset)
                    .cornerRadius(8)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.Stroke.tertiary, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                model.currentIcon == icon ? Color.System.amber25 : .clear,
                                lineWidth: 2
                            )
                            .frame(width: 66, height: 66)
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsAppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            SettingsAppearanceView(model: SettingsAppearanceViewModel(
                viewControllerProvider: DI.preview.uihelpersDI.viewControllerProvider(),
                output: nil
            ))
        }
    }
}
