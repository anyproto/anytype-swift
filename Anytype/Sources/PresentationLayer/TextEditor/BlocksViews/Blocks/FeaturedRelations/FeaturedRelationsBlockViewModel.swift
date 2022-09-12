import UIKit
import BlocksModels

struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    private let type: String
    private let featuredRelationValues: [RelationValue]
    private weak var blockDelegate: BlockDelegate?
    private let onRelationValueTap: (RelationValue) -> Void
    private let relationViewModels: [RelationItemModel]
    
    var hashable: AnyHashable {
        [
            type,
            relationViewModels
        ] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
        featuredRelationValues: [RelationValue],
        type: String,
        blockDelegate: BlockDelegate,
        onRelationValueTap: @escaping (RelationValue) -> Void
    ) {
        self.info = info
        self.featuredRelationValues = featuredRelationValues
        self.type = type
        self.blockDelegate = blockDelegate
        self.onRelationValueTap = onRelationValueTap
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
                    .map(onRelationValueTap)
            },
            heightDidChanged: { blockDelegate?.textBlockSetNeedsLayout() }
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: nil
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
