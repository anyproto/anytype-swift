import SwiftUI

final class UISheetController<Content>: UIHostingController<Content> where Content: View {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        view.backgroundColor = .clear
        modalPresentationStyle = .overCurrentContext
    }
  
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
