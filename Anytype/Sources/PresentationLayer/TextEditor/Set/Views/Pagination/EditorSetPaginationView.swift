import SwiftUI

struct EditorSetPaginationView: View {
    @ObservedObject var model: EditorSetViewModel
    let paginationData: EditorSetPaginationData
    
    var body: some View {
        VStack(spacing: 0) {
            if paginationData.pageCount >= 2 {
                content
            } else {
                EmptyView()
            }
        
            AnytypeNavigationSpacer()
        }
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            backArror
            Spacer()
            pages
            Spacer()
            forwardArror
        }
        .padding().frame(height: 60)
    }
    
    private var pages: some View {
        HStack(spacing: 24) {
            ForEach(paginationData.visiblePages, id: \.self) { counter in
                pagesButton(counter)
                    .transition(.opacity)
            }
        }
    }
    
    private func pagesButton(_ counter: Int) -> some View {
        Button(action: {
            model.changePage(counter)
        }) {
            AnytypeText(
                "\(counter)",
                style: .bodyRegular,
                color: paginationData.selectedPage == counter ? .Button.button : .Button.inactive
            )
                .frame(width: 24, height: 24)
        }
    }
    
    private var backArror: some View {
        Group {
            if paginationData.canGoBackward {
                Button(action: { model.goBackwardRow() }) {
                    Image(asset: .X18.Disclosure.left)
                        .foregroundColor(.Button.active)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var forwardArror: some View {
        Group {
            if paginationData.canGoForward {
                Button(action: { model.goForwardRow() }) {
                    Image(asset: .X18.Disclosure.right)
                        .foregroundColor(.Button.active)
                }
            } else {
                EmptyView()
            }
        }
    }
}
