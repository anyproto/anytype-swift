struct SimpleSetState: Equatable {
    var limit = Constants.limit
    
    mutating func increaseLimit() {
        limit += Constants.limit
    }
    
    private enum Constants {
        static let limit = 100
    }
}
