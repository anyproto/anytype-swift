struct CoverColor: Identifiable {
    let name: String
    
    let hex: String
    
    var id: String {
        "\(name)\(hex)"
    }
}
