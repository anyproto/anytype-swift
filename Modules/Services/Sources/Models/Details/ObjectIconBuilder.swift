import AnytypeCore

public protocol ObjectIconBuilderProtocol {
    func objectIcon(relations: BundledRelationsValueProvider) -> ObjectIcon
    func profileIcon(iconImage: String, objectName: String) -> ObjectIcon?
}

public final class ObjectIconBuilder: ObjectIconBuilderProtocol {
    public init() { }
    
    public func objectIcon(relations: BundledRelationsValueProvider) -> ObjectIcon {
        guard !relations.isDeleted else {
            return .deleted
        }
        
        if let objectIcon = icon(relations: relations) {
            return objectIcon
        }
        
        if relations.layoutValue.isFileOrMedia {
            return fileIcon(
                fileMimeType: relations.fileMimeType,
                name: FileDetails.formattedFileName(relations.name, fileExt: relations.fileExt)
            )
        }
        
        if relations.layoutValue == .todo {
            return .todo(relations.isDone, relations.id)
        }
        
        return .empty(emptyIconType(layoutValue: relations.layoutValue))
    }
    
    public func profileIcon(iconImage: String, objectName: String) -> ObjectIcon? {
        if iconImage.isNotEmpty {
            return .profile(.imageId(iconImage))
        }
        
        return .profile(.name(objectName))
    }
    
    // MARK: - Private
    
    private func icon(relations: BundledRelationsValueProvider) -> ObjectIcon? {
        switch relations.layoutValue {
        case .basic, .set, .collection, .image, .chat:
            return basicIcon(iconImage: relations.iconImage, iconEmoji: relations.iconEmoji)
        case .profile, .participant:
            return profileIcon(iconImage: relations.iconImage, objectName: relations.objectName)
        case .bookmark:
            return bookmarkIcon(iconImage: relations.iconImage)
        case .todo, .note, .file, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList,
                .audio, .video, .pdf, .date, .tag, .chatDerived:
            return nil
        case .space, .spaceView:
            return spaceIcon(iconImage: relations.iconImage, iconOption: relations.iconOption, objectName: relations.objectName)
        case .objectType:
            return objectTypeIcon(customIcon: relations.customIcon, customIconColor: relations.customIconColor, iconImage: relations.iconImage, iconEmoji: relations.iconEmoji)
        }
    }
    
    private func basicIcon(iconImage: String, iconEmoji: Emoji?) -> ObjectIcon? {
        if iconImage.isNotEmpty {
            return .basic(iconImage)
        }
        
        if let iconEmoji = iconEmoji {
            return .emoji(iconEmoji)
        }
        
        return nil
    }
    
    private func bookmarkIcon(iconImage: String) -> ObjectIcon? {
        return iconImage.isNotEmpty ? .bookmark(iconImage) : nil
    }
    
    private func spaceIcon(iconImage: String, iconOption: Int?, objectName: String) -> ObjectIcon? {
        if iconImage.isNotEmpty {
            return .space(.imageId(iconImage))
        }
        
        return .space(.name(name: objectName, iconOption: iconOption ?? 1))
    }
    
    private func fileIcon(fileMimeType: String, name: String) -> ObjectIcon {
        return .file(mimeType: fileMimeType, name: name)
    }
    
    private func objectTypeIcon(customIcon: CustomIcon?, customIconColor: CustomIconColor?, iconImage: String, iconEmoji: Emoji?) -> ObjectIcon? {
        if FeatureFlags.newTypeIcons, let customIcon {
            return .customIcon(customIcon, customIconColor ?? CustomIconColor.default)
        }
        
        return basicIcon(iconImage: iconImage, iconEmoji: iconEmoji)
    }
    
    private func emptyIconType(layoutValue: DetailsLayout) -> ObjectIcon.EmptyType {
        switch layoutValue {
        case .basic, .profile, .participant, .todo, .note, .space, .file, .image, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .spaceView:
            return .page
        case .set, .collection:
            return .list
        case .bookmark:
            return .bookmark
        case .chat, .chatDerived:
            return .chat
        case .objectType:
            return .objectType
        case .tag:
            return .tag
        case .date:
            return .date
        }
    }
}
