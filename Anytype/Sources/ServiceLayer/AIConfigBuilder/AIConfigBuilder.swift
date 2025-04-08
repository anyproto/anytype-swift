import Foundation
import Services

protocol AIConfigBuilderProtocol: Sendable {
    func makeOpenAIConfig() -> AIProviderConfig?
}

struct AIConfigBuilder: AIConfigBuilderProtocol {
    private var endpoint: String? {
        Bundle.main.object(forInfoDictionaryKey:  "AIEndpoint") as? String
    }
    
    private var model: String? {
        Bundle.main.object(forInfoDictionaryKey:  "AIModel") as? String
    }
    
    private var token: String? {
        Bundle.main.object(forInfoDictionaryKey:  "OpenAIToken") as? String
    }
    
    func makeOpenAIConfig() -> AIProviderConfig? {
        guard let endpoint, endpoint.isNotEmpty,
              let model, model.isNotEmpty,
              let token, token.isNotEmpty else {
            return nil
        }
        
        var config = AIProviderConfig()
        config.provider = .openai
        config.endpoint = endpoint
        config.model = model
        config.token = token
        config.temperature = 0.2
        
        return config
    }
}
