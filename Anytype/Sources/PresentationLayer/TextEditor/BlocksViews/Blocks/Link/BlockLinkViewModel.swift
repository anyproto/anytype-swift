import UIKit
import Combine
import Services
import AnytypeCore

final class BlockLinkViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    
    var info: BlockInformation { informationProvider.info }

    private let informationProvider: BlockModelInfomationProvider
    private let document: any BaseDocumentProtocol
    private let blocksController: EditorBlockCollectionController
    private let openLink: (ScreenData) -> ()
    private let detailsService: any DetailsServiceProtocol
    private var objectDetailsSubscription: AnyCancellable?
    
    private var content: BlockLink {
        guard case let .link(blockLink) = info.content else { return .empty() }
        return blockLink
    }
    
    private var targetDetails: ObjectDetails?

    init(
        informationProvider: BlockModelInfomationProvider,
        document: some BaseDocumentProtocol,
        blocksController: EditorBlockCollectionController,
        detailsService: some DetailsServiceProtocol,
        openLink: @escaping (ScreenData) -> ()
    ) {
        self.informationProvider = informationProvider
        self.document = document
        self.blocksController = blocksController
        self.openLink = openLink
        self.detailsService = detailsService
        
        
        objectDetailsSubscription = document
            .subscribeForDetails(objectId: content.targetBlockID)
            .sinkOnMain { [weak self] details in
                guard let self else { return }
                self.targetDetails = details
                blocksController.reconfigure(items: [.block(self)])
                blocksController.itemDidChangeFrame(item: .block(self))
        }
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> any UIContentConfiguration {
        guard let details = targetDetails else {
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
                    styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
                )
        default:
            return BlockLinkTextConfiguration(state: state, todoToggleAction: toggleTodo)
                .cellBlockConfiguration(
                    dragConfiguration: .init(id: info.id),
                    styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
                )
        }
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard let targetDetails else { return }
        let state = BlockLinkState(details: targetDetails, blockLink: content)
        
        if state.deleted { return }
        
        openLink(state.screenData)
    }

    private func toggleTodo() {
        guard let targetDetails else { return }
        
        let state = BlockLinkState(details: targetDetails, blockLink: content)
        guard case let .object(.todo(isChecked, _)) = state.icon else {
            return
        }
        
        Task {
            try await detailsService.updateDetails(
                contextId: content.targetBlockID,
                relationKey: BundledRelationKey.done.rawValue,
                value: .checkbox(.with { $0.checked = !isChecked })
            )
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}
