//
//  BlocksViews+Toolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

// MARK: Style
extension BlocksViews.Toolbar {
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

// MARK: ViewModifiers
extension BlocksViews.Toolbar {
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

/// WARNING: Do not delete commented code.
/// It contains various toolbars that we may use in future.
///

// MARK: TurnInto
//extension BlocksViews.Toolbar {
//    enum TurnIntoBlock {}
//}
//
//extension BlocksViews.Toolbar.TurnIntoBlock {
//    typealias BlocksTypes = BlocksViews.Toolbar.BlocksTypes
//    typealias Style = BlocksViews.Toolbar.Style
//    class ViewModel: BlocksViews.Toolbar.AddBlock.ViewModel {
//        override init() {
//            super.init()
//            self.title = "Turn Into"
//            self.categories = self.categories.filter {
//                switch $0 {
//                case .text: return true
//                case .list: return true
//                case .page: return true
//                case .tool: return true
//                case .media: return false
//                case .other: return false
//                }
//            }
//        }
//    }
//    class InputViewBuilder {
//        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
//            let controller = UIHostingController(rootView: InputView(title: viewModel.wrappedValue.title, model: viewModel.wrappedValue, categories: viewModel.wrappedValue.categories, categoryIndex: viewModel.projectedValue.categoryIndex, typeIndex: viewModel.projectedValue.typeIndex))
//            let view = controller.view
//            view?.backgroundColor = Style.default.backgroundColor()
//            return view
//        }
//    }
//    struct InputView: View {
//        var title: String
//        @ObservedObject var model: ViewModel
//        var categories: [BlocksTypes] = []
//        @Binding var categoryIndex: Int?
//        @Binding var typeIndex: Int?
//
//        var body: some View {
//            BlocksViews.Toolbar.AddBlock.InputView(title: self.title, model: self.model, categories: self.categories, categoryIndex: self.$categoryIndex, typeIndex: self.$typeIndex)
//        }
//    }
//}

//// MARK: ChangeColor
//extension BlocksViews.Toolbar {
//    enum ChangeColor {}
//}
//
//extension BlocksViews.Toolbar.ChangeColor {
//    typealias Style = BlocksViews.Toolbar.Style
//    enum Colors {
//        case black, grey, yellow, orange, red, magenta, purple, ultramarine, lightBlue, teal, green
//        func color(highlighted: Bool = false) -> UIColor {
//            switch self {
//            case .black: return highlighted ? .clear : .black
//            case .grey: return highlighted ? #colorLiteral(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) : #colorLiteral(red: 0.6745098039, green: 0.662745098, blue: 0.5882352941, alpha: 1) // #ACA996
//            case .yellow: return highlighted ? #colorLiteral(red: 0.996, green: 0.976, blue: 0.8, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.8509803922, blue: 0.1058823529, alpha: 1) // #ECD91B
//            case .orange: return highlighted ? #colorLiteral(red: 0.996, green: 0.953, blue: 0.773, alpha: 1) : #colorLiteral(red: 1, green: 0.7098039216, blue: 0.1333333333, alpha: 1) // #FFB522
//            case .red: return highlighted ? #colorLiteral(red: 1, green: 0.922, blue: 0.898, alpha: 1) : #colorLiteral(red: 0.9607843137, green: 0.3333333333, blue: 0.1333333333, alpha: 1) // #F55522
//            case .magenta: return highlighted ? #colorLiteral(red: 0.996, green: 0.89, blue: 0.961, alpha: 1) : #colorLiteral(red: 0.8980392157, green: 0.1098039216, blue: 0.6274509804, alpha: 1) // #E51CA0
//            case .purple: return highlighted ? #colorLiteral(red: 0.957, green: 0.891, blue: 0.98, alpha: 1) : #colorLiteral(red: 0.6705882353, green: 0.3137254902, blue: 0.8, alpha: 1) // #AB50CC
//            case .ultramarine: return highlighted ? #colorLiteral(red: 0.894, green: 0.906, blue: 0.988, alpha: 1) : #colorLiteral(red: 0.2431372549, green: 0.3450980392, blue: 0.9215686275, alpha: 1) // #3E58EB
//            case .lightBlue: return highlighted ? #colorLiteral(red: 0.84, green: 0.937, blue: 0.992, alpha: 1) : #colorLiteral(red: 0.1647058824, green: 0.6549019608, blue: 0.9333333333, alpha: 1) // #2AA7EE
//            case .teal: return highlighted ? #colorLiteral(red: 0.839, green: 0.961, blue: 0.953, alpha: 1) : #colorLiteral(red: 0.05882352941, green: 0.7843137255, blue: 0.7294117647, alpha: 1) // #0FC8BA
//            case .green: return highlighted ? #colorLiteral(red: 0.89, green: 0.969, blue: 0.816, alpha: 1) :  #colorLiteral(red: 0.3647058824, green: 0.831372549, blue: 0, alpha: 1) // #5DD400
//            }
//        }
//        static var colors: [Colors] = [.black, .grey, .yellow, .orange, .red, .magenta, .purple, .ultramarine, .lightBlue, .teal, .green]
//    }
//    class ViewModel: ObservableObject {
//        struct InnerStorage {
//            var textColor: UIColor?
//            var backgroundColor: UIColor?
//        }
//        @Published var value: InnerStorage = .init()
//        var colors: [Colors] = Colors.colors
//    }
//    class InputViewBuilder {
//        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
//            let controller = UIHostingController(rootView: InputView(colors: viewModel.wrappedValue.colors, textColor: viewModel.projectedValue.value.textColor, backgroundColor: viewModel.projectedValue.value.backgroundColor))
//            let view = controller.view
//            view?.backgroundColor = Style.default.backgroundColor()
//            return view
//        }
//    }
//    struct InputView: View {
//        var colors: [Colors]
//        @Binding var textColor: UIColor?
//        @Binding var backgroundColor: UIColor?
//        var body: some View {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Text Color").fontWeight(.semibold)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(alignment: .center, spacing: 8) {
//                        ForEach(0..<self.colors.count) { i in
//                            Button(action: {
//                                self.textColor = self.colors[i].color()
//                            }) {
//                                Text("Aa").font(.headline).fontWeight(.semibold).foregroundColor(Color(self.colors[i].color()))
//                            }.modifier(BlocksViews.Toolbar.RoundedButtonViewModifier())
//                        }
//                    }
//                }
//                Text("Highlight Color").fontWeight(.semibold)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(alignment: .center, spacing: 8) {
//                        ForEach(0..<self.colors.count) { i in
//                            Button(action: {
//                                self.backgroundColor = self.colors[i].color(highlighted: true)
//                            }) {
//                                Text("Aa").font(.headline).fontWeight(.semibold).background(Color(self.colors[i].color(highlighted: true))).foregroundColor(.black)
//                            }.modifier(BlocksViews.Toolbar.RoundedButtonViewModifier())
//                        }
//                    }
//                }
//            }.modifier(BlocksViews.Toolbar.OuterHorizontalStackViewModifier())
//        }
//    }
//}
//
//// MARK: EditActions
//extension BlocksViews.Toolbar {
//    enum EditActions {}
//}
//
//// MARK: EditActions / Actions
//extension BlocksViews.Toolbar.EditActions {
//    enum Action: CaseIterable {
//        case delete, duplicate, undo ,redo
//        func path() -> String {
//            switch self {
//            case .delete: return "TextEditor/Toolbar/Blocks/Actions/Delete"
//            case .duplicate: return "TextEditor/Toolbar/Blocks/Actions/Duplicate"
//            case .undo: return "TextEditor/Toolbar/Blocks/Actions/Undo"
//            case .redo: return "TextEditor/Toolbar/Blocks/Actions/Redo"
//            }
//        }
//        func title() -> String {
//            return self.path().components(separatedBy: "/").last ?? ""
//        }
//        static var allCases: [Self] = [.delete, .duplicate, .undo, .redo]
//    }
//}
//
//// MARK: EditActions / ViewModel
//extension BlocksViews.Toolbar.EditActions {
//    typealias Style = BlocksViews.Toolbar.Style
//    class ViewModel: ObservableObject {
//        @Published var value: Action?
//        var actions = Action.allCases
//    }
//    class InputViewBuilder {
//        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
//            let controller = UIHostingController(rootView: InputView(actions: viewModel.wrappedValue.actions, action: viewModel.projectedValue.value))
//            let view = controller.view
//            view?.backgroundColor = Style.default.backgroundColor()
//            return view
//        }
//    }
//    struct InputView: View {
//        var actions: [Action] = []
//        @Binding var action: Action?
//        var body: some View {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Block actions").fontWeight(.semibold)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(alignment: .center, spacing: 8) {
//                        ForEach(0..<self.actions.count) { i in
//                            Button(action: {
//                                self.action = self.actions[i]
//                            }) {
//                                VStack(spacing: 2) {
//                                    Image(self.actions[i].path()).renderingMode(.template).foregroundColor(.black).modifier(BlocksViews.Toolbar.RoundedButtonViewModifier())
//                                    Text(self.actions[i].title()).font(.caption).foregroundColor(.black)
//                                }
//                            }
//                        }
//                    }
//                }
//            }.modifier(BlocksViews.Toolbar.OuterHorizontalStackViewModifier())
//        }
//    }
//}
