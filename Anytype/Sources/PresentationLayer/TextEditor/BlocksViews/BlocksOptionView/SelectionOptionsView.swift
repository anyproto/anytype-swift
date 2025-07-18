import SwiftUI

// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5469%3A0
struct SelectionOptionsView: View {
    @ObservedObject var viewModel: SelectionOptionsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 4) {
                ForEach(viewModel.items, id: \.self) { item in
                    Button {
                        item.action()
                    } label: {
                        SelectionOptionsItemView(
                            imageAsset: item.imageAsset,
                            title: item.title
                        )
                    }
                    .frame(height: 100)
                    .frame(minWidth: 68, maxWidth: 72)
                    .fixedSize()
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color.Background.secondary)
    }
}

private struct SelectionOptionsItemView: View {
    let imageAsset: ImageAsset
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Image(asset: imageAsset)
                .foregroundColor(.Control.secondary)
                .frame(width: 52, height: 52)
                .background(Color.Background.highlightedMedium)
                .cornerRadius(10.5)
            AnytypeText(title, style: .caption2Regular)
                .foregroundColor(.Text.secondary)
        }
        .padding(EdgeInsets(top: 16, leading: 0, bottom: 13, trailing: 0))

    }
}
