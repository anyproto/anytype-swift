//
//  MarksPane+Main+Section.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: Section
extension MarksPane.Main {
    enum Section {}
}

// MARK: Section / Category
extension MarksPane.Main.Section {
    enum Category {
        case style
        case textColor
        case backgroundColor
        
        func title() -> String { Resources.Title.title(for: self) }
    }
    enum Resources {
        struct Title {
            static func title(for category: Category) -> String {
                switch category {
                case .style: return "Style"
                case .textColor: return "Color"
                case .backgroundColor: return "Background"
                }
            }
        }
    }
}

// MARK: Section / ViewModel
extension MarksPane.Main.Section {
    class ViewModel: ObservableObject {
        var chosenCategory: Category {
            get {
                self.availableCategories[self.chosenIndex]
            }
            set {
                self.chosenIndex = self.availableCategories.firstIndex(of: newValue) ?? 0
            }
        }
        @Published var chosenIndex: Int = 0
        var availableCategories: [Category] = [.style, .textColor, .backgroundColor]
    }
}

// MARK: Section / ViewModelBuilder
extension MarksPane.Main.Section {
    enum InputViewBuilder {
        static func createView(_ viewModel: ObservedObject<ViewModel>) -> some View {
            InputView.init(chosenIndex: viewModel.projectedValue.chosenIndex, categories: viewModel.wrappedValue.availableCategories, viewModel: viewModel.wrappedValue)
        }
    }
}

// MARK: Section / View
extension MarksPane.Main.Section {
    struct InputView: View {
        @Binding var chosenIndex: Int
        var categories: [Category]
        @ObservedObject var viewModel: ViewModel
        
        var layout: Layout = .init()
        var style: Style = .presentation
        
        var body: some View {
            VStack(alignment: .center) {
                HStack(alignment: .center, spacing: self.layout.horizontalSpacing) {
                    ForEach(0..<self.categories.count) { i in
                        Button(action: {
                            self.chosenIndex = i
                        }) {
                            Text(self.categories[i].title())
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(self.style.foregroundColor(chosen: self.chosenIndex == i)))
                        }
                        .padding(.vertical, self.layout.button.verticalPadding)
                        .padding(.horizontal, self.layout.button.horizontalPadding)
                        .background(Color(self.style.backgroundColor(chosen: self.chosenIndex == i)))
                        .cornerRadius(self.layout.button.cornerRadius)
                    }
                }
            }
        }
    }
}

extension MarksPane.Main.Section.InputView {
    struct Layout {
        struct Button {
            var verticalPadding: CGFloat = 5
            var horizontalPadding: CGFloat = 15
            var cornerRadius: CGFloat = 15
        }
        
        var horizontalSpacing: CGFloat = 8
        var button: Button = .init()
    }
}

extension MarksPane.Main.Section.InputView {
    enum Style {
        static func accentColor() -> UIColor {
            MarksPane.Style.default.accentColor()
        }
        case presentation
        func foregroundColor(chosen: Bool) -> UIColor {
            switch self {
            case .presentation: return chosen ? .white : .black
            }
        }
        func backgroundColor(chosen: Bool) -> UIColor {
            switch self {
            case .presentation: return chosen ? Style.accentColor() : .white
            }
        }
    }
}
