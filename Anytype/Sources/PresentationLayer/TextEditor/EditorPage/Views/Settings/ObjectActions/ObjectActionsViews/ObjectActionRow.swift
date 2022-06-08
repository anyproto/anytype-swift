import SwiftUI


struct ObjectActionRow: View {
    let setting: ObjectAction
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
            UISelectionFeedbackGenerator().selectionChanged()
        }
        label: {
            VStack(spacing: Constants.space) {
                setting.image
                    .frame(width: 52, height: 52)
                    .background(Color.backgroundSelected)
                    .cornerRadius(10)
                AnytypeText(
                    setting.title,
                    style: .caption2Regular,
                    color: .textSecondary
                )
            }
        }
    }

    private enum Constants {
        static let space: CGFloat = 5
    }
}

private extension ObjectAction {

    var title: String {
        switch self {
        case .undoRedo:
            return "Undo/Redo".localized
        case let .archive(isArchived):
            return isArchived ? "Restore".localized : "To Bin".localized
        case let .favorite(isFavorite):
            return isFavorite ? "Unfavorite".localized : "Favorite".localized
        case let .locked(isLocked):
            return isLocked ? "Unlock".localized : "Lock".localized
        case .duplicate:
            return "Duplicate".localized
        }
    }

    var image: Image {
        switch self {
        case .undoRedo:
            return .ObjectAction.undoRedo
        case let .archive(isArchived):
            return isArchived ? .ObjectAction.restore : .ObjectAction.archive
        case let .favorite(isFavorite):
            return isFavorite ? .ObjectAction.unfavorite : .ObjectAction.favorite
        case let .locked(isLocked):
            return isLocked ? .ObjectAction.unlock : .ObjectAction.lock
        case .duplicate:
            return .ObjectAction.duplicate
        }
    }
}

struct ActionObjectSettingRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectActionRow(setting: .archive(isArchived: false)) {}
    }
}

