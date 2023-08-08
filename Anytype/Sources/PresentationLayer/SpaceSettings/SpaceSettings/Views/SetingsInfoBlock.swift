import SwiftUI

struct SettingsInfoBlock: View {
    
    let title: String
    let subtitle: String
    let onTap: (() -> Void)?
    
    init(title: String, subtitle: String, onTap: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(title, style: .uxTitle1Semibold, color: .Text.primary)
            HStack {
                AnytypeText(subtitle, style: .previewTitle2Regular, color: .Text.primary)
                Spacer()
                if let onTap {
                    Image(asset: .X24.copy)
                        .foregroundColor(.Button.active)
                        .onTapGesture {
                            onTap()
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
