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
            .eraseToAnyView()
    }
}

struct UnsplashItemView: View {
    let viewModel: UnsplashItemViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(viewModel.item.url)
                .resizable()
                .scaledToFill()
                .frame(height: 112)
            AnytypeText(viewModel.item.artistName, style: .caption2Medium, color: .textWhite)
                .padding(.init(8))
        }

    }
}
