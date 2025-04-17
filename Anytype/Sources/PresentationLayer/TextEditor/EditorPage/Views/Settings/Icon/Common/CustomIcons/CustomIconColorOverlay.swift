import SwiftUI
import Services


struct CustomIconColorOverlay: View {
    let icon: CustomIcon
    let onColorSelected: (CustomIconColor) -> Void
    
    private let columns = [
        GridItem(.fixed(48), spacing: 0),
        GridItem(.fixed(48), spacing: 0),
        GridItem(.fixed(48), spacing: 0),
        GridItem(.fixed(48), spacing: 0),
        GridItem(.fixed(48), spacing: 0)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(CustomIconColor.allCases, id: \.rawValue) { color in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    onColorSelected(color)
                } label: {
                    Image(asset: icon.imageAsset)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color.color)
                        .frame(width: 40, height: 40)
                        .padding(8)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.Background.secondary))
                .shadow(radius: 4)
        )
    }
}
