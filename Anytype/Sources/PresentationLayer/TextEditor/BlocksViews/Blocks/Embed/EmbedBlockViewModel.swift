import Services
import UIKit
import AnytypeCore
import SwiftUI

struct EmbedBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    let className = "EmbedBlockViewModel"

    init(info: BlockInformation) {
        self.info = info
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> any UIContentConfiguration {
        return UIHostingConfiguration {
            EmbedContentView(
                data: EmbedContentData(
                    icon: .X32.attachment,
                    text: "Figma embed. This content is not available on mobile",
                    url: nil
                )
            )
        }
        .minSize(height: 0)
        .margins(.vertical, 10)
        .margins(.horizontal, 20)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
