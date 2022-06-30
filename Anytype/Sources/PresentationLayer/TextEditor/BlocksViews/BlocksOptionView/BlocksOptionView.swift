import SwiftUI

// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5469%3A0
struct BlocksOptionView: View {
    @ObservedObject var viewModel: BlocksOptionViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(viewModel.options, id: \.self) { item in
                    Button {
                        viewModel.tapHandler?(item)
                    } label: {
                        BlocksOptionItemView(
                            image: item.image,
                            title: item.title
                        )
                    }
                    .frame(width: 68, height: 100)
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color.backgroundSecondary)
    }
}

private struct BlocksOptionItemView: View {
    let image: UIImage
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Image(uiImage: image)
                .frame(width: 52, height: 52)
                .background(Color.backgroundSelected)
                .cornerRadius(10.5)
            AnytypeText(title, style: .caption2Regular, color: .textSecondary)
        }
        .padding(EdgeInsets(top: 16, leading: 0, bottom: 13, trailing: 0))
    }
}

struct BlocksOptionView_Previews: PreviewProvider {
    static var previews: some View {
        BlocksOptionView(viewModel: .init())
            .previewLayout(.fixed(width: 340, height: 100))
    }
}
