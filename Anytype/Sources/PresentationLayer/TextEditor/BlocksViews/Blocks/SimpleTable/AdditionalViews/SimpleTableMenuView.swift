import SwiftUI
import Combine

struct SimpleTableMenuModel {
    struct TabModel: Identifiable {
        let id: Int
        let title: String
        let isSelected: Bool
        let action: () -> Void
    }

    let tabs: [TabModel]
    let items: [SelectionOptionsItemViewModel]
    let onDone: () -> Void
}

final class SimpleTableMenuViewModel: ObservableObject, OptionsItemProvider {
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { $items.eraseToAnyPublisher() }
    @Published var items = [SelectionOptionsItemViewModel]()
    @Published var tabModels = [SimpleTableMenuModel.TabModel]()

    func update(with model: SimpleTableMenuModel) {
        withAnimation(nil) {
            self.items = model.items
            self.tabModels = model.tabs
        }
    }
}

struct SimpleTableMenuView: View {
    enum Tab: Int, CaseIterable {
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
            SelectionOptionsView(viewModel: .init(itemProvider: viewModel))
        }
        .background(Color.Background.secondary)
    }

    private var tabHeaders: some View {
        HStack(alignment: .center, spacing: 17) {
            ForEach(viewModel.tabModels) { item in
                tabHeaderButton(item: item)
            }

        }.frame(height: 24, alignment: .center)
    }

    private func tabHeaderButton(item: SimpleTableMenuModel.TabModel) -> some View {
        Button {
            guard !item.isSelected else { return }
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                item.action()
            }
        } label: {
            AnytypeText(
                item.title,
                style: .subheading
            )
            .foregroundColor(item.isSelected ? Color.Control.primary : Color.Control.secondary)
        }
    }
}
