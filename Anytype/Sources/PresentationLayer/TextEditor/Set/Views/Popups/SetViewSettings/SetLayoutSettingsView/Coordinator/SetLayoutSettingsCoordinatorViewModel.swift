import SwiftUI

@MainActor
protocol SetLayoutSettingsCoordinatorOutput: AnyObject {
    func onImagePreviewTap(completion: @escaping (String) -> Void)
    func onGroupByTap(completion: @escaping (String) -> Void)
}

@MainActor
@Observable
final class SetLayoutSettingsCoordinatorViewModel: SetLayoutSettingsCoordinatorOutput {
    var imagePreviewData: SetLayoutSettingsData?
    var groupByData: SetLayoutSettingsData?

    @ObservationIgnored
    let setDocument: any SetDocumentProtocol
    @ObservationIgnored
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

