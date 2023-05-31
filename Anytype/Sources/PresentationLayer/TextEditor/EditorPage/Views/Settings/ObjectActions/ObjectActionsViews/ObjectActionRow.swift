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
                    .foregroundColor(.Button.active)
                    .frame(width: 52, height: 52)
                    .background(Color.Background.highlightedOfSelected)
                    .cornerRadius(10)
                AnytypeText(
                    setting.title,
                    style: .caption2Regular,
                    color: .Text.secondary
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
            return .X32.undoRedo
        case let .archive(isArchived):
            return isArchived ? .X32.restore : .X32.delete
        case let .favorite(isFavorite):
            return isFavorite ? .X32.Favorite.favorite : .X32.Favorite.unfavorite
        case let .locked(isLocked):
            return isLocked ? .X32.Lock.unlock : .X32.Lock.lock
        case .duplicate:
            return .X32.duplicate
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

