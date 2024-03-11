public protocol NameServiceProtocol {
    func resolveName(name: String) async throws
}

final class NameService: NameServiceProtocol {
    func resolveName(name: String) async throws {
        if name != "Vovavova" {
            throw CommonError.undefined
        }
    }
}
