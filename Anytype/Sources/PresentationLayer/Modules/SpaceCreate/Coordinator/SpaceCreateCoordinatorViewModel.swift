import SwiftUI

@MainActor
@Observable
final class SpaceCreateCoordinatorViewModel: SpaceCreateModuleOutput {

    let data: SpaceCreateData

    var localObjectIconPickerData: LocalObjectIconPickerData?
    
    init(data: SpaceCreateData) {
        self.data = data
    }
    
    // MARK: - SpaceCreateModuleOutput
    
    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput) {
        localObjectIconPickerData = LocalObjectIconPickerData(
            fileData: fileData,
            output: output
        )
    }
}
