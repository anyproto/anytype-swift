import Foundation

public extension BundledRelationsValueProvider {
    
    var objectIcon: ObjectIcon? {
        guard !isDeleted else {
            return .deleted
        }
        
        if let icon = icon {
            return icon
        }
        
        if DetailsLayout.fileLayouts.contains(layoutValue) {
            return fileIcon
        }
        
        if layoutValue == .todo {
            return .todo(isDone, id)
        }
        
        return nil
    }
    
    private var icon: ObjectIcon? {
        switch layoutValue {
        case .basic, .set, .collection, .image, .objectType:
            return basicIcon
        case .profile, .participant:
            return profileIcon
        case .bookmark:
            return bookmarkIcon
        case .todo, .note, .file, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList,
                .audio, .video, .pdf, .date:
            return nil
        case .space, .spaceView:
            return spaceIcon
        }
    }
    private var basicIcon: ObjectIcon? {
        if iconImage.isNotEmpty {
            return .basic(iconImage)
        }
        
        if let iconEmoji = self.iconEmoji {
            return .emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: ObjectIcon? {
        if iconImage.isNotEmpty {
            return .profile(.imageId(iconImage))
        }
        
        return .profile(.name(objectName))
    }
    
    private var bookmarkIcon: ObjectIcon? {
        return iconImage.isNotEmpty ? .bookmark(iconImage) : nil
    }
    
    private var spaceIcon: ObjectIcon? {
        if iconImage.isNotEmpty {
            return .space(.imageId(iconImage))
        }
        
        if let iconOptionValue {
            return .space(.gradient(iconOptionValue))
        }
        
        return .space(.name(objectName))
    }
    
    private var fileIcon: ObjectIcon {
        return .file(mimeType: fileMimeType, name: name)
    }
}
