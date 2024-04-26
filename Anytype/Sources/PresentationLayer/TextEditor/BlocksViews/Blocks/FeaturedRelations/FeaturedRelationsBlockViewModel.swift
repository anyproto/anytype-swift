import UIKit
import Services

struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    private let type: String
    private let featuredRelationValues: [Relation]
    private weak var blockDelegate: BlockDelegate?
    private let onRelationTap: (Relation) -> Void
    private let relationViewModels: [RelationItemModel]
    
    var hashable: AnyHashable {
        [
            type,
            relationViewModels
        ] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
        featuredRelationValues: [Relation],
        type: String,
        blockDelegate: BlockDelegate,
        onRelationValueTap: @escaping (Relation) -> Void
    ) {
        self.info = info
        self.featuredRelationValues = featuredRelationValues
        self.type = type
        self.blockDelegate = blockDelegate
        self.onRelationTap = onRelationValueTap
        self.relationViewModels = featuredRelationValues.map(RelationItemModel.init)
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        FeaturedRelationsBlockContentConfiguration(
            featuredRelations: relationViewModels,
            type: type,
            alignment: info.horizontalAlignment.asNSTextAlignment,
            onRelationTap: { item in
                featuredRelationValues
                    .first { $0.key == item.key }
                    .map(onRelationTap)
            },
            heightDidChanged: { blockDelegate?.textBlockSetNeedsLayout() }
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: nil
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
