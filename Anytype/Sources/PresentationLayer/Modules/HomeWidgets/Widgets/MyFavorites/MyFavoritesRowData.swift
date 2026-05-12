import Foundation
import Services

struct MyFavoritesRowData: Identifiable, Equatable {
    let id: String
    let details: ObjectDetails
    var objectId: String { details.id }
}
