
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
        details: ObjectDetails?,
        openLink: @escaping (EditorScreenData) -> ()
    ) {
        self.info = info
        self.content = content
        self.openLink = openLink

        self.state = details.flatMap {
            BlockLinkState(
                details: $0,
                cardStyle: content.appearance.cardStyle,
                relations: content.appearance.relations,
                iconSize: content.appearance.iconSize,
                descriptionState: content.appearance.description
            )
        } ?? .empty
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let backgroundColor = info.backgroundColor.map {
            UIColor.Background.uiColor(from: $0)
        } ?? .clear

        return BlockLinkContentConfiguration(state: state, backgroundColor: backgroundColor)
            .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if state.deleted || state.archived { return }
        
        openLink(EditorScreenData(pageId: content.targetBlockID, type: state.viewType))
    }
}
