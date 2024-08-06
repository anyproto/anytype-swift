import SwiftUI

@MainActor
protocol SetLayoutSettingsCoordinatorOutput: AnyObject {
    func onImagePreviewTap(completion: @escaping (String) -> Void)
    func onGroupByTap(completion: @escaping (String) -> Void)
}

@MainActor
final class SetLayoutSettingsCoordinatorViewModel: ObservableObject, SetLayoutSettingsCoordinatorOutput {
    @Published var imagePreviewData: SetLayoutSettingsData?
    @Published var groupByData: SetLayoutSettingsData?
    
    let setDocument: any SetDocumentProtocol
    let viewId: String
    
    init(setDocument: some SetDocumentProtocol, viewId: String) {
        self.setDocument = setDocument
        self.viewId = viewId
    }
    
    // MARK: - SetLayoutSettingsCoordinatorOutput
    
    func onImagePreviewTap(completion: @escaping (String) -> Void) {
        imagePreviewData = SetLayoutSettingsData(
            completion: completion
        )
    }
    
    func onGroupByTap(completion: @escaping (String) -> Void) {
        groupByData = SetLayoutSettingsData(
            completion: completion
        )
    }
}

