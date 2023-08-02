import Foundation
import SwiftUI
import Services

struct WidgetTypeView: View {
    
    @StateObject var model: WidgetTypeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Widgets.Layout.Screen.title)
            ForEach(model.rows, id:\.self) {
                WidgetTypeRowView(model: $0)
            }
        }
        .modifier(FitPresentationDetentsViewModifier())
    }
}

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
