import Foundation
import SwiftUI

extension View {
    
    func anytypeBottomAlert<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content : View {
        anytypeSheet(isPresented: isPresented, dismissByTap: false, content: content)
    }
    
    func anytypeBottomAlert<Item, Content>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item : Identifiable, Content : View {
        anytypeSheet(item: item, dismissByTap: false, content: content)
    }
}
