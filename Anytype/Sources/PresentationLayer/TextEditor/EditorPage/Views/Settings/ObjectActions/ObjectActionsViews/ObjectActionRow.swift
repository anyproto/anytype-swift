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
        case let .archive(isArchived: isArchived):
            return isArchived ? "Restore".localized : "Delete".localized
        case let .favorite(isFavorite: isFavorite):
            return isFavorite ? "Unfavorite".localized : "Favorite".localized
//        case .moveTo:
//            return "Move to"
//        case .template:
//            return "Template"
//        case .search:
//            return "Search"
        }
    }

    var image: Image {
        switch self {
        case let .archive(isArchived: isArchived):
            return isArchived ? .ObjectAction.restore : .ObjectAction.archive
        case let .favorite(isFavorite: isFavorite):
            return isFavorite ? .ObjectAction.unfavorite : .ObjectAction.favorite
//        case .moveTo:
//            return Image.ObjectAction.moveTo
//        case .template:
//            return Image.ObjectAction.template
//        case .search:
//            return Image.ObjectAction.search
        }
    }
}

struct ActionObjectSettingRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectActionRow(setting: .archive(isArchived: false)) {}
    }
}

