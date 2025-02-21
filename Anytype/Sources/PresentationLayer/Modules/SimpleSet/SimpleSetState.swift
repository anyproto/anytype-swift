struct SimpleSetState: Equatable {
    var limit = Constants.limit
    var layout = SimpleSetLayout.list
    
    mutating func increaseLimit() {
        limit += Constants.limit
    }
    
    private enum Constants {
        static let limit = 100
    }
}
