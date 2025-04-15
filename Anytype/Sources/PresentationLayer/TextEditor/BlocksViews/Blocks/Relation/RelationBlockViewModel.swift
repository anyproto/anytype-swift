import UIKit
import Services
import AnytypeCore
import Combine

final class RelationProvider {
    @Published var relation: Relation
    private var subscription: AnyCancellable?
    
    init(relation: Relation, relationPublisher: AnyPublisher<ParsedRelations, Never>) {
        self.relation = relation
        
        subscription = relationPublisher
            .compactMap {
                $0.all.first { $0.key == relation.key }
            }.removeDuplicates()
            .sink { [weak self] in
                self?.relation = $0
            }
    }
}

final class RelationBlockViewModel: BlockViewModelProtocol {
    let blockInformationProvider: BlockModelInfomationProvider
    nonisolated var info: BlockInformation { blockInformationProvider.info }
    let relationProvider: RelationProvider
    let actionOnValue: (() -> Void)?
    
    var relationSubscription: AnyCancellable?

    // MARK: - BlockViewModelProtocol methods

    nonisolated var hashable: AnyHashable { info.id }
    
    init(
        blockInformationProvider: BlockModelInfomationProvider,
        relationProvider: RelationProvider,
        collectionController: EditorBlockCollectionController,
        actionOnValue: (() -> Void)? = nil
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.relationProvider = relationProvider
        self.actionOnValue = actionOnValue
        
        relationSubscription = relationProvider.$relation.receiveOnMain().sink { [weak self] _ in
            guard let self else { return }
            collectionController.reconfigure(items: [.block(self)])
        }
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        return RelationBlockContentConfiguration(
            actionOnValue: { [weak self] in self?.actionOnValue?() },
            relation: RelationItemModel(relation: relationProvider.relation)
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
}
