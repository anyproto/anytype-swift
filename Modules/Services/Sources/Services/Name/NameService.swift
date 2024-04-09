import ProtobufMessages


public protocol NameServiceProtocol {
    func resolveName(name: String) async throws
}

final class NameService: NameServiceProtocol {
    func resolveName(name: String) async throws {
        try await ClientCommands.nameServiceResolveName(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
        }).invoke()
    }
}
