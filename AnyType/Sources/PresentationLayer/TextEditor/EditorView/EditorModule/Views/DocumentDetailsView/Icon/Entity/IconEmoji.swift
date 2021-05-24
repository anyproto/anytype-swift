struct IconEmoji {
    
    let value: String
    
    // MARK: - Initializer
    
    init?(_ value: String?) {
        guard let value = value, value.isSingleEmoji else { return nil }
        
        self.value = value
    }
    
}
