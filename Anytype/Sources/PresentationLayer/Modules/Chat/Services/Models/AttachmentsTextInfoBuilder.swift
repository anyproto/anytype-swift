import Services

final class AttachmentsTextInfoBuilder {
    static func localizedAttachmentsText(attachments: [ObjectDetails]) -> String {
        // TBD: real implementation
        switch attachments.count {
        case 0:
            ""
        case 1:
            "Attachement"
        default:
            "\(attachments.count) Attachements"
        }
    }
}
