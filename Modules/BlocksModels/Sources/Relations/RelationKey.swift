import Foundation

// Getters are located in ObjectDetails+Relations
public enum RelationKey: String {
    case id = "id"
    case name = "name"
    case iconEmoji = "iconEmoji"
    case iconImage = "iconImage"
    case coverId = "coverId"
    case coverType = "coverType"
    case isFavorite = "isFavorite"
    case description = "description"
    case layout = "layout"
    case layoutAlign = "layoutAlign"
    case done = "done"
    case type = "type"
    case lastOpenedDate = "lastOpenedDate"
    case lastModifiedDate = "lastModifiedDate"
    case featuredRelations = "featuredRelations"
    case relationFormat = "relationFormat"
    
    case isDeleted
    case isArchived = "isArchived"
    case isHidden = "isHidden"
    case isReadonly = "isReadonly"
    case isDraft = "isDraft"
}
