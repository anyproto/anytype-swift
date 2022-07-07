import SwiftUI
import Combine

final class SimpleTableMenuViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> { $items.eraseToAnyPublisher() }
    @Published var items = [HorizontalListItem]()

    private var selectedIndexPaths = [IndexPath]()

    weak var delegate: SimpleTableMenuDelegate?

    func didSelectTab(tab: SimpleTableMenuView.Tab) {
        delegate?.didSelectTab(tab: tab)
    }
}

struct SimpleTableMenuView: View {
    enum Tab: Int {
        case cell
        case column
        case row

        var title: String {
            switch self {
            case .cell:
                return "Cell"
            case .column:
                return "Column"
            case .row:
                return "Row"
            }
        }
    }

    let viewModel: SimpleTableMenuViewModel
    @State private var index: Int = 0

    var body: some View {
        VStack {
            tabHeaders

        }
    }

    private var tabHeaders: some View {
        HStack {
            tabHeaderButton(.cell)
            tabHeaderButton(.column)
            tabHeaderButton(.row)
        }
        .frame(height: 48)
    }

    private func tabHeaderButton(_ tab: Tab) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                viewModel.didSelectTab(tab: tab)
                index = tab.rawValue
            }
        } label: {
            AnytypeText(
                tab.title,
                style: .uxBodyRegular,
                color: index == tab.rawValue ? Color.buttonSelected : Color.buttonActive
            )
        }
        .frame(maxWidth: .infinity)
    }
}
