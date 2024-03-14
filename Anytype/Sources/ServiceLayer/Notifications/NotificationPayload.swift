import Foundation
import ProtobufMessages
import Services

enum NotificationPayload {
    case galleryImport(NotificationGalleryImport)
    case participantRequestApproved(NotificationParticipantRequestApproved)
    case requestToLeave(NotificationRequestToLeave)
    case participantRemove(NotificationParticipantRemove)
    case participantRequestDecline(NotificationParticipantRequestDecline)
    case participantPermissionsChange(NotificationParticipantPermissionsChange)

    case undefined
}

struct NotificationGalleryImport {
    public let common: Services.Notification
    public let galleryImport: Anytype_Model_Notification.GalleryImport
}

struct NotificationParticipantRequestApproved {
    public let common: Services.Notification
    public let requestApprove: Anytype_Model_Notification.ParticipantRequestApproved
}

struct NotificationRequestToLeave {
    public let common: Services.Notification
    public let requestToLeave: Anytype_Model_Notification.RequestToLeave
}

struct NotificationParticipantRemove {
    public let common: Services.Notification
    public let remove: Anytype_Model_Notification.ParticipantRemove
}

struct NotificationParticipantRequestDecline {
    public let common: Services.Notification
    public let requestDecline: Anytype_Model_Notification.ParticipantRequestDecline
}

struct NotificationParticipantPermissionsChange {
    public let common: Services.Notification
    public let permissionChange: Anytype_Model_Notification.ParticipantPermissionsChange
}
