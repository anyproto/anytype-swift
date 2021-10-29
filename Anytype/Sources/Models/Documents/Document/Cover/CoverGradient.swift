struct CoverGradient: Identifiable, Codable, Equatable {
    let name: String
    
    let startHex: String
    let endHex: String
    
    var id: String {
        "\(name)\(startHex)\(endHex)"
    }
}
