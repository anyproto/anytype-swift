import SwiftUI
import Combine
import Kingfisher

struct UnsplashItemViewModel: Identifiable {
    var id: String { item.id }
    let item: UnsplashItem
}

extension UnsplashItemViewModel: GridItemViewModel {
    var view: AnyView {
        UnsplashItemView(viewModel: self)
//            .frame(height: ItemPickerGridViewContants.gridItemHeight)
            .clipped()
            .eraseToAnyView()
    }
}

struct UnsplashItemView: View {
    let viewModel: UnsplashItemViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage
                .url(viewModel.item.url)
                .fade(duration: 0.25)
//                .resizable()

                .resizable()
                .aspectRatio(contentMode: .fill)

                .scaledToFill()
                .clipped()
            AnytypeText(viewModel.item.artistName, style: .caption2Medium, color: .textWhite)
                .padding(.init(8))
        }

    }
}
