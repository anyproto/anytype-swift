import SwiftUI
import UIKit
import Combine

protocol ChangeTypeItemProvider: AnyObject {
    var typesPublisher: Published<[ChangeTypeAccessoryItemViewModel.Item]>.Publisher { get }
}

protocol ChangeTypeAccessoryDelegate: AnyObject {
    func didTapOnSearch()
}

final class ChangeTypeAccessoryItemViewModel: ObservableObject {
    struct Item: Identifiable {
        let id: String
        let title: String
        let image: ObjectIconImage
        let action: () -> Void
    }

    @Published var items = [Item]()

    weak var delegate: ChangeTypeAccessoryDelegate?
    private var cancellables = [AnyCancellable]()

    init(itemProvider: ChangeTypeItemProvider) {
        itemProvider.typesPublisher.sink { [weak self] types in
            guard let self = self else { return }

            self.items = [self.searchItem] + types
        }.store(in: &cancellables)
    }

    private lazy var searchItem = Item.searchItem { [weak self] in self?.delegate?.didTapOnSearch() }
}

extension ChangeTypeAccessoryItemViewModel.Item {
    static func searchItem(onTap: @escaping () -> Void) -> Self {
        let image = UIImage.editorNavigation.search.image(
            imageSize: .init(width: 20, height: 20),
            cornerRadius: 12,
            side: 48,
            backgroundColor: .grayscale10
        )

        return .init(
            id: "Search",
            title: "Search".localized,
            image: ObjectIconImage.image(image),
            action: onTap
        )
    }
}

struct ChangeTypeAccessoryView: View {
    let viewModel: ChangeTypeAccessoryItemViewModel

    var body: some View {
        Divider()
            .frame(height: 0.5)
            .foregroundColor(Color.grayscale30)
        ScrollView(.horizontal) {
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
    }
}

private struct TypeView: View {
    let image: ObjectIconImage
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            imageView
            AnytypeText(title, style: .caption2Regular, color: .textSecondary)
        }
    }

    private var imageView: some View {
        SwiftUIObjectIconImageView(
            iconImage: image,
            usecase: .editorAccessorySearch
        ).frame(width: 48, height: 48)
    }
}

struct ChangeTypeAccessoryView_Previews: PreviewProvider {
    private final class ItemProvider: ChangeTypeItemProvider {
        var typesPublisher: Published<[ChangeTypeAccessoryItemViewModel.Item]>.Publisher {
            $items
        }

        @Published var items: [ChangeTypeAccessoryItemViewModel.Item] =
        [ChangeTypeAccessoryItemViewModel.Item.searchItem {}]
    }

    static var previews: some View {
        ChangeTypeAccessoryView(
            viewModel: .init(itemProvider: ItemProvider())
        )
        .previewLayout(.fixed(width: 300, height: 96))
    }
}
//
//extension ChangeTypeAccessoryItemViewModel {
//    static var searchItem: Self {
//        .init(id: "1", title: "Search", image: Image.main.search, action: {})
//    }
//
//
//    static var draftItem: Self {
//        .init(id: "2", title: "Draft", image: Image.main.search, action: {})
//    }
//}

final class ChangeButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        setTitle("Change type".localized, for: .normal)
        setImage(.codeBlock.arrow, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .bodyRegular
        setTitleColor(.grayscale50, for: .normal)
        imageEdgeInsets = .init(top: 0, left: -9, bottom: 0, right: 0)
    }

    override var isSelected: Bool {
        didSet {
            guard let transform = imageView?.transform.rotated(by: Double.pi) else {
                return
            }

            UIView.animate(withDuration: 0.4) {
                self.imageView?.transform = transform
            }
        }
    }
}
