
import UIKit
import Combine
import BlocksModels

struct BlockLinkViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable {
        [
            info,
            state
        ] as [AnyHashable]
    }
    
    let info: BlockInformation

    private let state: BlockLinkState
    private let content: BlockLink
    private let openLink: (EditorScreenData) -> ()

    init(
        info: BlockInformation,
        content: BlockLink,
        details: ObjectDetails,
        openLink: @escaping (EditorScreenData) -> ()
    ) {
        self.info = info
        self.content = content
        self.openLink = openLink
        self.state = BlockLinkState(details: details, blockLink: content)
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch (content.appearance.cardStyle, state.deleted, state.archived) {
        case (.card, false, false):
            let backgroundColor = info.backgroundColor.map {
                UIColor.Background.uiColor(from: $0)
            }

            return BlockLinkCardConfiguration(state: state, backgroundColor: backgroundColor)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        default:
            return BlockLinkTextConfiguration(state: state)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if state.deleted || state.archived { return }
        
        openLink(EditorScreenData(pageId: content.targetBlockID, type: state.viewType))
    }
}
