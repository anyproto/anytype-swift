import BlocksModels

extension BlockDataview {
    func groupByRelations(for activeView: DataviewView) -> [RelationMetadata] {
        let relations: [RelationMetadata] = relations.filter { relation in
            if relation.key == BundledRelationKey.done.rawValue {
                return true
            }
            
            let hasOption = activeView.options.first(where: { option in option.key == relation.key }) != nil
            if relation.isHidden || !hasOption {
                return false
            }
            
            switch relation.format {
            case .status, .tag, .checkbox:
                return true
            default:
                return false
            }
        }
        return relations
    }
}
