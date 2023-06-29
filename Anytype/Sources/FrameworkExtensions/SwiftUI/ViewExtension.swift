import SwiftUI


extension View {
    func errorToast(isShowing: Binding<Bool>, errorText: String, onOkPressed: @escaping () -> () = {}) -> some View {
        LegacyErrorAlertView(isShowing: isShowing, errorText: errorText, presenting: self, onOkPressed: onOkPressed)
    }
    
    func alertView(isShowing: Binding<Bool>, errorText: String, onButtonTap: @escaping () -> () = {}) -> some View {
        AlertView(isShowing: isShowing, errorText: errorText, presenting: self, onButtonTap: onButtonTap)
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
    
    @ViewBuilder
      func ifLet<V, Transform: View>(
        _ value: V?,
        transform: (Self, V) -> Transform
      ) -> some View {
        if let value = value {
          transform(self, value)
        } else {
          self
        }
      }
}

extension View {
    
    func transparencyEffect(edge: TransparencyEffect.Edge, length: CGFloat) -> some View {
        modifier(TransparencyEffectModifier(edge: edge, length: length))
    }
    
}

