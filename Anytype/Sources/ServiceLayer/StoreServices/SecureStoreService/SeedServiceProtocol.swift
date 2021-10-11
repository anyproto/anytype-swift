protocol SeedServiceProtocol {
    func obtainSeed() throws -> String
    func saveSeed(_ seed: String) throws
    func removeSeed() throws
}
