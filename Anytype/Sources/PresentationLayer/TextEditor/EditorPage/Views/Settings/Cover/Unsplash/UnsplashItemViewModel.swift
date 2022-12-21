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
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                KFImage
                    .url(viewModel.item.url)
                    .setProcessors(
                        [
                            KFProcessorBuilder(
                                imageGuideline: ImageGuideline(
                                    size: .init(
                                        width: geometry.size.width > 0 ? geometry.size.width : 200,
                                        height: ItemPickerGridViewContants.gridItemHeight
                                    )
                                ),
                                scalingType: .resizing(.aspectFill)
                            ).build()
                        ]
                    )
                    .fade(duration: 0.25)
                AnytypeText(viewModel.item.artistName, style: .caption2Medium, color: .Text.white)
                    .padding(.init(8))
            }
        }
    }
}
