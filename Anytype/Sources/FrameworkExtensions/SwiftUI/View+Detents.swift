import SwiftUI

struct FitPresentationDetentsViewModifier: ViewModifier {
    
    @State private var height: CGFloat = 100

     func body(content: Content) -> some View {
         if #available(iOS 16.4, *) {
            bodyDetents(content: content)
                 .presentationCornerRadius(16)
         } else if #available(iOS 16.0, *) {
             bodyDetents(content: content)
         } else {
             VStack(spacing: 0) {
                 content
                 Spacer(minLength: 0)
             }
         }
     }

     @available(iOS 16.0, *)
     private func bodyDetents(content: Content) -> some View {
         VStack(spacing: 0) {
             content.readSize { size in
                 height = size.height
             }
             .frame(height: height)
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
         if #available(iOS 16.4, *) {
             content
                 .presentationDetents([.medium, .large])
                 .presentationCornerRadius(16)
                 .presentationDragIndicator(.hidden)
         } else if #available(iOS 16.0, *) {
             content
                 .presentationDetents([.medium, .large])
                 .presentationDragIndicator(.hidden)
         } else {
             VStack(spacing: 0) {
                 content
                 Spacer(minLength: 0)
             }
         }
     }
}

extension View {
    func mediumPresentationDetents() -> some View {
         modifier(MediumPresentationDetentsViewModifier())
     }
}


