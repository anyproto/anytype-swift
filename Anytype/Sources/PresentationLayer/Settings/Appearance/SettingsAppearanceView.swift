import SwiftUI
import AnytypeCore

struct SettingsAppearanceView: View {
    
    @StateObject var model: SettingsAppearanceViewModel
    
    @Environment(\.appInterfaceStyle) private var appInterfaceStyle
    
    init() {
        _model = StateObject(wrappedValue: SettingsAppearanceViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer.fixedHeight(12)
            AnytypeText(Loc.appearance, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(12)
            
            appearanceType
            iconPicker
            
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.appearanceSettingsShow)
            model.setAppInterfaceStyle(appInterfaceStyle)
        }
    }
    
    private var appearanceType: some View {
        VStack(alignment: .center) {
            AnytypeText(Loc.mode, style: .caption1Medium)
                .foregroundColor(.Text.secondary)
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
                style: .caption2Regular
            )
            .foregroundColor(.Text.secondary)
            .frame(maxWidth: .infinity)
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .center) {
            AnytypeText(Loc.applicationIcon, style: .caption1Medium)
                .foregroundColor(.Text.secondary).padding(.bottom, 6)
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    Spacer.fixedWidth(20)
                    ForEach(AppIcon.allCases, id: \.self) { icon in
                        appIcon(icon)
                    }
                    Spacer.fixedWidth(20)
                }
                .padding(.top, 16)
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
                            .stroke(Color.Shape.tertiary, lineWidth: 1)
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
            SettingsAppearanceView()
        }
    }
}
