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
        case title, subtitle, section
        func font() -> UIFont {
            switch self {
            case .title: return .preferredFont(forTextStyle: .title2)
            case .subtitle: return .preferredFont(forTextStyle: .caption1)
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
                    Category(viewModel: .init(title: self.categories[i].title), cells: self.model.cells(category: i))
                }
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
        var body: some View {
            Section(header: Text(self.viewModel.uppercasedTitle).font(.init(Style.section.coreTextFont())).foregroundColor(.init(Style.section.foregroundColor()))) {
                ForEach(self.cells.indices) { i in
                    Cell(viewModel: self.cells[i])
                }
            }
        }
    }
}

// MARK: Cell
extension BlocksViews.Toolbar.AddBlock {
    struct Cell: View {
        var viewModel: ViewModel
        var body: some View {
            HStack {
                Image(self.viewModel.imageResource)
                VStack(alignment: .leading) {
                    Text(self.viewModel.title).font(.init(Style.title.coreTextFont())).foregroundColor(.init(Style.title.foregroundColor()))
                    Spacer(minLength: 5)
                    Text(self.viewModel.subtitle).font(.init(Style.subtitle.coreTextFont())).foregroundColor(.init(Style.subtitle.foregroundColor()))
                }
            }
        }
    }
}
