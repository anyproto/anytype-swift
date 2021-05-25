import BlocksModels

extension DetailsEntryValueProvider {
    
    var documentIcon: DocumentIcon? {
        if let iconImageId = self.iconImage, !iconImageId.isEmpty {
            return DocumentIcon.imageId(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji) {
            return DocumentIcon.emoji(iconEmoji)
        }
        
        return nil
    }
    
    var documentCover: DocumentCover? {
        guard
            let coverType = coverType,
            let coverId = coverId, !coverId.isEmpty
        else { return nil }
        
        switch coverType {
        case .none:
            return nil
        case .uploadedImage:
            return DocumentCover.imageId(coverId)
        case .color:
            return nil
        case .gradient:
            return nil
        case .bundledImage:
            return nil
        }
    }
    
}
