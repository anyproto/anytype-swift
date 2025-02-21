import Combine
import Services
import Foundation
import AnytypeCore

struct AIToolData: Identifiable {
    let id: String
    let spaceId: String
    let objectIds: [String]
    let completion: (ScreenData) -> Void
}

@MainActor
final class AIToolViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var generateTaskId: String? = nil
    @Published var inProgress = false
    @Published var dismiss = false
    
    @Injected(\.aiService)
    private var aiService: any AIServiceProtocol
    
    private let aiConfigBuilder: any AIConfigBuilderProtocol = AIConfigBuilder()
    
    private let data: AIToolData
    
    init(data: AIToolData) {
        self.data = data
    }
    
    func generate() async {
        guard let config = aiConfigBuilder.makeOpenAIConfig() else {
            anytypeAssertionFailure(
                "Endpoint, Model, Token should be set, ask @joe_pusya to run it in debug mode"
            )
            return
        }
        
        do {
            inProgress = true
            let objectId = try await aiService.aiListSummary(spaceId: data.spaceId, objectIds: data.objectIds, prompt: text, config: config)
            data.completion(
                .editor(.page(EditorPageObject(objectId: objectId, spaceId: data.spaceId)))
            )
            inProgress = false
            dismiss = true
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
        }
    }
    
    func generateTap() {
        generateTaskId = UUID().uuidString
    }
}
