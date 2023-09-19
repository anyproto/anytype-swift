import UIKit
import Combine
import Services
import AnytypeCore

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
    private let detailsService: DetailsServiceProtocol

    init(
        info: BlockInformation,
        content: BlockLink,
        details: ObjectDetails,
        detailsService: DetailsServiceProtocol,
        openLink: @escaping (EditorScreenData) -> ()
    ) {
        self.info = info
        self.content = content
        self.openLink = openLink
        self.detailsService = detailsService
        self.state = BlockLinkState(details: details, blockLink: content)
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch (content.appearance.cardStyle, state.deleted, state.archived) {
        case (.card, false, false):
            let backgroundColor = info.backgroundColor.map {
                UIColor.VeryLight.uiColor(from: $0)
            }

            return BlockLinkCardConfiguration(state: state, backgroundColor: backgroundColor, todoToggleAction: toggleTodo)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        default:
            return BlockLinkTextConfiguration(state: state, todoToggleAction: toggleTodo)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if state.deleted { return }
        
        openLink(state.screenData)
    }

    private func toggleTodo() {
        guard case let .object(.todo(isChecked)) = state.icon else {
            return
        }
        
        Task {
            try await detailsService.updateDetails(
                contextId: content.targetBlockID,
                relationKey: BundledRelationKey.done.rawValue,
                value: .checkbox(.with { $0.checked = !isChecked })
            )
        }
    }
}
