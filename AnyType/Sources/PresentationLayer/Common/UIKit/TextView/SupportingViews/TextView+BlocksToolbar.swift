//
//  TextView+BlocksToolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 15.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

// MARK: Style
extension TextView.BlockToolbar {
    enum Style {
        static let `default`: Self = .presentation
        case presentation
        func backgroundColor() -> UIColor {
            switch self {
            case .presentation: return .init(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) // #F3F2EC
            }
        }
    }
}

// MARK: BlockTypes
extension TextView.BlockToolbar {
    enum BlocksTypes: CaseIterable {
        static let typesPath = "TextEditor/Toolbar/Blocks/Types/"
        static func resolvedPath(_ subpath: String) -> String {
            typesPath + subpath
        }
        static var allCases: [Self] = [.text(.text), .list(.bulleted), .media(.bookmark), .tool(.contact), .other(.divider)]

        case text(Text), list(List), media(Media), tool(Tool), other(Other)

        enum Text: CaseIterable {
            case text, h1, h2, h3, highlighted
            func path() -> String {
                switch self {
                case .text: return BlocksTypes.resolvedPath("Text/Text")
                case .h1: return BlocksTypes.resolvedPath("Text/H1")
                case .h2: return BlocksTypes.resolvedPath("Text/H2")
                case .h3: return BlocksTypes.resolvedPath("Text/H3")
                case .highlighted: return BlocksTypes.resolvedPath("Text/Highlighted")
                }
            }
            func title() -> String {
                return self.path().components(separatedBy: "/").last ?? ""
            }
            static var allCases: [Self] = [.text, .h1, .h2, .h3, .highlighted]
        }

        enum List: CaseIterable {
            case bulleted, checkbox, numbered, toggle
            func path() -> String {
                switch self {
                case .bulleted: return BlocksTypes.resolvedPath("List/Bulleted")
                case .checkbox: return BlocksTypes.resolvedPath("List/Checkbox")
                case .numbered: return BlocksTypes.resolvedPath("List/Numbered")
                case .toggle: return BlocksTypes.resolvedPath("List/Toggle")
                }
            }
            func title() -> String {
                return self.path().components(separatedBy: "/").last ?? ""
            }
            static var allCases: [Self] = [.bulleted, .checkbox, .numbered, .toggle]
        }

        enum Media: CaseIterable {
            case bookmark, code, file, picture, video
            func path() -> String {
                switch self {
                case .bookmark: return BlocksTypes.resolvedPath("Media/Bookmark")
                case .code: return BlocksTypes.resolvedPath("Media/Code")
                case .file: return BlocksTypes.resolvedPath("Media/File")
                case .picture: return BlocksTypes.resolvedPath("Media/Picture")
                case .video: return BlocksTypes.resolvedPath("Media/Video")
                }
            }
            func title() -> String {
                return self.path().components(separatedBy: "/").last ?? ""
            }
            static var allCases: [Self] = [.bookmark, .code, .file, .picture, .video]
        }

        enum Tool: CaseIterable {
            case contact, database, existingTool, set, page, task
            func path() -> String {
                switch self {
                case .contact: return BlocksTypes.resolvedPath("Tool/Contact")
                case .database: return BlocksTypes.resolvedPath("Tool/Database")
                case .existingTool: return BlocksTypes.resolvedPath("Tool/ExistingTool")
                case .set: return BlocksTypes.resolvedPath("Tool/Set")
                case .page: return BlocksTypes.resolvedPath("Tool/Page")
                case .task: return BlocksTypes.resolvedPath("Tool/Task")
                }
            }
            func title() -> String {
                return self.path().components(separatedBy: "/").last ?? ""
            }
            static var allCases: [Self] = [.contact, .database, .existingTool, .set, .page, .task]
        }

        enum Other: CaseIterable {
            static var allCases: [Self] = [.divider]

            case divider

            func path() -> String {
                switch self {
                case .divider: return BlocksTypes.resolvedPath("Other/Divider")
                }
            }

            func title() -> String {
                return self.path().components(separatedBy: "/").last ?? ""
            }
        }

        func title() -> String {
            switch self {
            case .text: return "Text"
            case .list: return "List"
            case .media: return "Media"
            case .tool: return "Tool"
            case .other: return "Other"
            }
        }
    }

    class BlockTypesColors {
        static let path = "TextEditor/Toolbar/Blocks/Types/TypesColors/"
        static func color(for type: BlocksTypes) -> UIColor {
            switch type {
            case .text: return UIColor.init(named: path + "Text") ?? .clear
            case .list: return UIColor.init(named: path + "List") ?? .clear
            case .media: return UIColor.init(named: path + "Media") ?? .clear
            case .tool: return UIColor.init(named: path + "Tool") ?? .clear
            case .other: return UIColor.init(named: path + "Other") ?? .clear
            }
        }
    }
}

// MARK: ViewModifiers
extension TextView.BlockToolbar {
    struct RoundedButtonViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(20).background(Color.white).cornerRadius(10)
        }
    }
    struct OuterHorizontalStackViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                VStack {
                    content
                    Spacer(minLength: 10)
                }
            }.padding(16)
        }
    }
    struct HorizontalStackViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack(alignment: .center, spacing: 5) {
                content
            }
        }
    }
}

// MARK: TurnInto
extension TextView.BlockToolbar {
    enum TurnIntoBlock {}
}

extension TextView.BlockToolbar.TurnIntoBlock {
    typealias BlocksTypes = TextView.BlockToolbar.BlocksTypes
    typealias Style = TextView.BlockToolbar.Style
    class ViewModel: TextView.BlockToolbar.AddBlock.ViewModel {
        override init() {
            super.init()
            self.title = "Turn Into"
            self.categories = self.categories.filter {
                switch $0 {
                case .text: return true
                case .list: return true
                case .tool: return true
                case .media: return false
                case .other: return false
                }
            }
        }
    }
    class InputViewBuilder {
        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let controller = UIHostingController(rootView: InputView(title: viewModel.wrappedValue.title, model: viewModel.wrappedValue, categories: viewModel.wrappedValue.categories, categoryIndex: viewModel.projectedValue.categoryIndex, typeIndex: viewModel.projectedValue.typeIndex))
            let view = controller.view
            view?.backgroundColor = Style.default.backgroundColor()
            return view
        }
    }
    struct InputView: View {
        var title: String
        @ObservedObject var model: ViewModel
        var categories: [BlocksTypes] = []
        @Binding var categoryIndex: Int?
        @Binding var typeIndex: Int?
        
        var body: some View {
            TextView.BlockToolbar.AddBlock.InputView(title: self.title, model: self.model, categories: self.categories, categoryIndex: self.$categoryIndex, typeIndex: self.$typeIndex)
        }
    }
}

// MARK: AddBlock
extension TextView.BlockToolbar {
    enum AddBlock {}
}

extension TextView.BlockToolbar.AddBlock {
    typealias BlockTypesColors = TextView.BlockToolbar.BlockTypesColors
    typealias BlocksTypes = TextView.BlockToolbar.BlocksTypes
    typealias Style = TextView.BlockToolbar.Style
    class ViewModel: ObservableObject {
        struct ChosenType: Identifiable, Equatable {
            var title: String
            var image: String
            var id: String {
                return title
            }
        }
        @Published var categoryIndex: Int? = 0
        @Published var typeIndex: Int?
        var value: AnyPublisher<BlocksTypes?, Never> = .empty()
        var types: [ChosenType] {
            return self.chosenTypes(category: self.categoryIndex)
        }
        var title = "Add Block"
        var categories = BlocksTypes.allCases
        func chosenTypes(category: Int?) -> [ChosenType] {
            guard let value = category else { return [] }
            switch self.categories[value] {
            case .text: return BlocksTypes.Text.allCases.compactMap{($0.title(), $0.path())}.map{ChosenType(title: $0.0, image: $0.1)}
            case .list: return BlocksTypes.List.allCases.compactMap{($0.title(), $0.path())}.map{ChosenType(title: $0.0, image: $0.1)}
            case .media: return BlocksTypes.Media.allCases.compactMap{($0.title(), $0.path())}.map{ChosenType(title: $0.0, image: $0.1)}
            case .tool: return BlocksTypes.Tool.allCases.compactMap{($0.title(), $0.path())}.map{ChosenType(title: $0.0, image: $0.1)}
            case .other: return BlocksTypes.Other.allCases.compactMap{($0.title(), $0.path())}.map{ChosenType(title: $0.0, image: $0.1)}
            }
        }
        func chosenAction(category: Int?, type: Int?) -> BlocksTypes? {
            guard let category = category, let type = type else { return nil }
            switch self.categories[category] {
            case .text: return .text(BlocksTypes.Text.allCases[type])
            case .list: return .list(BlocksTypes.List.allCases[type])
            case .media: return .media(BlocksTypes.Media.allCases[type])
            case .tool: return .tool(BlocksTypes.Tool.allCases[type])
            case .other: return .other(BlocksTypes.Other.allCases[type])
            }
        }
        init() {
            self.value = self.$typeIndex.map { [weak self] value in
                let category = self?.categoryIndex
                let type = value
                return self?.chosenAction(category: category, type: type)
            }.eraseToAnyPublisher()
        }
    }
    class InputViewBuilder {
        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let controller = UIHostingController(rootView: InputView(title: viewModel.wrappedValue.title, model: viewModel.wrappedValue, categories: viewModel.wrappedValue.categories, categoryIndex: viewModel.projectedValue.categoryIndex, typeIndex: viewModel.projectedValue.typeIndex))
            let view = controller.view
            view?.backgroundColor = Style.default.backgroundColor()
            return view
        }
    }
    struct InputView: View {
        var title: String
        @ObservedObject var model: ViewModel
        var categories: [BlocksTypes] = []
        @Binding var categoryIndex: Int?
        @Binding var typeIndex: Int?
        func types() -> [(Int, ViewModel.ChosenType)] {
            let values = self._model.wrappedValue.chosenTypes(category: self.$categoryIndex.wrappedValue)
            return Array(values.enumerated())
        }
        func typesSelected() -> Bool {
            self.categoryIndex != nil
        }
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                AnytypeText(self.title, style: .bodySemibold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(0..<self.categories.count) { i in
                            Button(action: {
                                self.categoryIndex = i
                            }) {
                                AnytypeText(self.categories[i].title(), style: .headlineSemibold)
                                    .foregroundColor(self.categoryIndex == i ? .white : .textPrimary)
                            }.padding(.vertical, 5).padding(.horizontal, 15).background(self.categoryIndex == i ? Color(BlockTypesColors.color(for: self.categories[i])) : .white).cornerRadius(15)
                        }
                    }
                }
                if self.typesSelected() {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 8) {
                            ForEach(self.types(), id: \.1.id) { i in
                                Button(action: {
                                    self.typeIndex = i.0
                                }) {
                                    VStack(spacing: 2) {
                                        Image(i.1.image).renderingMode(.template).foregroundColor(Color(BlockTypesColors.color(for: self.categories[self.categoryIndex ?? 0]))).modifier(TextView.BlockToolbar.RoundedButtonViewModifier())
                                        AnytypeText(i.1.title, style: .caption).foregroundColor(.textPrimary)
                                    }
                                }
                            }
                        }
                    }
                }
            }.modifier(TextView.BlockToolbar.OuterHorizontalStackViewModifier())
        }
    }
}

// MARK: ChangeColor
extension TextView.BlockToolbar {
    enum ChangeColor {}
}

extension TextView.BlockToolbar.ChangeColor {
    typealias Style = TextView.BlockToolbar.Style
    enum Colors {
        case black, grey, yellow, orange, red, magenta, purple, ultramarine, lightBlue, teal, green
        func color(highlighted: Bool = false) -> UIColor {
            switch self {
            case .black: return highlighted ? .clear : .grayscale90
            case .grey: return highlighted ? #colorLiteral(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) : #colorLiteral(red: 0.6745098039, green: 0.662745098, blue: 0.5882352941, alpha: 1) // #ACA996
            case .yellow: return highlighted ? #colorLiteral(red: 0.996, green: 0.976, blue: 0.8, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.8509803922, blue: 0.1058823529, alpha: 1) // #ECD91B
            case .orange: return highlighted ? #colorLiteral(red: 0.996, green: 0.953, blue: 0.773, alpha: 1) : #colorLiteral(red: 1, green: 0.7098039216, blue: 0.1333333333, alpha: 1) // #FFB522
            case .red: return highlighted ? #colorLiteral(red: 1, green: 0.922, blue: 0.898, alpha: 1) : #colorLiteral(red: 0.9607843137, green: 0.3333333333, blue: 0.1333333333, alpha: 1) // #F55522
            case .magenta: return highlighted ? #colorLiteral(red: 0.996, green: 0.89, blue: 0.961, alpha: 1) : #colorLiteral(red: 0.8980392157, green: 0.1098039216, blue: 0.6274509804, alpha: 1) // #E51CA0
            case .purple: return highlighted ? #colorLiteral(red: 0.957, green: 0.891, blue: 0.98, alpha: 1) : #colorLiteral(red: 0.6705882353, green: 0.3137254902, blue: 0.8, alpha: 1) // #AB50CC
            case .ultramarine: return highlighted ? #colorLiteral(red: 0.894, green: 0.906, blue: 0.988, alpha: 1) : #colorLiteral(red: 0.2431372549, green: 0.3450980392, blue: 0.9215686275, alpha: 1) // #3E58EB
            case .lightBlue: return highlighted ? #colorLiteral(red: 0.84, green: 0.937, blue: 0.992, alpha: 1) : #colorLiteral(red: 0.1647058824, green: 0.6549019608, blue: 0.9333333333, alpha: 1) // #2AA7EE
            case .teal: return highlighted ? #colorLiteral(red: 0.839, green: 0.961, blue: 0.953, alpha: 1) : #colorLiteral(red: 0.05882352941, green: 0.7843137255, blue: 0.7294117647, alpha: 1) // #0FC8BA
            case .green: return highlighted ? #colorLiteral(red: 0.89, green: 0.969, blue: 0.816, alpha: 1) :  #colorLiteral(red: 0.3647058824, green: 0.831372549, blue: 0, alpha: 1) // #5DD400
            }
        }
        static var colors: [Colors] = [.black, .grey, .yellow, .orange, .red, .magenta, .purple, .ultramarine, .lightBlue, .teal, .green]
    }
    class ViewModel: ObservableObject {
        struct InnerStorage {
            var textColor: UIColor?
            var backgroundColor: UIColor?
        }
        @Published var value: InnerStorage = .init()
        var colors: [Colors] = Colors.colors
    }
    class InputViewBuilder {
        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let controller = UIHostingController(rootView: InputView(colors: viewModel.wrappedValue.colors, textColor: viewModel.projectedValue.value.textColor, backgroundColor: viewModel.projectedValue.value.backgroundColor))
            let view = controller.view
            view?.backgroundColor = Style.default.backgroundColor()
            return view
        }
    }
    struct InputView: View {
        var colors: [Colors]
        @Binding var textColor: UIColor?
        @Binding var backgroundColor: UIColor?
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                AnytypeText("Text Color", style: .bodySemibold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(0..<self.colors.count) { i in
                            Button(action: {
                                self.textColor = self.colors[i].color()
                            }) {
                                AnytypeText("Aa", style: .headlineSemibold)
                                    .foregroundColor(Color(self.colors[i].color()))
                            }.modifier(TextView.BlockToolbar.RoundedButtonViewModifier())
                        }
                    }
                }
                AnytypeText("Highlight Color", style: .bodySemibold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(0..<self.colors.count) { i in
                            Button(action: {
                                self.backgroundColor = self.colors[i].color(highlighted: true)
                            }) {
                                AnytypeText("Aa", style: .headlineSemibold)
                                    .background(Color(self.colors[i].color(highlighted: true)))
                                    .foregroundColor(.textPrimary)
                            }.modifier(TextView.BlockToolbar.RoundedButtonViewModifier())
                        }
                    }
                }
            }.modifier(TextView.BlockToolbar.OuterHorizontalStackViewModifier())
        }
    }
}

// MARK: EditActions
extension TextView.BlockToolbar {
    enum EditActions {}
}

// MARK: EditActions / Actions
extension TextView.BlockToolbar.EditActions {
    enum Action: CaseIterable {
        case delete, duplicate, undo ,redo
        func path() -> String {
            switch self {
            case .delete: return "TextEditor/Toolbar/Blocks/Actions/Delete"
            case .duplicate: return "TextEditor/Toolbar/Blocks/Actions/Duplicate"
            case .undo: return "TextEditor/Toolbar/Blocks/Actions/Undo"
            case .redo: return "TextEditor/Toolbar/Blocks/Actions/Redo"
            }
        }
        func title() -> String {
            return self.path().components(separatedBy: "/").last ?? ""
        }
        static var allCases: [Self] = [.delete, .duplicate, .undo, .redo]
    }
}

// MARK: EditActions / ViewModel
extension TextView.BlockToolbar.EditActions {
    typealias Style = TextView.BlockToolbar.Style
    class ViewModel: ObservableObject {
        @Published var value: Action?
        var actions = Action.allCases
    }
    class InputViewBuilder {
        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let controller = UIHostingController(rootView: InputView(actions: viewModel.wrappedValue.actions, action: viewModel.projectedValue.value))
            let view = controller.view
            view?.backgroundColor = Style.default.backgroundColor()
            return view
        }
    }
    struct InputView: View {
        var actions: [Action] = []
        @Binding var action: Action?
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                AnytypeText("Block actions", style: .bodySemibold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(0..<self.actions.count) { i in
                            Button(action: {
                                self.action = self.actions[i]
                            }) {
                                VStack(spacing: 2) {
                                    Image(self.actions[i].path())
                                        .renderingMode(.template)
                                        .foregroundColor(.black)
                                        .modifier(TextView.BlockToolbar.RoundedButtonViewModifier())
                                    AnytypeText(self.actions[i].title(), style: .caption).foregroundColor(.textPrimary)
                                }
                            }
                        }
                    }
                }
            }.modifier(TextView.BlockToolbar.OuterHorizontalStackViewModifier())
        }
    }
}
