// MARK: - Resource
extension UnknownLabelViewModel {
    struct Resource: CustomStringConvertible {
        var description: String {
            "\(self.blockType) -> \(self.blockName)"
        }
        
        let blockName: String
        let blockType: String
    }
}
