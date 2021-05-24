import BlocksModels

extension DetailsEntryValueProvider {
    
    var documentIcon: DocumentIcon? {
        if let iconImageId = self[.iconImage], !iconImageId.isEmpty {
            return DocumentIcon.imageId(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self[.iconEmoji]) {
            return DocumentIcon.emoji(iconEmoji)
        }
        
        return nil
    }
}
