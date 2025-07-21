import Services
import UIKit
import AnytypeCore
import SwiftUI
import Combine

final class EmbedBlockViewModel: BlockViewModelProtocol {
    
    let info: BlockInformation
    
    @Injected(\.embedContentDataBuilder)
    private var embedContentDataBuilder: any EmbedContentDataBuilderProtocol
    
    private let document: any BaseDocumentProtocol
    private var subscription: AnyCancellable?
    private let collectionController: any EditorCollectionReloadable
    
    private var embedContentData: EmbedContentData?

    let className = "EmbedBlockViewModel"

    init(
        info: BlockInformation,
        blockContent: BlockLatex,
        document: some BaseDocumentProtocol,
        collectionController: some EditorCollectionReloadable
    ) {
        self.info = info
        self.document = document
        self.collectionController = collectionController
        self.embedContentData = embedContentDataBuilder.build(from: blockContent)
        
        setupBlockSubscription()
    }
    
    func setupBlockSubscription() {
        subscription = document.subscribeForBlockInfo(blockId: info.id)
            .sinkOnMain { [weak self] info in
                guard let self else { return }
                embedContentData = embedContentDataBuilder.build(from: content(for: info))
                collectionController.reconfigure(items: [.block(self)])
            }
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        guard let embedContentData else {
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: maxWidth)
        }
        return UIHostingConfiguration {
            EmbedContentView(
                model: EmbedContentViewModel(data: embedContentData)
            )
        }
        .minSize(height: 0)
        .margins(.vertical, 10)
        .margins(.horizontal, 20)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
    
    private func content(for info: BlockInformation) -> BlockLatex {
        guard case let .embed(blockLatex) = info.content else { return BlockLatex() }
        return blockLatex
    }
}
