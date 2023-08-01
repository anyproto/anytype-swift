import SwiftUI
import UIKit
import Combine

struct HorizonalTypeListView: View {
    @StateObject var viewModel: HorizonalTypeListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 28) {
                ForEach(viewModel.items) { item in
                    Button {
                        item.action()
                    } label: {
                        TypeView(image: item.image, title: item.title)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 96)
        .ignoresSafeArea()
    }
}

private struct TypeView: View {
    let image: Icon
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            imageView
            Spacer.fixedHeight(14)
        }
        .overlay(
            AnytypeText(title, style: .caption2Regular, color: .Text.secondary)
                .lineLimit(1)
                .padding(.horizontal, -9), // Max width 70
            alignment: .bottom
        )
        .fixTappableArea()
    }

    private var imageView: some View {
        IconView(icon: image)
            .frame(width: 52, height: 52)
    }
}

struct HorizonalTypeListView_Previews: PreviewProvider {
    private final class ItemProvider: TypeListItemProvider {
        var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
            $items.eraseToAnyPublisher()
        }

        @Published var items: [HorizontalListItem] =
        [HorizontalListItem.searchItem {}]
    }

    static var previews: some View {
        HorizonalTypeListView(
            viewModel: .init(itemProvider: ItemProvider())
        )
        .previewLayout(.fixed(width: 300, height: 96))
    }
}
