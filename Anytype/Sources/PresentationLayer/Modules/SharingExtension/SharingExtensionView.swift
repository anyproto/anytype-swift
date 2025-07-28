import SwiftUI

struct SharingExtensionView: View {
    
    @State private var tab: SharingExtensionTabs = .chat
    @StateObject private var model = SharingExtensionViewModel()
    
    var body: some View {
        VStack {
            DragIndicator()
            NavigationHeaderContainer(spacing: 20) {
                EmptyView()
            } titleView: {
                AnytypeText(Loc.Sharing.title, style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
            } rightView: {
                Image(asset: .X32.search)
                    .foregroundStyle(Color.Control.secondary)
            }
            .frame(height: 48)
            .padding(.horizontal, 16)
            
            Picker("", selection: $tab) {
                ForEach(SharingExtensionTabs.allCases, id:\.self) {
                    Text($0.title)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            
            tabView
        }
        .task {
            await model.onAppear()
        }
    }
    
    private var tabView: some View {
        ZStack {
            SharingExtensionChatView(spaces: model.spacesWithChat)
                .opacity(tab == .chat ? 1 : 0)
        }
    }
}

#Preview {
    MockView {
        SharingExtensionView()
    }
}
