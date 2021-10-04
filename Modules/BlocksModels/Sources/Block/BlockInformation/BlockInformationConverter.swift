/// TODO: Time to remove Details Crutches. ?????????????
public struct DetailsAsBlockConverter {
    public struct IdentifierBuilder {
        
        static var separator: Character = "/"
        public static func asBlockId(_ blockId: BlockId, _ id: BlockId) -> BlockId {
            blockId + "\(self.separator)" + id
        }
        public static func asDetails(_ id: BlockId) -> (BlockId, BlockId) {
            guard let index = id.lastIndex(of: self.separator) else { return (id, "") }
            let substring = id[index...].dropFirst()
            let prefix = String(id.prefix(upTo: index))
            switch DetailsKind(rawValue: String(substring)) {
            case .name: return (prefix, DetailsKind.name.rawValue)
            case .iconEmoji: return (prefix, DetailsKind.iconEmoji.rawValue)
            default: return ("", "")
            }
        }
    }
}
