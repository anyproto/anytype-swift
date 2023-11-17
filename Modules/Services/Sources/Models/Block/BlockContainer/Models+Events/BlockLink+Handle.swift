import Foundation
import ProtobufMessages

extension BlockLink {
    func handleSetLink(data: Anytype_Event.Block.Set.Link) -> Self {
        var blockLink = self

        if data.hasIconSize {
            blockLink.appearance.iconSize = data.iconSize.value.asModel
        }

        if data.hasCardStyle {
            blockLink.appearance.cardStyle = data.cardStyle.value.asModel
        }

        if data.hasDescription_p {
            blockLink.appearance.description = data.description_p.value.asModel
        }

        if data.hasRelations {
            blockLink.appearance.relations = data.relations.value.compactMap(BlockLink.Relation.init(rawValue:))
        }

        if data.hasTargetBlockID {
            blockLink.targetBlockID = data.targetBlockID.value
        }

        return blockLink
    }
}
