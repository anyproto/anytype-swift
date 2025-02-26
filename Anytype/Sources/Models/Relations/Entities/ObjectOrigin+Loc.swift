import Foundation
import Services

extension ObjectOrigin {
    var title: String? {
        switch self {
        case .none, .UNRECOGNIZED, .api:
            return nil
        case .clipboard:
            return Loc.Relation.Origin.clipboard
        case .dragAndDrop:
            return Loc.Relation.Origin.dragAndDrop
        case .import:
            return Loc.Relation.Origin.import
        case .webclipper:
            return Loc.Relation.Origin.webClipper
        case .sharingExtension:
            return Loc.Relation.Origin.sharingExtension
        case .usecase:
            return Loc.Relation.Origin.useCase
        case .builtin:
            return Loc.Relation.Origin.builtin
        case .bookmark:
            return Loc.Relation.Origin.bookmark
        case .api:
            return Loc.Relation.Origin.api
        }
    }
}
