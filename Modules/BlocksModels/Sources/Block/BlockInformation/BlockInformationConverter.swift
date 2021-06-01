/// What happens here?
/// We convert details ( PageDetails ) to ready-to-use information.
struct DetailsAsInformationConverter {
    
    var blockId: BlockId

    private func detailsAsInformation(_ blockId: BlockId, _ details: DetailsEntry<AnyHashable>) -> BlockInformationModel {
        /// Our ID is <ID>/<Details.key>.
        /// Look at implementation in `IdentifierBuilder`
        
        let id = DetailsAsBlockConverter.IdentifierBuilder.asBlockId(blockId, details.id)

        /// Actually, we don't care about block type.
        /// We only take care about "distinct" block model.
        let content: BlockContent = .text(.empty())
        return BlockInformationModel(id: id, content: content)
    }

    func callAsFunction(_ details: DetailsEntry<AnyHashable>) -> BlockInformationModel {
        detailsAsInformation(self.blockId, details)
    }
}

/// We need this converter to convert our details into a block.
/// First, we convert them to an Information structure.
/// Then, we convert it to block.
///
/// Why do we need it?
/// We need it to get block and later configure blocks views with this block and then render them.
///
public struct DetailsAsBlockConverter {
    
    // MARK: - Private variables
    
    private let blockId: BlockId

    // MARK: - Initializer
    
    public init(blockId: BlockId) {
        self.blockId = blockId
    }
    
    // MARK: - Public functions
    
    public func convertDetailsToBlock(_ details: DetailsEntry<AnyHashable>) -> BlockModelProtocol {
        TopLevelBuilder.blockBuilder.createBlockModel(
            with: DetailsAsInformationConverter(blockId: self.blockId)(details)
        )
    }
    
}

/// TODO: Time to remove Details Crutches. ?????????????
public extension DetailsAsBlockConverter {
    struct IdentifierBuilder {
        
        static var separator: Character = "/"
        public static func asBlockId(_ blockId: BlockId, _ id: ParentId) -> BlockId {
            blockId + "\(self.separator)" + id
        }
        public static func asDetails(_ id: BlockId) -> (BlockId, ParentId) {
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
