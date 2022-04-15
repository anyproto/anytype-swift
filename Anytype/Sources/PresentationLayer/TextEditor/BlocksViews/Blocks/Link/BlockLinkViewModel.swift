
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
        let objectPreviewFields = ObjectPreviewFields.convertToModel(fields: info.fields)
        self.state = details.flatMap { BlockLinkState(details: $0, objectPreviewFields: objectPreviewFields) } ?? .empty
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
        if state.deleted || state.archived {
            return
        }
        
        guard let id = content.targetBlockID.asAnytypeId else { return }
        openLink(EditorScreenData(pageId: id, type: state.viewType))
    }
}
