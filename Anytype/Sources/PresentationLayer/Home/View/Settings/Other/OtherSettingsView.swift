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
            appearanceType
            iconPicker
            clearCache
            Spacer.fixedHeight(12)
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(16)
        .padding(.horizontal, 8)
    }

    private var appearanceType: some View {
        VStack(alignment: .center) {
            AnytypeText("Appearance".localized, style: .caption1Medium, color: .textSecondary)
                .frame(alignment: .center)
            HStack() {
                ForEach(UIUserInterfaceStyle.allCases) { style in
                    Button {
                        model.currentStyle = style
                    } label: {
                        VStack {
                            Image(uiImage: style.image)
                                .frame(width: 60, height: 60, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16).stroke(
                                        model.currentStyle == style ? Color.System.amber : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                                .padding(.bottom, 8)

                            AnytypeText(
                                style.title.localized,
                                style: .caption2Regular,
                                color: .textSecondary
                            ).frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding(.vertical, 14)
        .modifier(DividerModifier())
        .padding(.horizontal, 20)
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
            AnytypeText("App icon".localized, style: .uxBodyRegular, color: .textPrimary).padding(.bottom, 6)
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
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                AppIconManager.shared.currentIcon == icon ? Color.System.amber : Color.strokeTertiary,
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
                AnytypeText("Clear file cache".localized, style: .uxBodyRegular, color: Color.System.red)
                Spacer()
            }
            .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
        }
    }
}

struct OtherSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            OtherSettingsView()
        }
    }
}
