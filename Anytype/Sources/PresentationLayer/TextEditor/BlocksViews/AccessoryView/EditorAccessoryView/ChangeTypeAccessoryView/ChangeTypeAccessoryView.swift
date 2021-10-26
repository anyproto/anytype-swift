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
        let image: ObjectIconImage?
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
        .init(id: "Search", title: "Search".localized, image: ObjectIconImage.staticImage(""), action: onTap)
    }
}

struct ChangeTypeAccessoryView: View {
    let viewModel: ChangeTypeAccessoryItemViewModel

    var body: some View {
        Divider()
        ScrollView(.horizontal) {
            LazyHStack(spacing: 32) {
                ForEach(viewModel.items) {
                    TypeView(image: $0.image, title: $0.title)
                }
            }
            .padding(.init(top: 0, leading: 16, bottom: 14, trailing: 16))
        }
    }
}

private struct TypeView: View {
    let image: ObjectIconImage?
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            imageView
            AnytypeText(title, style: .caption2Regular, color: .textSecondary)
        }
    }

    private var imageView: some View {
        Group {
            if let image = image {
                SwiftUIObjectIconImageView(
                    iconImage: image,
                    usecase: .dashboardList
                )
                                .foregroundColor(Color.grayscale50)
                                .frame(width: 48, height: 48, alignment: .center)
                                .background(Color.grayscale10)
                                .cornerRadius(12)
            } else {
                Text("")
            }
        }
    }
}
//
//struct ChangeTypeAccessoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeTypeAccessoryView(
//            items: [ChangeTypeAccessoryItemViewModel.Item.searchItem {}]
//        )
//            .previewLayout(.fixed(width: 300, height: 96))
//    }
//}
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
        setTitle("Change type", for: .normal)
        setImage(.codeBlock.arrow, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .bodyRegular
        setTitleColor(.grayscale50, for: .normal)
        imageEdgeInsets = .init(top: 0, left: -7, bottom: 0, right: 0)
    }

    override var isSelected: Bool {
        didSet {
            guard let transform = imageView?.transform.rotated(by: Double.pi) else {
                return
            }

            UIView.animate(withDuration: 0.2) {
                self.imageView?.transform = transform
            }
        }
    }
}
