import SwiftUI

struct RelationListContainerView<Content>: View where Content: View {
    @State private var searchText = ""
    
    let title: String
    let isEditable: Bool
    let isEmpty: Bool
    let hideClear: Bool
    let listContent: () -> Content
    let onCreate: (_ title: String?) -> Void
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
                .if(isEditable, transform: {
                    $0.toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if !hideClear {
                                clearButton
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            createButton
                        }
                    }
                })
        }
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            if isEditable {
                SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                    .onChange(of: searchText) { text in
                        onSearchTextChange(text)
                    }
            }
            
            if isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color.Background.secondary)
    }
    
    private var list: some View {
        PlainList {
            listContent()
            if searchText.isNotEmpty {
                createRow
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .bounceBehaviorBasedOnSize()
        .disabled(!isEditable)
    }
    
    private var clearButton: some View {
        Button {
            onClear()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
        }
    }
    
    private var createButton: some View {
        Button {
            onCreate(nil)
        } label: {
            Image(asset: .X32.plus).foregroundColor(.Button.active)
        }
    }
    
    private var createRow: some View {
        Button {
            onCreate(searchText)
        } label: {
            HStack(spacing: 10) {
                Image(asset: .X32.plus).foregroundColor(.Button.active)
                AnytypeText(Loc.Relation.Create.Row.title(searchText), style: .uxBodyRegular, color: .Text.primary)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var emptyState: some View {
        if isEditable {
            defaultEmptyState
        } else {
            blockedEmptyState
        }
    }
    
    private var defaultEmptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .red)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relation.EmptyState.title, style: .uxCalloutMedium, color: .Text.primary)
            AnytypeText(Loc.Relation.EmptyState.description, style: .uxCalloutRegular, color: .Text.primary)
            Spacer.fixedHeight(12)
            StandardButton(Loc.create, style: .secondarySmall) {
                onCreate(nil)
            }
            .disabled(!isEditable)
            Spacer.fixedHeight(48)
            Spacer()
        }
    }
    
    private var blockedEmptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .red)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relation.EmptyState.Blocked.title, style: .uxCalloutMedium, color: .Text.primary)
            Spacer()
        }
    }
}
