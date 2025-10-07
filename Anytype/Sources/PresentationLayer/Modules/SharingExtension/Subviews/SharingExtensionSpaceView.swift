import SwiftUI

struct SharingExtensionSpaceView: View {
    
    let icon: Icon?
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            IconView(icon: icon)
                .frame(width: 80, height: 80)
                .overlay(alignment: .bottomTrailing) {
                    if isSelected {
                        AnytypeCircleCheckbox(checked: true)
                            .offset(x: 6, y: 6)
                    }
                }
            Text(title)
                .anytypeStyle(.relation3Regular)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(height: 116)
    }
}

#Preview {
    SharingExtensionSpaceView(
        icon: .object(.space(.name(name: "ABC", iconOption: 1, circular: true))),
        title: "Long text long text long text long text long text long text",
        isSelected: true
    )
    .frame(width: 123)
}
