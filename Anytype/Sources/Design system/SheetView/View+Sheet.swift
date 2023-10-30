import Foundation
import SwiftUI

extension View {
    func anytypeSheet<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content : View {
        fullScreenCover(isPresented: isPresented) {
            SheetContainerView {
                SheetView {
                    content()
                }
            }
        }
    }
    
    public func anytypeSheet<Item, Content>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item : Identifiable, Content : View {
        fullScreenCover(item: item) { item in
            SheetContainerView {
                SheetView {
                    content(item)
                }
            }
        }
    }
}

@available(iOS, deprecated: 16.4, message: "Replace to SheetView {}.presentationBackground(.clear)")
private struct SheetContainerView<Content: View>: UIViewControllerRepresentable {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return UISheetControllerForPresentation(rootView: content)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

private final class UISheetControllerForPresentation<Content>: UIHostingController<Content> where Content: View {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        view.backgroundColor = .clear
    }
  
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        parent?.view.backgroundColor = .clear
        parent?.modalPresentationStyle = .overCurrentContext
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
