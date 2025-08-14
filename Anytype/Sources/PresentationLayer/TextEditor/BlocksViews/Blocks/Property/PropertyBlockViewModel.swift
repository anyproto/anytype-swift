import UIKit
import Services
import AnytypeCore
import Combine

final class PropertyProvider {
    @Published var relation: Property
    private var subscription: AnyCancellable?
    
    init(relation: Property, relationPublisher: AnyPublisher<ParsedProperties, Never>) {
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

final class PropertyBlockViewModel: BlockViewModelProtocol {
    let blockInformationProvider: BlockModelInfomationProvider
    nonisolated var info: BlockInformation { blockInformationProvider.info }
    let relationProvider: PropertyProvider
    let actionOnValue: (() -> Void)?
    
    var relationSubscription: AnyCancellable?

    // MARK: - BlockViewModelProtocol methods

    let className = "PropertyBlockViewModel"
    
    init(
        blockInformationProvider: BlockModelInfomationProvider,
        relationProvider: PropertyProvider,
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
        return PropertyBlockContentConfiguration(
            actionOnValue: { [weak self] in self?.actionOnValue?() },
            property: PropertyItemModel(property: relationProvider.relation)
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
}
