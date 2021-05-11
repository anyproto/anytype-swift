import Foundation
import SwiftUI
import Combine
import os


extension BlocksViews.Toolbar {
    enum AddBlock {
        typealias BlocksTypes = BlocksViews.Toolbar.BlocksTypes
    }
}

// MARK: InputViewBuilder
extension BlocksViews.Toolbar.AddBlock {
    enum InputViewBuilder {
        static func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let inputView = InputView(
                model: viewModel.wrappedValue,
                categoryIndex: viewModel.projectedValue.categoryIndex,
                typeIndex: viewModel.projectedValue.typeIndex,
                title: viewModel.wrappedValue.title,
                categories: viewModel.wrappedValue.categories
            )
            let controller = UIHostingController(rootView: inputView)
            let view = controller.view
            view?.backgroundColor = BlocksViews.Toolbar.Style.default.backgroundColor()
            return view
        }
    }
}

// MARK: View
extension BlocksViews.Toolbar.AddBlock {
    struct InputView: View {
        typealias Types = BlocksViews.Toolbar.BlocksTypes
        typealias TypesColor = Types.Resources.Color

        private var safeCategoryIndex: Int { categoryIndex ?? 0 }

        @ObservedObject var model: ViewModel
        @Binding var categoryIndex: Int?
        @Binding var typeIndex: Int?

        var title: String
        var categories: [Types] = []
        var types: [(Int, ViewModel.ChosenType)] {
            let values = self._model.wrappedValue.chosenTypes(category: self.$categoryIndex.wrappedValue)
            return Array(values.enumerated())
        }

        func typesSelected() -> Bool {
            self.categoryIndex != nil
        }

        var body: some View {
            List {
                ForEach(self.categories.indices) { i in
                    /// NOTES:
                    /// Interesting bug.
                    /// Each cell should be identifiable by something.
                    /// As soon as we doesn't know about top-level index, we should provide an identifier.
                    /// If it doesn't happen, well, we are going wild.
                    /// Cell *may* be reused and you see a cell in incorrect category.
                    Category(viewModel: .init(title: self.categories[i].title), cells: self.model.cells(category: i))
                }
            }.onAppear {
                /// Thanks! https://stackoverflow.com/a/58474518
                // TODO: We should remove all appearances to global UIKit classes
                UITableView.appearance().tableFooterView = .init()
                UITableViewHeaderFooterView.appearance().tintColor = .clear
            }
        }
    }
}

// MARK: Category
extension BlocksViews.Toolbar.AddBlock {
    struct Category: View {
        var viewModel: ViewModel
        var cells: [Cell.ViewModel]
        var header: some View {
            HStack {
                AnytypeText(self.viewModel.uppercasedTitle, style: .headline)
                    .foregroundColor(Color(UIColor(red: 0.675, green: 0.663, blue: 0.588, alpha: 1)))
                    .padding()
                Spacer()
            }.background(Color.white).listRowInsets(.init(.init()))
        }
        var body: some View {
            Section(header: self.header) {
                ForEach(self.cells) { cell in
                    Cell(viewModel: cell)
                }
            }
        }
    }
}

// MARK: Cell
extension BlocksViews.Toolbar.AddBlock.Cell {
    enum ButtonColorScheme {
        case selected
        func backgroundColor() -> UIColor {
            .init(red: 0.165, green: 0.656, blue: 0.933, alpha: 1)
        }
    }

    struct SelectedButtonStyle: ButtonStyle {
        var pressedColor: UIColor
        func makeBody(configuration: Configuration) -> some View {
            configuration.label.background(configuration.isPressed ? Color(self.pressedColor) : Color.clear)
                .frame(minWidth: 1.0, idealWidth: nil, maxWidth: nil)
        }
    }
}

extension BlocksViews.Toolbar.AddBlock {
    struct Cell: View {
        var viewModel: ViewModel
        var view: some View {
            HStack {
                Image(self.viewModel.imageResource).renderingMode(.original)
                VStack(alignment: .leading) {
                    AnytypeText(self.viewModel.title, style: .heading)
                        .foregroundColor(Color(UIColor.grayscale90))
                    Spacer(minLength: 5)
                    AnytypeText(self.viewModel.subtitle, style: .caption)
                        .foregroundColor(Color(UIColor(red: 0.422, green: 0.415, blue: 0.372, alpha: 1)))
                }
            }
        }
        var body: some View {
            Button(action: {
                self.viewModel.pressed()
            }) {
                self.view
            }
        }
    }
}
