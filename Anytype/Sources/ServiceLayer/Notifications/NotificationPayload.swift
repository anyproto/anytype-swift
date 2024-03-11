import Foundation
import ProtobufMessages
import Services

public enum NotificationPayload {
    case `import`(NotificationImport)
    case export(NotificationExport)
    case galleryImport(NotificationGalleryImport)
    case undefined
}

public struct NotificationGalleryImport {
    public let common: Services.Notification
    public let galleryImport: Anytype_Model_Notification.GalleryImport
}

public struct NotificationExport {
    public let common: Services.Notification
    public let export: Anytype_Model_Notification.Export
}

public struct NotificationImport {
    public let common: Services.Notification
    public let `import`: Anytype_Model_Notification.Import
}
