import Services

final class AttachmentsTextInfoBuilder {
    static func localizedAttachmentsText(attachments: [ObjectDetails]) -> String {
        guard attachments.allHaveSameValue(\.resolvedLayoutValue) else {
            return localizedAttachmentsTextForMixedLayouts(attachments: attachments)
        }
        
        guard let firstAttachment = attachments.first else { return "" }
        let count = attachments.count
        
        switch firstAttachment.resolvedLayoutValue {
        case .basic, .profile, .todo, .note:
            if count == 1 {
                return firstAttachment.title
            } else {
                return Loc.object(count)
            }
        case .set, .collection:
            if count == 1 {
                return firstAttachment.title
            } else {
                return Loc.list(count)
            }
        case .objectType:
            return Loc.objectType(count)
        case .relation:
            return Loc.relation(count)
        case .file:
            return Loc.file(count)
        case .image:
            return Loc.image(count)
        case .bookmark:
            return Loc.bookmark(count)
        case .audio:
            return Loc.audio(count)
        case .video:
            return Loc.video(count)
        case .date:
            return Loc.date(count)
        case .pdf:
            return Loc.pdf(count)
        case .tag:
            return Loc.tag(count)
        case .UNRECOGNIZED, .dashboard, .space, .relationOptionsList, .relationOption, .spaceView, .participant, .chat, .chatDerived:
            return Loc.attachment(count)
        }
    }
    
    private static func localizedAttachmentsTextForMixedLayouts(attachments: [ObjectDetails]) -> String {
        if attachments.allSatisfy({ DetailsLayout.editorLayouts.contains($0.resolvedLayoutValue) }) {
            return Loc.object(attachments.count)
        } else if attachments.allSatisfy({ DetailsLayout.listLayouts.contains($0.resolvedLayoutValue) }) {
            return Loc.list(attachments.count)
        } else if attachments.allSatisfy({ (DetailsLayout.editorLayouts + DetailsLayout.listLayouts).contains($0.resolvedLayoutValue) }) {
            return Loc.object(attachments.count)
        }
        
        return Loc.attachment(attachments.count)
    }
}


fileprivate extension Array where Element: Equatable {
    func allHaveSameValue<T: Equatable>(_ keyPath: KeyPath<Element, T>) -> Bool {
        guard let firstValue = first?[keyPath: keyPath] else {
            return true
        }
        
        return allSatisfy { $0[keyPath: keyPath] == firstValue }
    }
}
