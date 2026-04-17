import SwiftUI


struct ObjectActionRow: View {
    let title: String
    let icon: ImageAsset
    let onTap: () async throws -> Void

    var body: some View {
        AsyncButton {
            try await onTap()
            UISelectionFeedbackGenerator().selectionChanged()
        }
        label: {
            VStack(spacing: Constants.space) {
                Image(asset: icon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 52, height: 52)
                    .background(Color.Background.highlightedMedium)
                    .clipShape(.rect(cornerRadius: 10))
                Text("")
                    .overlay {
                        AnytypeText(
                            title,
                            style: .caption2Regular
                        )
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 72)
                        .fixedSize()
                    }
            }
        }
        .frame(height: 108)
    }

    private enum Constants {
        static let space: CGFloat = 5
    }
}

extension ObjectActionRow {
    init(setting: ObjectAction, onTap: @escaping () async throws -> Void) {
        self = ObjectActionRow(title: setting.title, icon: setting.imageAsset, onTap: onTap)
    }
}

extension ObjectAction {

    var title: String {
        switch self {
        case .undoRedo:
            return Loc.undoRedo
        case let .archive(isArchived):
            return isArchived ? Loc.restore : Loc.delete
        case let .pin(isPinned):
            return isPinned ? Loc.unpinFromChannel : Loc.pinToChannel
        case let .favorite(isFavorited):
            return isFavorited ? Loc.unfavorite : Loc.favorite
        case let .locked(isLocked):
            return isLocked ? Loc.unlock : Loc.lock
        case .duplicate:
            return Loc.duplicate
        case .linkItself:
            return Loc.Actions.linkItself
        case .makeAsTemplate:
            return Loc.Actions.makeAsTemplate
        case .templateToggleDefaultState(let isDefault):
            return isDefault ? Loc.unsetDefault : Loc.Actions.templateMakeDefault
        case .delete:
            return Loc.delete
        case .copyLink:
            return Loc.copyInviteLink
        case .inviteMembers:
            return Loc.Chat.inviteMembers
        case .editInfo:
            return Loc.editInfo
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .undoRedo:
            return .X32.undoRedo
        case let .archive(isArchived):
            return isArchived ? .X32.restore : .X32.delete
        case .pin, .favorite:
            // Neutral fallback — `.pin` and `.favorite` are rendered via `menuIcon`
            // (SF Symbols) in `ObjectSettingsMenuView`, which is the only runtime
            // surface. The rail asset only appears in the SwiftUI preview below.
            // Dedicated X32.pin / X32.pin.slash / X32.star assets are a
            // design-system follow-up (plan Addendum A).
            return .X32.Favorite.favorite
        case let .locked(isLocked):
            return isLocked ? .X32.Lock.unlock : .X32.Lock.lock
        case .duplicate:
            return .X32.duplicate
        case .linkItself:
            return .X32.linkTo
        case .makeAsTemplate:
            return .makeAsTemplate
        case .templateToggleDefaultState(let isDefault):
            return isDefault ? .X32.Favorite.unfavorite : .X32.Favorite.favorite
        case .delete:
            return .X32.delete
        case .copyLink:
            return .X32.copy
        case .inviteMembers:
            return .X32.Island.addMember
        case .editInfo:
            return .X32.edit
        }
    }

    var menuIcon: MenuIcon {
        switch self {
        case .editInfo:
            return .system("pencil")
        case .pin(false):
            return .system("pin")
        case .pin(true):
            return .system("pin.slash")
        case .favorite(false):
            return .system("star")
        case .favorite(true):
            return .system("star.fill")
        case .copyLink:
            return .system("link")
        case .archive(false):
            return .system("trash")
        default:
            return .asset(imageAsset)
        }
    }
}

struct ActionObjectSettingRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectActionRow(setting: .archive(isArchived: false)) {}
    }
}

