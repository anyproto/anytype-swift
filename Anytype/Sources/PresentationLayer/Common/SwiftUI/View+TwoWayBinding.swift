import Foundation
import SwiftUI

extension View {
    func twoWayBinding<T>(viewState: Binding<T>, modelState: Binding<T>) -> some View where T: Equatable {
        modifier(TwoWayBindingModifier(viewState: viewState, modelState: modelState))
    }
}

private struct TwoWayBindingModifier<T>: ViewModifier where T: Equatable {
    
    @Binding var viewState: T
    @Binding var modelState: T
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                modelState = viewState
            }
            .onChange(of: modelState) { _, newModelState in
                if viewState != newModelState {
                    viewState = newModelState
                }
            }
            .onChange(of: viewState) { _, newViewState in
                if modelState != newViewState {
                    modelState = newViewState
                }
            }
    }
    
}
