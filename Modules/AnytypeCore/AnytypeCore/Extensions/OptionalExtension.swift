public extension Optional {

    // This property should be used instead of comparision with `nil` literal to decrease compilation time.
    var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
    
   var isNotNil: Bool {
        return !isNil
    }

}

