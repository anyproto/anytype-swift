import Foundation
import SwiftUI

extension View {
    func anytypeSheet<Content>(
        isPresented: Binding<Bool>,
        dismissOnBackgroundView: Bool = true,
        onDismiss: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View where Content : View {
        fullScreenCover(isPresented: isPresented, onDismiss: onDismiss) {
            SheetView(dismissOnBackgroundView: dismissOnBackgroundView) {
                content()
            } cancelAction: {
                cancelAction?()
            }
            .presentationBackground(.clear)
        }
    }
    
    public func anytypeSheet<Item, Content>(
        item: Binding<Item?>,
        dismissOnBackgroundView: Bool = true,
        onDismiss: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil,
        content: @escaping (Item) -> Content
    ) -> some View where Item : Identifiable, Content : View {
        fullScreenCover(item: item, onDismiss: onDismiss) { item in
            SheetView(dismissOnBackgroundView: dismissOnBackgroundView) {
                content(item)
            } cancelAction: {
                cancelAction?()
            }
            .presentationBackground(.clear)
        }
    }
}
