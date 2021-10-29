struct CoverColor: Identifiable, Codable, Equatable {
    let name: String
    
    let hex: String
    
    var id: String {
        "\(name)\(hex)"
    }
}
