import UIKit
import BlocksModels

struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation
    let indentationLevel: Int = 0

    private let type: String
    private let featuredRelations: [Relation]
    private let blockDelegate: BlockDelegate
    private let onRelationTap: (Relation) -> Void
    private let relationViewModels: [RelationItemModel]
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            type,
            relationViewModels
        ] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
        featuredRelation: [Relation],
        type: String,
        blockDelegate: BlockDelegate,
        onRelationTap: @escaping (Relation) -> Void
    ) {
        self.info = info
        self.featuredRelations = featuredRelation
        self.type = type
        self.blockDelegate = blockDelegate
        self.onRelationTap = onRelationTap
        self.relationViewModels = featuredRelations.map(RelationItemModel.init)
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        FeaturedRelationsBlockContentConfiguration(
            featuredRelations: relationViewModels,
            type: type,
            alignment: info.alignment.asNSTextAlignment,
            onRelationTap: { item in
                featuredRelations
                    .first { $0.id == item.id }
                    .map(onRelationTap)
            },
            heightDidChanged: { blockDelegate.textBlockSetNeedsLayout() }
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: nil
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
