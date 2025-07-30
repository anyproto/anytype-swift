import SwiftUI

struct SharingExtensionView: View {
    
    @StateObject private var model = SharingExtensionViewModel()
    
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
            
            listView
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
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 16)
    }
}

#Preview {
    MockView {
        SharingExtensionView()
    }
}
