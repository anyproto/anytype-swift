import UIKit
import Combine
import Services
import AnytypeCore

final class BlockLinkViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    
    var info: BlockInformation { informationProvider.info }

    private let informationProvider: BlockModelInfomationProvider
    private let objectDetailsProvider: ObjectDetailsInfomationProvider
    private let blocksController: EditorBlockCollectionController
    private let openLink: (EditorScreenData) -> ()
    private let detailsService: DetailsServiceProtocol
    private var objectDetailsSubscription: AnyCancellable?
    
    private var content: BlockLink {
        guard case let .link(blockLink) = info.content else { return .empty() }
        return blockLink
    }

    init(
        informationProvider: BlockModelInfomationProvider,
        objectDetailsProvider: ObjectDetailsInfomationProvider,
        blocksController: EditorBlockCollectionController,
        detailsService: DetailsServiceProtocol,
        openLink: @escaping (EditorScreenData) -> ()
    ) {
        self.informationProvider = informationProvider
        self.objectDetailsProvider = objectDetailsProvider
        self.blocksController = blocksController
        self.openLink = openLink
        self.detailsService = detailsService
        
        objectDetailsSubscription = objectDetailsProvider
            .$details
            .receiveOnMain()
            .sink { [weak self] _ in
            guard let self else { return }
                blocksController.reconfigure(items: [.block(self)])
                blocksController.itemDidChangeFrame(item: .block(self))
        }
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        guard let details = objectDetailsProvider.details else {
            anytypeAssertionFailure("Coudn't find object details for blockLink")
            return UnsupportedBlockViewModel(info: info)
                .makeContentConfiguration(maxWidth: width)
        }
        let state = BlockLinkState(details: details, blockLink: content)
        
        switch (content.appearance.cardStyle, state.deleted, state.archived) {
        case (.card, false, false):
            let backgroundColor = info.backgroundColor.map {
                UIColor.VeryLight.uiColor(from: $0)
            }

            return BlockLinkCardConfiguration(state: state, backgroundColor: backgroundColor, todoToggleAction: toggleTodo)
                .cellBlockConfiguration(
                    dragConfiguration: .init(id: info.id),
                    styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
                )
        default:
            return BlockLinkTextConfiguration(state: state, todoToggleAction: toggleTodo)
                .cellBlockConfiguration(
                    dragConfiguration: .init(id: info.id),
                    styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
                )
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard let details = objectDetailsProvider.details else { return }
        let state = BlockLinkState(details: details, blockLink: content)
        
        if state.deleted { return }
        
        openLink(state.screenData)
    }

    private func toggleTodo() {
        guard let details = objectDetailsProvider.details else { return }
        
        let state = BlockLinkState(details: details, blockLink: content)
        guard case let .object(.todo(isChecked)) = state.icon else {
            return
        }
        
        Task {
            try await detailsService.updateDetails(
                contextId: content.targetBlockID,
                relationKey: BundledRelationKey.done.rawValue,
                value: .checkbox(.with { $0.checked = !isChecked })
            )
            await UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}
