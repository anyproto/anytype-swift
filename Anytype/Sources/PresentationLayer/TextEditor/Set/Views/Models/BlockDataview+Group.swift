import Services

extension BlockDataview {
    func groupByRelations(for activeView: DataviewView, dataViewRelationsDetails: [PropertyDetails]) -> [PropertyDetails] {
        let relations: [PropertyDetails] = dataViewRelationsDetails.filter { relation in
            if relation.key == BundledPropertyKey.done.rawValue {
                return true
            }
            
            let hasOption = activeView.options.first(where: { option in option.key == relation.key }) != nil
            if relation.isHidden || relation.isDeleted || !hasOption {
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
