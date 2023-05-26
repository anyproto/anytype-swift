import Foundation
import SwiftUI

class AnytypeHostingController: UIHostingController<AnyView> {
    
    private class Observer {
        weak var value: AnytypeHostingController?
        init() {}
    }
    
    // MARK: - State
    
    private var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            if oldValue != statusBarStyle {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    private var anytypeStatusBarStyle: AnytypeStatusBarStyle = .default {
        didSet { updateStatusBarStyle() }
    }
    
    // MARK: - Public

    init<T: View>(rootView: T) {
        let observer = Observer()
        
        let observedView = AnyView(rootView.onPreferenceChange(AnytypeStatusBarStyleKey.self) { style in
            observer.value?.anytypeStatusBarStyle = style
        })

        super.init(rootView: observedView)
        observer.value = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unavailable")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    
    // MARK: - Private
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateStatusBarStyle()
        }
    }
    
    private func updateStatusBarStyle() {
        statusBarStyle = anytypeStatusBarStyle.uiKitStyle(traitCollection: traitCollection)
    }
}
