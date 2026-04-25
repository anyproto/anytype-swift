import Foundation
import SwiftUI

struct MyFavoritesRowContextMenu: View {
    let model: MyFavoritesRowContextMenuViewModel

    var body: some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                model.onFavoriteTap()
            }
        } label: {
            Text(Loc.unfavorite)
            Image(systemName: "star.fill")
        }

        if model.canManageChannelPins() {
            let isPinnedToChannel = model.isPinnedToChannel()
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    model.onChannelPinTap()
                }
            } label: {
                Text(isPinnedToChannel ? Loc.unpinFromChannel : Loc.pinToChannel)
                Image(systemName: isPinnedToChannel ? "pin.slash" : "pin")
            }
        }
    }
}
