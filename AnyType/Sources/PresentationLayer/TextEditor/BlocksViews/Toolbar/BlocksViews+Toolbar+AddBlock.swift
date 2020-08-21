//
//  BlocksViews+Toolbar+AddBlock.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

private extension Logging.Categories {
    static let blocksViewsToolbarAddBlock: Self = "BlocksViews.Toolbar.AddBlock"
}

// MARK: AddBlock
extension BlocksViews.Toolbar {
    enum AddBlock {
        typealias BlocksTypes = BlocksViews.Toolbar.BlocksTypes
    }
}

// MARK: InputViewBuilder
extension BlocksViews.Toolbar.AddBlock {
    enum InputViewBuilder {
        static func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let controller = UIHostingController(rootView: InputView(title: viewModel.wrappedValue.title, model: viewModel.wrappedValue, categories: viewModel.wrappedValue.categories, categoryIndex: viewModel.projectedValue.categoryIndex, typeIndex: viewModel.projectedValue.typeIndex))
            let view = controller.view
            view?.backgroundColor = BlocksViews.Toolbar.Style.default.backgroundColor()
            return view
        }
    }
}

// MARK: Style
extension BlocksViews.Toolbar.AddBlock {
    enum Style {
        func fontSize() -> CGFloat {
            switch self {
            case .title: return 17
            case .subtitle: return 13
            case .section: return 0
            }
        }
        case title, subtitle, section
        func font() -> UIFont {
            switch self {
            case .title: return .systemFont(ofSize: self.fontSize())
            case .subtitle: return .systemFont(ofSize: self.fontSize())
            case .section: return .preferredFont(forTextStyle: .headline)
            }
        }
        func coreTextFont() -> CTFont {
            self.font() as CTFont
        }
        func foregroundColor() -> UIColor {
            switch self {
            case .title: return .black
            case .subtitle: return .init(red: 0.422, green: 0.415, blue: 0.372, alpha: 1)
            case .section: return .init(red: 0.675, green: 0.663, blue: 0.588, alpha: 1)
            }
        }
        func backgroundColor() -> UIColor {
            .white
        }
    }
}

// MARK: View
extension BlocksViews.Toolbar.AddBlock {
    struct InputView: View {
        typealias Types = BlocksViews.Toolbar.BlocksTypes
        typealias TypesColor = Types.Resources.Color
        var title: String
        @ObservedObject var model: ViewModel
        var categories: [Types] = []
        @Binding var categoryIndex: Int?
        @Binding var typeIndex: Int?
        private var safeCategoryIndex: Int { categoryIndex ?? 0 }
        var types: [(Int, ViewModel.ChosenType)] {
            let values = self._model.wrappedValue.chosenTypes(category: self.$categoryIndex.wrappedValue)
            return Array(values.enumerated())
        }

        func typesSelected() -> Bool {
            self.categoryIndex != nil
        }

        var oldBody: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text(self.title).fontWeight(.semibold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(self.categories.indices) { i in
                            Button(action: {
                                self.categoryIndex = i
                            }) {
                                Text(self.categories[i].title).font(.subheadline).fontWeight(.semibold).foregroundColor(self.categoryIndex == i ? .white : .black)
                            }.padding(.vertical, 5).padding(.horizontal, 15).background(self.categoryIndex == i ? Color(TypesColor.color(for: self.categories[i])) : .white).cornerRadius(15)
                        }
                    }
                }
                if self.typesSelected() {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 8) {
                            ForEach(self.types, id: \.1.id) { i in
                                Button(action: {
                                    self.typeIndex = i.0
                                }) {
                                    VStack(spacing: 2) {
                                        Image(i.1.image).renderingMode(.template).foregroundColor(Color(TypesColor.color(for: self.categories[self.safeCategoryIndex]))).modifier(BlocksViews.Toolbar.RoundedButtonViewModifier())
                                        Text(i.1.title).font(.caption).foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                }
            }.modifier(BlocksViews.Toolbar.OuterHorizontalStackViewModifier())
        }

        var newBody: some View {
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
                let logger = Logging.createLogger(category: .todo(.workaround(.os14, "Fix it.")))
                os_log(.debug, log: logger, "We should remove all appearances to global UIKit classes.")
                UITableView.appearance().tableFooterView = .init()
                UITableViewHeaderFooterView.appearance().tintColor = .clear
            }
        }

        var body: some View {
            newBody
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
                Text(self.viewModel.uppercasedTitle)
                    .font(.init(Style.section.coreTextFont()))
                    .foregroundColor(.init(Style.section.foregroundColor()))
                    .padding()
                Spacer()
            }.background(Color(Style.section.backgroundColor())).listRowInsets(.init(.init()))
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
                    Text(self.viewModel.title).font(.init(Style.title.coreTextFont())).foregroundColor(.init(Style.title.foregroundColor()))
                    Spacer(minLength: 5)
                    Text(self.viewModel.subtitle).font(.init(Style.subtitle.coreTextFont())).foregroundColor(.init(Style.subtitle.foregroundColor()))
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
