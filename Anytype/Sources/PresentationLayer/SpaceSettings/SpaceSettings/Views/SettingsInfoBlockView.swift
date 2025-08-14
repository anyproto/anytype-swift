import SwiftUI

struct SettingsInfoModel {
    let title: String
    let subtitle: String
    let onTap: (() -> Void)?
    
    init(title: String, subtitle: String, onTap: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.onTap = onTap
    }
}

struct SettingsInfoBlockView: View {
    
    let model: SettingsInfoModel
    
    var body: some View {
        Button {
            model.onTap?()
        } label: {
            label
        }
        .disabled(model.onTap.isNil)
    }
    
    var label: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(model.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            HStack {
                AnytypeText(model.subtitle, style: .previewTitle2Regular)
                    .foregroundColor(.Text.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if model.onTap.isNotNil {
                    Image(asset: .X24.copy)
                        .foregroundColor(.Control.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack {
        SettingsInfoBlockView(
            model: SettingsInfoModel(
                title: "Description",
                subtitle: "Setting without action",
                onTap: nil
            )
        )
        SettingsInfoBlockView(
            model: SettingsInfoModel(
                title: "AnytypeId",
                subtitle: "Setting with action",
                onTap: { }
            )
        )
    }.padding()
}
