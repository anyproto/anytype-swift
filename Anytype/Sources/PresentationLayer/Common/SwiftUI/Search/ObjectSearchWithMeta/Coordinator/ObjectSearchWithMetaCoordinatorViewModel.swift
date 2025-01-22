import SwiftUI

@MainActor
final class ObjectSearchWithMetaCoordinatorViewModel: ObservableObject, ObjectSearchWithMetaModuleOutput {
    
    let data: ObjectSearchWithMetaModuleData
    
    init(data: ObjectSearchWithMetaModuleData) {
        self.data = data
    }
    
    // MARK: - ObjectSearchWithMetaModuleOutput
    
}
