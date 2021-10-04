struct CoverGradient: Identifiable {
    let name: String
    
    let startHex: String
    let endHex: String
    
    var id: String {
        "\(name)\(startHex)\(endHex)"
    }
}
