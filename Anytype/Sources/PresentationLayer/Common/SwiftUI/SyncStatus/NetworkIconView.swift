import SwiftUI
import Services


struct NetworkIconView<T: NetworkIconProvider>: View {
    @Binding var provider: T
    @State var color: Color
    
    init(iconProvider: Binding<T>) {
        _provider = iconProvider
        _color = State(initialValue: iconProvider.wrappedValue.background.initialColor)
    }
    
    var body: some View {
        ZStack {
            Circle().frame(width: 48, height: 48)
                .foregroundStyle(color)
            Image(asset: provider.iconData.icon)
                .foregroundStyle(provider.iconData.color)
                .frame(width: 32, height: 32)
        }
        .onAppear {
            updateColor()
        }
        .onChange(of: provider.background) {
            updateColor()
        }
        .transition(.opacity)
        .animation(.default, value: provider.background)
    }
    
    private func updateColor() {
        color = provider.background.initialColor
        
        if case let .animation(_, end) = provider.background {
            withAnimation(.smooth(duration: 1).repeatForever()) {
                color = end
            }
        }
    }
}


#Preview("Syncing state") {
    MockView {
        SyncStatusStorageMock.shared.infoToReturn = [.mock(status: .syncing)]
    } content: {
        NetworkIconView(iconProvider: .constant(SpaceSyncStatusInfo.default(spaceId: "")))
    }
}
