//
//  TextBlocksViews+List.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// TODO: rethink.
// We could remove pair of protocols by using DocumentViewModel instead.
// MARK: ViewModel
extension TextBlocksViews.List {
    class BlockViewModel {
        fileprivate weak var delegate: TextBlocksViewsUserInteractionProtocol?
        fileprivate var blocks: [BlockViewBuilderProtocol] {
            didSet {
                _ = self.configured(self.blocks)
            }
        }
        
        func configured(_ blocks: [BlockViewBuilderProtocol]) -> [BlockViewBuilderProtocol] {
            _ = blocks.compactMap{$0 as? TextBlocksViewsUserInteractionProtocolHolder}.compactMap{$0.configured(self)}
            return blocks
        }
        
        init(blocks: [BlockViewBuilderProtocol]) {
            self.blocks = blocks
            _ = self.configured(blocks)
        }
        
        var id: Block.ID = UUID().uuidString
//        var id: String {
////            return "list"
//            // we should return something unique.
//        }
    }
}

// MARK: TextBlocksViewsUserInteractionProtocolHolder
extension TextBlocksViews.List.BlockViewModel: TextBlocksViewsUserInteractionProtocolHolder {
    func configured(_ delegate: TextBlocksViewsUserInteractionProtocol?) -> Self? {
        self.delegate = delegate
        return self
    }
}

// MARK: TextBlocksViewsUserInteractionProtocol
extension TextBlocksViews.List.BlockViewModel: TextBlocksViewsUserInteractionProtocol {
    func didReceiveAction(block: Block, id: Block.ID, action: TextView.UserAction) {
        self.delegate?.didReceiveAction(block: block, id: id, action: action)
    }
}

// MARK: ObservableObject
extension TextBlocksViews.List.BlockViewModel: ObservableObject {}

// MARK: Identifiable
extension TextBlocksViews.List.BlockViewModel: Identifiable {}

// MARK: BlockViewBuilderProtocol
extension TextBlocksViews.List.BlockViewModel: BlockViewBuilderProtocol {
    func buildView() -> AnyView {
        .init(TextBlocksViews.List.BlockView(viewModel: self))
    }
    func buildUIView() -> UIView { .init() }
}

// MARK: Style
extension TextBlocksViews.List {
    enum Style {
        case none
        case number(Int)
        func string() -> String {
            switch self {
            case .none: return ""
            case let .number(value): return "\(value)"
            }
        }
    }
}

// MARK: View
import SwiftUI

extension TextBlocksViews.List {
    struct MarkedViewModifier: ViewModifier {
        fileprivate var style: Style
        func accessoryView() -> some View {
            return Text(self.style.string())
            // "TextEditor/Style/Bulleted/mark"
        }
        func body(content: Content) -> some View {
            HStack {
                self.accessoryView()
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            VStack {
                ForEach(self.viewModel.blocks, id: \.id) { (element) in
                    element.buildView()
                }
            }
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.List {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let textType = BlockType.Text(text: "some text", contentType: .todo)
            let block = Block(id: "1", childrensIDs: [""], type: .text(textType))
            let model = TextBlocksViews.Checkbox.BlockViewModel(block)
            let viewModel = BlockViewModel(blocks: [model])
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
