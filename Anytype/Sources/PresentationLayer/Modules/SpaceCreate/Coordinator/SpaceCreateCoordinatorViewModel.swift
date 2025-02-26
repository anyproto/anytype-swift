import SwiftUI

@MainActor
final class SpaceCreateCoordinatorViewModel: ObservableObject, SpaceCreateModuleOutput {
    
    let data: SpaceCreateData
    
    @Published var localObjectIconPickerData: LocalObjectIconPickerData?
    
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
