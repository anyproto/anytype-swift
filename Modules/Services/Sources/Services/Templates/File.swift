import ProtobufMessages

public protocol TemplatesServiceProtocol {
    func cloneTemplate(blockId: BlockId) async throws
    func createTemplateFromObject(blockId: BlockId) async throws
    func deleteTemplate(templateId: BlockId) async throws
}

public final class TemplatesService: TemplatesServiceProtocol {
    public init() {}
    
    public func cloneTemplate(blockId: BlockId) async throws {
        _ = try await ClientCommands.objectListDuplicate(.with {
            $0.objectIds = [blockId]
        }).invoke()
    }
    
    public func createTemplateFromObject(blockId: BlockId) async throws {
        _ = try await ClientCommands.templateCreateFromObject(.with {
            $0.contextID = blockId
        }).invoke()
    }
    
    public func deleteTemplate(templateId: BlockId) async throws {
        _ = try await ClientCommands.objectSetIsArchived(.with {
            $0.contextID = templateId
            $0.isArchived = true
        }).invoke()
    }
}

