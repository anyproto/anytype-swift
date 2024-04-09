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
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(model.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            HStack {
                AnytypeText(model.subtitle, style: .previewTitle2Regular)
                    .foregroundColor(.Text.primary)
                Spacer()
                if let onTap = model.onTap {
                    Image(asset: .X24.copy)
                        .foregroundColor(.Button.active)
                        .onTapGesture {
                            onTap()
                        }
                }
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
