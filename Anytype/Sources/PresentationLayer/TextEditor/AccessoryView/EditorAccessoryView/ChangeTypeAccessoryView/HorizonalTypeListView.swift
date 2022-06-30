import SwiftUI
import UIKit
import Combine

struct HorizonalTypeListView: View {
    @StateObject var viewModel: HorizonalTypeListViewModel

    var body: some View {
        AnytypeDivider()
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(viewModel.items) { item in
                    Button {
                        item.action()
                    } label: {
                        TypeView(image: item.image, title: item.title)
                    }
                    .frame(width: 80, height: 90)
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct TypeView: View {
    let image: ObjectIconImage
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            imageView
            AnytypeText(title, style: .caption2Regular, color: .textSecondary)
                .lineLimit(1)
        }
        .padding(EdgeInsets(top: 16, leading: 0, bottom: 13, trailing: 0))
    }

    private var imageView: some View {
        SwiftUIObjectIconImageView(
            iconImage: image,
            usecase: .editorAccessorySearch
        ).frame(width: 48, height: 48)
    }
}

struct HorizonalTypeListView_Previews: PreviewProvider {
    private final class ItemProvider: TypeListItemProvider {
        var typesPublisher: AnyPublisher<[HorizonalTypeListViewModel.Item], Never> {
            $items.eraseToAnyPublisher()
        }

        @Published var items: [HorizonalTypeListViewModel.Item] =
        [HorizonalTypeListViewModel.Item.searchItem {}]
    }

    static var previews: some View {
        HorizonalTypeListView(
            viewModel: .init(itemProvider: ItemProvider(), searchHandler: {})
        )
        .previewLayout(.fixed(width: 300, height: 96))
    }
}
