import SwiftUI

struct RelationListContainerView<Content>: View where Content: View {
    @State private var searchText = ""
    
    let title: String
    let isEmpty: Bool
    let listContent: () -> Content
    let onCreate: () -> Void
    let onClear: () -> Void
    let onSearchTextChange: (_ text: String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationView
        }
        .background(Color.Background.secondary)
    }
    
    private var navigationView: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        clearButton
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                .onChange(of: searchText) { text in
                    onSearchTextChange(text)
                }
            if isEmpty {
                emptyState
            } else {
                list
            }
        }
    }
    
    private var list: some View {
        PlainList {
            listContent()
        }
        .buttonStyle(BorderlessButtonStyle())
        .bounceBehaviorBasedOnSize()
        .background(Color.Background.secondary)
    }
    
    private var clearButton: some View {
        Button {
            onClear()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
        }
    }
    
    private var addButton: some View {
        Button {
           onCreate()
        } label: {
            Image(asset: .X32.plus).foregroundColor(.Button.active)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .red)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relations.EmptyState.title, style: .uxCalloutMedium, color: .Text.primary)
            AnytypeText(Loc.Relations.EmptyState.description, style: .uxCalloutMedium, color: .Text.primary)
            Spacer.fixedHeight(12)
            StandardButton(Loc.create, style: .secondarySmall) {
                onCreate()
            }
            Spacer.fixedHeight(48)
            Spacer()
        }
    }
}
