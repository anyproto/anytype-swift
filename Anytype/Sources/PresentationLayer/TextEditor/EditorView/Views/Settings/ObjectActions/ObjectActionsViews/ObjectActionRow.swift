//
//  ObjectActionRow.swift
//  Anytype
//
//  Created by Denis Batvinkin on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


struct ObjectActionRow: View {
    let setting: ObjectAction
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        label: {
            VStack(spacing: Constants.space) {
                setting.image
                    .frame(width: 52, height: 52)
                    .background(Color.grayscale10)
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
            return isArchived ? "Restore" : "Archive"
        case let .favorite(isFavorite: isFavorite):
            return isFavorite ? "Unfavorite" : "Favorite"
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
        case .archive:
            return Image.ObjectAction.archive
        case let .favorite(isFavorite: isFavorite):
            return isFavorite ? Image.ObjectAction.unfavorite : Image.ObjectAction.favorite
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

