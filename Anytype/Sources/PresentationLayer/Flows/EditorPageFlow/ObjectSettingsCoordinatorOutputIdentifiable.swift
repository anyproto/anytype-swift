import Foundation

struct ObjectSettingsCoordinatorOutputIdentifiable: Identifiable {
    let value: any ObjectSettingsCoordinatorOutput
    
    init(value: any ObjectSettingsCoordinatorOutput) {
        self.value = value
    }
    
    var id: Int {
        (value as AnyObject).hash
    }
}
