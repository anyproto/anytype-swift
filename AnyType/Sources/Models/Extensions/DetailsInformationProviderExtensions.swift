import BlocksModels

extension DetailsEntryValueProvider {
    
    var documentIcon: DocumentIcon? {
        if let iconImageId = self.value(for: .iconImage), !iconImageId.isEmpty {
            return DocumentIcon.imageId(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.value(for: .iconEmoji)) {
            return DocumentIcon.emoji(iconEmoji)
        }
        
        return nil
    }
}
