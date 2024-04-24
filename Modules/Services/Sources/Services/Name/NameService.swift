import ProtobufMessages


public protocol NameServiceProtocol {
    func isNameAvailable(name: String) async throws -> Bool
}

final class NameService: NameServiceProtocol {
    func isNameAvailable(name: String) async throws -> Bool {
        return try await ClientCommands.nameServiceResolveName(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
        }).invoke().available
    }
}
