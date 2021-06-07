protocol SeedServiceProtocol {
    /// Obtain seed
    func obtainSeed() throws -> String
    
    /// Save seed to keychain
    /// - Parameter seed: seed
    func saveSeed(_ seed: String) throws
    
    /// Remove seed
    func removeSeed() throws
}
