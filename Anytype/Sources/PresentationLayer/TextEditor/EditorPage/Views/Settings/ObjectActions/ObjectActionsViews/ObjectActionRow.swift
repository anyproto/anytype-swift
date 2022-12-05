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
                Image(asset: setting.imageAsset)
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
            return Loc.undoRedo
        case let .archive(isArchived):
            return isArchived ? Loc.restore : Loc.toBin
        case let .favorite(isFavorite):
            return isFavorite ? Loc.unfavorite : Loc.favorite
        case let .locked(isLocked):
            return isLocked ? Loc.unlock : Loc.lock
        case .duplicate:
            return Loc.duplicate
        case .linkItself:
            return Loc.Actions.linkItself
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .undoRedo:
            return .undoredo
        case let .archive(isArchived):
            return isArchived ? .restore : .delete
        case let .favorite(isFavorite):
            return isFavorite ? .unfavorite : .addToFavorites
        case let .locked(isLocked):
            return isLocked ? .unlock : .lock
        case .duplicate:
            return .duplicate
        case .linkItself:
            return .linkToItself
        }
    }
}

struct ActionObjectSettingRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectActionRow(setting: .archive(isArchived: false)) {}
    }
}

