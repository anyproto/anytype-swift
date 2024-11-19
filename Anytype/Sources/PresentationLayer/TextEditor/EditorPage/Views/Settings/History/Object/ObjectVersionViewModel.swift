import Services
import SwiftUI

@MainActor
protocol ObjectVersionModuleOutput: AnyObject {
    func versionRestored(_ text: String)
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
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenHistoryVersion()
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
            output?.versionRestored(data.title.trimmingCharacters(in: .whitespaces))
            AnytypeAnalytics.instance().logRestoreFromHistory()
        }
    }
    
    private func currentScreenData() -> EditorScreenData? {
        let mode: DocumentMode = .version(data.versionId)
        if data.isListType {
            return .list(
                EditorListObject(
                    objectId: data.objectId,
                    spaceId: data.spaceId,
                    mode: mode,
                    usecase: .embedded
                )
            )
        } else {
            return .page(
                EditorPageObject(
                    objectId: data.objectId,
                    spaceId: data.spaceId,
                    mode: mode,
                    usecase: .embedded
                )
            )
        }
    }
}

