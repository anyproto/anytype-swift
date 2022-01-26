import SwiftUI

struct EditorSetPaginationView: View {
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                backArror
                Spacer()
                pages
                Spacer()
                forwardArror
            }
            .padding().frame(height: 60)
            
            Rectangle().frame(height: 40).foregroundColor(.backgroundPrimary) // Navigation view stub
        }
    }
    
    private var pages: some View {
        HStack(spacing: 24) {
            ForEach(model.pagitationData.visiblePages, id: \.self) { counter in
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
                style: .body,
                color: model.pagitationData.selectedPage == counter ? .buttonSelected : .buttonInactive
            )
                .frame(width: 24, height: 24)
        }
    }
    
    private var backArror: some View {
        Group {
            if model.pagitationData.canGoBackward {
                Button(action: { model.goBackwardPage() }) {
                    Image.set.back
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var forwardArror: some View {
        Group {
            if model.pagitationData.canGoForward {
                Button(action: { model.goForwardPage() }) {
                    Image.set.forward
                }
            } else {
                EmptyView()
            }
        }
    }
}
