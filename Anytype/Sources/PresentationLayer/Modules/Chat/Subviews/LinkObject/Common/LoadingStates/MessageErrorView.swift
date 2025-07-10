import SwiftUI

struct MessageErrorView: View {
    var body: some View {
        MessageLoadingStateContainer {
            Image(asset: .CustomIcons.alert)
                .resizable()
                .foregroundStyle(Color.Control.white)
        }
        .background(.black.opacity(0.5))
    }
}

#Preview {
    MessageErrorView()
        .frame(width: 48, height: 48)
    MessageErrorView()
        .frame(width: 100, height: 100)
}
