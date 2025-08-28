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
                    .foregroundColor(.Control.secondary)
                    .frame(width: 52, height: 52)
                    .background(Color.Background.highlightedMedium)
                    .cornerRadius(10)
                Text("")
                    .overlay {
                        AnytypeText(
                            title,
                            style: .caption2Regular
                        )
                        .foregroundColor(.Text.secondary)
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

private extension ObjectAction {

    var title: String {
        switch self {
        case .undoRedo:
            return Loc.undoRedo
        case let .archive(isArchived):
            return isArchived ? Loc.restore : Loc.toBin
        case let .pin(isPinned):
            return isPinned ? Loc.unpin : Loc.pin
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
        case .createWidget:
            return Loc.Actions.CreateWidget.title
        case .copyLink:
            return Loc.copyLink
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .undoRedo:
            return .X32.undoRedo
        case let .archive(isArchived):
            return isArchived ? .X32.restore : .X32.delete
        case let .pin(isPinned):
            return isPinned ? .X32.Favorite.unfavorite : .X32.Favorite.favorite
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
        case .createWidget:
            return .X32.dashboard
        case .copyLink:
            return .X32.copy
        }
    }
}

struct ActionObjectSettingRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectActionRow(setting: .archive(isArchived: false)) {}
    }
}

