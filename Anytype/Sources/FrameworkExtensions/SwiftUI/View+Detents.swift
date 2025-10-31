import SwiftUI

struct FitPresentationDetentsViewModifier: ViewModifier {

    @State private var height: CGFloat = 100

     func body(content: Content) -> some View {
        bodyDetents(content: content)
             .presentationCornerRadius(16)
     }

     private func bodyDetents(content: Content) -> some View {
         VStack(spacing: 0) {
             content.readSize { size in
                 height = size.height
             }
             Spacer(minLength: 0)
         }
         .presentationDetents([.height(height)])
     }
}


extension View {
    func fitPresentationDetents() -> some View {
         modifier(FitPresentationDetentsViewModifier())
     }
}

struct MediumPresentationDetentsViewModifier: ViewModifier {

    func body(content: Content) -> some View {
        bodyDetents(content: content)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(16)
     }

    private func bodyDetents(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            Spacer(minLength: 0)
        }
    }
}

extension View {
    func mediumPresentationDetents() -> some View {
         modifier(MediumPresentationDetentsViewModifier())
     }
}


