import SwiftUI

struct ExperimentalFeatureRow: View {
    
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    if title.isNotEmpty {
                        AnytypeText(title, style: .caption1Regular)
                            .foregroundColor(.Text.primary)
                    }
                    if subtitle.isNotEmpty {
                        AnytypeText(subtitle, style: .caption1Regular)
                            .foregroundColor(.Text.secondary)
                    }
                }
            }
        }
        .lineLimit(1)
        .toggleStyle(SwitchToggleStyle(tint: .Control.accent80))
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .border(16, color: .Shape.primary, lineWidth: 0.5)
    }
}


#Preview {
    ExperimentalFeatureRow(title: "titlesdf sdfsd fdsf dsfsd fsdafsd f", subtitle: "subtitle sdf sdfds fsdfsd fsd sdgd gdfg dfgdfg dfgdfs gdfsgdfs gdfg dfgdfgdsfgdsfgdfs g", isOn: .constant(true))
}
