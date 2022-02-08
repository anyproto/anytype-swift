public enum DetailsLayout: Int, CaseIterable {
    case basic = 0
    case profile = 1
    case todo = 2
    case set = 3
//    case objectType = 4
//    case relation = 5
//    case file = 6
//    case dashboard = 7
//    case image = 8
    case note = 9
//
//    case database = 20 // to be released later
}

public extension DetailsLayout {
    
    static var editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo
    ]
    
    static let fileLayout: Int = 6
    static let imageLayout: Int = 8
    
}
