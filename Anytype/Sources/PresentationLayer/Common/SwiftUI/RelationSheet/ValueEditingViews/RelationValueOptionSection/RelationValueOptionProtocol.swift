import Foundation
import BlocksModels

protocol RelationValueOptionProtocol: Hashable {
    var text: String { get }
    var scope: RelationMetadata.Option.Scope { get }
}
