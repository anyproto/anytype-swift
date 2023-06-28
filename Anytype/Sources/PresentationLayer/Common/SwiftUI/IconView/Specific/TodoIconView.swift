import SwiftUI

struct TodoIconView: View {
    
    let checked: Bool
    
    var body: some View {
        SquareView { _ in
            Image(asset: checked ? .TaskLayout.done : .TaskLayout.empty)
                .resizable()
                .foregroundColor(.Button.active)
        }
    }
}
