import Services
import UIKit
import AnytypeCore
import SwiftUI

struct EmbedBlockViewModel: BlockViewModelProtocol {
    
    let info: BlockInformation

    let className = "EmbedBlockViewModel"
    
    private var content: BlockLatex {
        guard case let .embed(blockLatex) = info.content else { return BlockLatex() }
        return blockLatex
    }

    init(info: BlockInformation) {
        self.info = info
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> any UIContentConfiguration {
        return UIHostingConfiguration {
            EmbedContentView(
                model: EmbedContentViewModel(
                    data: content.asEmbedContentData
                )
            )
        }
        .minSize(height: 0)
        .margins(.vertical, 10)
        .margins(.horizontal, 20)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
