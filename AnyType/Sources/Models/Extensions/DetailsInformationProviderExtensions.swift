import BlocksModels

extension DetailsInformationProvider {
    
    var documentIcon: DocumentIcon? {
        if let iconImageId = self.iconImage?.value, !iconImageId.isEmpty {
            return DocumentIcon.imageId(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji?.value) {
            return DocumentIcon.emoji(iconEmoji)
        }
        
        return nil
    }
}
