import Services
import SwiftUI

@MainActor
protocol ObjectVersionModuleOutput: AnyObject {
    func versionRestored()
}

@MainActor
final class ObjectVersionViewModel: ObservableObject {
    
    @Published var screenData: EditorScreenData?
    @Published var dismiss = false
    
    let data: ObjectVersionData
    
    @Injected(\.historyVersionsService)
    private var historyVersionsService: any HistoryVersionsServiceProtocol
    
    private weak var output: (any ObjectVersionModuleOutput)?
    
    init(data: ObjectVersionData, output: (any ObjectVersionModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    func setupObject() async {
        self.screenData = currentScreenData()
    }
    
    func onCancelTap() {
        dismiss.toggle()
    }
    
    func onRestoreTap() {
        Task {
            try await historyVersionsService.setVersion(objectId: data.objectId, versionId: data.versionId)
            output?.versionRestored()
        }
    }
    
    private func currentScreenData() -> EditorScreenData? {
        let mode: DocumentMode = .version(data.versionId)
        if data.isListType {
            return .set(EditorSetObject(objectId: data.objectId, spaceId: data.spaceId, mode: mode))
        } else {
            return .page(EditorPageObject(objectId: data.objectId, spaceId: data.spaceId, mode: mode))
        }
    }
}

