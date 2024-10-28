import SwiftUI

@MainActor
final class DateCoordinatorViewModel: ObservableObject{
    
    let objectId: String
    let spaceId: String
    
    init(data: EditorDateObject) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
    }
}
