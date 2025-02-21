import Services

enum SimpleSetLayout {
    case list
    case gallery
}

extension ObjectType {
    var simpleSetLayout: SimpleSetLayout {
        if isImageLayout {
            return .gallery
        } else {
            return .list
        }
    }
}
