import UIKit

// MARK: - UIView + LayoutStrategy

public extension UIView {

    /// Entry point for layout utils scope
    var layoutUsing: LayoutStrategy {
        LayoutStrategy(container: self)
    }

    /// Type statically contains all available layout strategies
    @MainActor
    struct LayoutStrategy {

        let root: UIView

        init(container: UIView) {
            self.root = container
        }
    }

}

// MARK: - UIView.LayoutStrategy + Anchors

public extension UIView.LayoutStrategy {

    /// Prepares the view for autolayout and calls layout block.
    ///
    /// - Parameter closure: The layout block.
    @MainActor
    func anchors(using closure: (LayoutProxy) -> Void) {
        root.translatesAutoresizingMaskIntoConstraints = false
        closure(LayoutProxy(view: root))
    }

}

public extension UIView {

    /// Adds a subview and setup layout.
    /// - Parameters:
    ///   - view: The view to be added.
    ///   - layout: The layout block.
    func addSubview(_ view: UIView, layout: (LayoutProxy) -> Void) {
        addSubview(view)
        view.layoutUsing.anchors(using: layout)
    }

}

// MARK: - UIView.LayoutStrategy + Stack

public extension UIView.LayoutStrategy {

    /// Use stack as a layout strategy. Then place it to the caller-view's hierarchy
    ///
    /// - Parameter builder: Builder with the scope for stack related operations
    @discardableResult
    func stack(layout: ((UIStackView) -> Void)? = nil,
               builder: ((UIView.Stack) -> UIStackView)) -> UIStackView {
        let stackView = builder(UIView.Stack())
        root.addSubview(stackView)

        if let layout = layout {
            layout(stackView)
        } else {
            stackView.pinAllEdges(to: root)
        }

        return stackView
    }

    /// UIScrollView with embedded stack layout strategy.
    /// - Parameters:
    ///   - scrollViewLayout: Position ScrollView as needed, otherwise pinned to rootView
    ///   - stackLayout: Position StackView as needed, otherwise pinned to scrollView
    ///   - alwaysBounceVertical: Disabled by default for unneded scroll
    ///   - builder: Place arranged subviews here
    @discardableResult
    func scrollableStack(
        scrollViewLayout: ((UIScrollView) -> Void)? = nil,
        stackViewLayout: ((UIStackView) -> Void)? = nil,
        config: UIView.ScrollableStackConfiguration = UIView.ScrollableStackConfiguration(),
        builder: ((UIView.Stack) -> UIStackView)
    ) -> UIScrollView {
        root.scrollableStack(
            scrollViewLayout: scrollViewLayout,
            stackViewLayout: stackViewLayout,
            config: config,
            builder: builder
        )
    }

}
