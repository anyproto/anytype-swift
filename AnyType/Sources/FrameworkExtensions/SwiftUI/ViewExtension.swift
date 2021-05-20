import SwiftUI


extension View {
    func errorToast(isShowing: Binding<Bool>, errorText: String) -> some View {
        ErrorAlertView(isShowing: isShowing, errorText: errorText, presenting: self)
    }

    func eraseToAnyView() -> AnyView {
        .init(self)
    }
    
    func embedInNavigation() -> some View {
        NavigationView { self }
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
          transform(self)
        } else {
          self
        }  
    }
    
   
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
          ifTransform(self)
        } else {
          elseTransform(self)
        }
    }
}

