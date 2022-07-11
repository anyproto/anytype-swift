import SwiftUI
import Combine

final class SimpleTableMenuViewModel: ObservableObject, TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> { $items.eraseToAnyPublisher() }
    @Published var items = [HorizontalListItem]()
    @Published var index: Int = 0

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

    @ObservedObject var viewModel: SimpleTableMenuViewModel

    var body: some View {
        VStack {
            Spacer.fixedHeight(17)
            tabHeaders
            HorizonalTypeListView(viewModel: .init(itemProvider: viewModel))
        }
    }

    private var tabHeaders: some View {
        HStack(alignment: .center, spacing: 17) {
            tabHeaderButton(.cell)
            tabHeaderButton(.column)
            tabHeaderButton(.row)
        }.frame(height: 24, alignment: .center)
    }

    private func tabHeaderButton(_ tab: Tab) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                viewModel.didSelectTab(tab: tab)
                viewModel.index = tab.rawValue
            }
        } label: {
            AnytypeText(
                tab.title,
                style: .subheading,
                color: viewModel.index == tab.rawValue ? Color.buttonSelected : Color.buttonActive
            )
        }
    }
}
