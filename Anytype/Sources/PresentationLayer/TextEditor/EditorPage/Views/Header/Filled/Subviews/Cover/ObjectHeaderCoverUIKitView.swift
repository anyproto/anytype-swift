import Foundation
import UIKit
import SwiftUI

final class ObjectHeaderCoverUIKitView: UIView {
    
    private let hosting: UIHostingController<AnyView>
    
    private var objectCover: ObjectHeaderCoverType?
    private var fitImage: Bool
    
    func setIcon(objectCover: ObjectHeaderCoverType, fitImage: Bool = false) {
        self.objectCover = objectCover
        self.fitImage = fitImage
        updateIcon()
    }
    
    init(objectCover: ObjectHeaderCoverType? = nil, fitImage: Bool = false) {
        self.objectCover = objectCover
        self.fitImage = fitImage
        self.hosting = UIHostingController(rootView: EmptyView().eraseToAnyView())
        super.init(frame: .zero)
        
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view) {
            $0.pinToSuperview()
        }
        updateIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateIcon() {
        guard let objectCover else {
            hosting.rootView = EmptyView().eraseToAnyView()
            return
        }
        hosting.rootView = ObjectHeaderCoverView(objectCover: objectCover, fitImage: fitImage).ignoresSafeArea().eraseToAnyView()
    }
}
