import SwiftUI

struct HomePageOptionRow: View {

    let icon: ImageAsset
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(asset: icon)
                    .foregroundStyle(Color.Control.primary)

                AnytypeText(title, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(asset: .X24.tick)
                }
            }
            .frame(height: 52)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        HomePageOptionRow(
            icon: .X18.list,
            title: "Widgets",
            isSelected: true
        ) {}

        HomePageOptionRow(
            icon: .X18.list,
            title: "Last Opened Object",
            isSelected: false
        ) {}
    }
}
