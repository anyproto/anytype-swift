import Foundation
import Services

extension Array where Element == ParticipantSpaceViewDataWithPreview {
    // The Space Hub's display order: pinned spaces by their pin order, the rest by
    // most recent activity (last message or join, whichever is later). Shared so
    // every space list (hub, search channels, person ordering) sorts identically.
    func sortedForSpaceHub() -> [ParticipantSpaceViewDataWithPreview] {
        sorted(by: Self.spaceHubOrder)
    }

    private static func spaceHubOrder(_ lhs: ParticipantSpaceViewDataWithPreview, _ rhs: ParticipantSpaceViewDataWithPreview) -> Bool {
        switch (lhs.spaceView.isPinned, rhs.spaceView.isPinned) {
        case (true, true):
            return lhs.spaceView.spaceOrder < rhs.spaceView.spaceOrder
        case (true, false):
            return true
        case (false, true):
            return false
        case (false, false):
            let lhsMessageDate = lhs.latestPreview.lastMessage?.createdAt
            let rhsMessageDate = rhs.latestPreview.lastMessage?.createdAt
            let lhsJoinDate = lhs.spaceView.joinDate
            let rhsJoinDate = rhs.spaceView.joinDate

            // Determine effective date for lhs (use joinDate if no message, or more recent of the two)
            let lhsEffectiveDate: Date? = {
                switch (lhsMessageDate, lhsJoinDate) {
                case let (messageDate?, joinDate?):
                    return Swift.max(messageDate, joinDate)
                case (let messageDate?, nil):
                    return messageDate
                case (nil, let joinDate?):
                    return joinDate
                case (nil, nil):
                    return nil
                }
            }()

            // Determine effective date for rhs (use joinDate if no message, or more recent of the two)
            let rhsEffectiveDate: Date? = {
                switch (rhsMessageDate, rhsJoinDate) {
                case let (messageDate?, joinDate?):
                    return Swift.max(messageDate, joinDate)
                case (let messageDate?, nil):
                    return messageDate
                case (nil, let joinDate?):
                    return joinDate
                case (nil, nil):
                    return nil
                }
            }()

            switch (lhsEffectiveDate, rhsEffectiveDate) {
            case let (date1?, date2?):
                return date1 > date2
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                let lhsCreatedDate = lhs.spaceView.createdDate ?? .distantPast
                let rhsCreatedDate = rhs.spaceView.createdDate ?? .distantPast
                return lhsCreatedDate > rhsCreatedDate
            }
        }
    }
}
