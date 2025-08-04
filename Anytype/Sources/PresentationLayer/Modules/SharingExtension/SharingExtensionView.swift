import SwiftUI

struct SharingExtensionView: View {
    
    @StateObject private var model: SharingExtensionViewModel
    
    init(output: SharingExtensionModuleOutput?) {
        self._model = StateObject(wrappedValue: SharingExtensionViewModel(output: output))
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                EmptyView()
            }
            .frame(height: 48)
            .padding(.horizontal, 16)
            
            ZStack(alignment: .bottom) {
                listView
                    .safeAreaInset(edge: .bottom) {
                        Spacer.fixedHeight(100)
                    }
                confirmButton
            }
        }
        .task {
            await model.onAppear()
        }
    }
    
    private var listView: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(model.spaces) { space in
                    Button {
                        model.onTapSpace(space)
                    } label: {
                        SharingExtensionSpaceView(
                            icon: space.objectIconImage,
                            title: space.title,
                            isSelected: model.selectedSpace?.id == space.id
                        )
                    }
                }
            }
            if let debugItems = model.debugInfo?.items {
                Section(header: Text(Loc.Debug.info)) {
                    ForEach(0..<debugItems.count, id: \.self) { index in
                        SharingExtensionDebugView(
                            index: index,
                            mimeTypes: debugItems[index].mimeTypes
                        )
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var confirmButton: some View {
        if model.selectedSpace != nil {
            AsyncStandardButton(Loc.send, style: .primaryLarge) {
                try await model.onTapSend()
            }
            .padding(16)
            .background(Color.Background.secondary)
        }
    }
}

#Preview {
    MockView {
        SharingExtensionView(output: nil)
    }
}
