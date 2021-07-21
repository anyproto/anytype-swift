struct ImageParameters: Codable, Hashable {
    internal init(width: ImageParameters.Width) {
        self.width = width
    }
    
    ///`Write Decoder (?)`
    struct Width: Codable, Hashable {
        let value: Int
        static let `default`: Self = .init(value: 1080)
        static let `thumbnail`: Self = .init(value: 100)
    }
    
    let width: Width
    
    enum CodingKeys: String, CodingKey {
        case width = "width"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(Int.self, forKey: .width)
        self.width = .init(value: width)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.width.value, forKey: .width)
    }
}

extension ImageParameters {
    
    // Will be removed soon
    var asImageWidth: UrlResolver.ImageWidth {
        switch self.width.value {
        case 1080:
            return .default
        case 100:
            return .thumbnail
        default:
            return .thumbnail
        }
    }
    
    
}
