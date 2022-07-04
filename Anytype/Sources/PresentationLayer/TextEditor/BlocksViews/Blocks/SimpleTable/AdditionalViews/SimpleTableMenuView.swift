import SwiftUI
import Combine

enum SimpleTableCellMenuItem: CaseIterable {
    case clearContents
    case color
    case style
    case clearStyle
}

enum SimpleTableColumnMenuItem: CaseIterable {
    case insertLeft
    case insertRight
    case moveLeft
    case moveRight
    case duplicate
    case delete
    case clearContents
    case sort
    case color
    case style
}

enum SimpleTableRowMenuItem: CaseIterable {
    case insertAbove
    case insertBelow
    case moveUp
    case moveDown
    case duplicate
    case delete
    case clearContents
    case color
    case style
}

final class SimpleTablesMenuItemsProvider: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizonalTypeListViewModel.Item], Never> { $items.eraseToAnyPublisher() }
    @Published private var items = [HorizonalTypeListViewModel.Item]()

    private var selectedIndexPaths = [IndexPath]()

    func didSelectTab(tab: SimpleTableMenuView.Tab) {
        switch tab {
        case .cell:
            self.items = SimpleTableCellMenuItem.allCases.map {
                HorizonalTypeListViewModel.Item.init(
                    id: "\($0.hashValue)",
                    title: <#T##String#>,
                    image: <#T##ObjectIconImage#>,
                    action: <#T##() -> Void#>
                )
            }
        case .row:

        case .column:

        }
    }

    func didChangeSelectedIndexPaths(indexPaths: [IndexPath]) {
        self.selectedIndexPaths = indexPaths
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

    @State private var index: Int = 0
    let horizontalList: HorizonalTypeListView

    var body: some View {
        VStack {
            tabHeaders
            horizontalList
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
                horizontalList.viewModel
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
