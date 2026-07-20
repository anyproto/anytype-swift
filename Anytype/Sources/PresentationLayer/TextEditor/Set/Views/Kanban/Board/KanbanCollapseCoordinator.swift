import SwiftUI
import UIKit

/// Drives the shared collapsing object header from the kanban columns' own scroll views.
///
/// The board has no whole-page vertical scroll. Every column reserves the collapse distance with
/// a transparent top spacer in its scroll content, and the column the user is scrolling becomes
/// the driver: its scroll *deltas* move `headerTravel`, which positions the shared object
/// header. Deltas, not absolute offsets - a column scrolled deeper than the page must not make
/// the header jump to its depth the moment it starts driving, and dragging any column down with
/// the header already expanded must scroll only that column's cards.
///
/// Columns sitting exactly on the page line follow it in both directions - that is the
/// whole-page scroll illusion, and it is what brings every synced column back to its own top
/// when the page re-expands. Columns scrolled deeper keep their position until the page line
/// catches them. Over-dragging past fully expanded stretches the whole board down as one sheet,
/// like the other view types' rubber band.
///
/// TODO: IOS-6595 - the introspection + KVO + setContentOffset plumbing exists only because
/// SwiftUI on iOS 17 exposes neither scroll offsets nor pixel-level scroll control. Once the
/// deployment target reaches iOS 18, replace it with `onScrollGeometryChange` (observation),
/// `onScrollPhaseChange` (driver detection) and `ScrollPosition` (follower sync), and delete
/// `kanbanCollapseSync`. The driver/follower rules stay as they are.
@MainActor
final class KanbanCollapseCoordinator {
    var onHeaderTravelChange: ((CGFloat) -> Void)?
    private(set) var headerTravel: CGFloat = 0

    private struct Entry {
        weak var scrollView: UIScrollView?
        let observation: NSKeyValueObservation
    }

    private var entries = [ObjectIdentifier: Entry]()
    // The settle point: the settings row rests at the top once the page has collapsed this far.
    private var collapseDistance: CGFloat = 0
    // The travel at which the object header is fully off-screen; tracking stops there so deep
    // card scrolling doesn't publish useless updates.
    private var headerTravelDistance: CGFloat = 0
    private weak var driver: UIScrollView?
    private var isSyncing = false

    // The page line: how far the settings row and page-locked columns have collapsed. Header
    // travel beyond it only slides the header's remainder out from behind the nav bar. Negative
    // is the over-drag stretch: the whole board follows the rubber band down as one sheet.
    private var pageCollapse: CGFloat {
        min(headerTravel, collapseDistance)
    }

    func setDistances(collapse collapseDistance: CGFloat, headerTravel headerTravelDistance: CGFloat) {
        self.collapseDistance = max(collapseDistance, 0)
        self.headerTravelDistance = max(headerTravelDistance, self.collapseDistance)
        applyTravel(min(headerTravel, self.headerTravelDistance), driver: nil)
    }

    func reset() {
        headerTravel = 0
        driver = nil
    }

    func register(_ scrollView: UIScrollView) {
        entries = entries.filter { $0.value.scrollView != nil }

        let id = ObjectIdentifier(scrollView)
        guard entries[id] == nil else { return }

        let observation = scrollView.observe(\.contentOffset, options: [.old, .new]) { [weak self] scrollView, change in
            guard let self, let old = change.oldValue, let new = change.newValue else { return }
            // UIScrollView reports contentOffset changes on the main thread.
            MainActor.assumeIsolated {
                self.offsetChanged(scrollView, delta: new.y - old.y)
            }
        }
        entries[id] = Entry(scrollView: scrollView, observation: observation)

        // A column materialized mid-collapse starts at zero offset; consume its spacer right
        // away so it doesn't show a hole where the header used to be.
        catchUp(scrollView)
    }

    private func offsetChanged(_ scrollView: UIScrollView, delta: CGFloat) {
        guard !isSyncing else { return }

        let fingerDriven = scrollView.isTracking || scrollView.isDragging
        let isActive = fingerDriven || scrollView.isDecelerating

        if fingerDriven {
            claimDriver(scrollView)
        } else if isActive, driver == nil {
            // Deceleration without a driver only happens if the driving column was deallocated.
            driver = scrollView
        }

        guard driver === scrollView, isActive else {
            if !fingerDriven {
                catchUp(scrollView)
            }
            return
        }

        let rel = relativeOffset(scrollView)
        var newTravel = headerTravel
        // Upward deltas coming out of the top rubber band are dropped: the snap-back must not
        // re-collapse what the stretch just expanded, or a column with no scroll range left
        // could never finish expanding the header.
        if delta < 0 || rel - delta >= 0 {
            newTravel += delta
        }
        newTravel = min(newTravel, headerTravelDistance)
        // Floor at zero - except a column rubber-banding at its own top drags the header down
        // with it 1:1 (and back), like the other view types' bounce.
        newTravel = max(newTravel, min(rel, 0))
        applyTravel(newTravel, driver: scrollView)
    }

    private func applyTravel(_ newTravel: CGFloat, driver: UIScrollView?) {
        guard newTravel != headerTravel else { return }
        let oldPage = pageCollapse
        headerTravel = newTravel
        let newPage = pageCollapse
        if newPage != oldPage {
            syncColumns(oldPage: oldPage, newPage: newPage, except: driver)
        }
        onHeaderTravelChange?(newTravel)
    }

    private func syncColumns(oldPage: CGFloat, newPage: CGFloat, except driver: UIScrollView?) {
        for entry in entries.values {
            guard
                let scrollView = entry.scrollView,
                scrollView !== driver,
                !scrollView.isTracking, !scrollView.isDragging
            else { continue }
            let rel = relativeOffset(scrollView)
            // Columns on the page line move with it in both directions (into the over-drag
            // stretch too); columns behind the new line are caught up so their spacer never
            // shows as a hole; deeper columns keep their position until the line reaches them
            // (Trello-style persistence)...
            if abs(rel - oldPage) <= Constants.lockTolerance || rel < newPage {
                scroll(scrollView, to: newPage)
            } else {
                // ...except during the stretch, where they too move with the sheet. The shift
                // telescopes back to zero as the bounce settles, so their position is kept.
                let stretchShift = min(newPage, 0) - min(oldPage, 0)
                if stretchShift != 0 {
                    scroll(scrollView, to: rel + stretchShift)
                }
            }
        }
    }

    private func catchUp(_ scrollView: UIScrollView) {
        let page = pageCollapse
        guard relativeOffset(scrollView) < page - Constants.lockTolerance else { return }
        scroll(scrollView, to: page)
    }

    private func scroll(_ scrollView: UIScrollView, to rel: CGFloat) {
        isSyncing = true
        // setContentOffset (not a plain assignment) also kills any in-flight deceleration, so a
        // synced column doesn't keep drifting and fight the correction.
        let target = CGPoint(
            x: scrollView.contentOffset.x,
            y: rel - scrollView.adjustedContentInset.top
        )
        scrollView.setContentOffset(target, animated: false)
        isSyncing = false
    }

    // Only finger contact claims the header - a decelerating column never takes it back. The
    // previous driver's fling is stopped dead (the same way a scroll view's own deceleration
    // ends the moment you touch it): without this, two decelerating columns both feed deltas
    // into the header and it flickers.
    private func claimDriver(_ scrollView: UIScrollView) {
        guard driver !== scrollView else { return }
        if let previous = driver, previous.isDecelerating {
            isSyncing = true
            previous.setContentOffset(previous.contentOffset, animated: false)
            isSyncing = false
        }
        driver = scrollView
    }

    private func relativeOffset(_ scrollView: UIScrollView) -> CGFloat {
        scrollView.contentOffset.y + scrollView.adjustedContentInset.top
    }
}

private extension KanbanCollapseCoordinator {
    enum Constants {
        // Columns are placed on the page line by our own setContentOffset, so matches are
        // near-exact; the tolerance only absorbs float noise.
        static let lockTolerance: CGFloat = 1
    }
}

extension View {
    /// Registers the enclosing scroll view as one of the kanban columns driving the header
    /// collapse. Apply to the column scroll view's *content*, like `scrollAxisLock`.
    func kanbanCollapseSync(_ coordinator: KanbanCollapseCoordinator) -> some View {
        background(KanbanCollapseSyncView(coordinator: coordinator))
    }
}

private struct KanbanCollapseSyncView: UIViewRepresentable {
    let coordinator: KanbanCollapseCoordinator

    func makeUIView(context: Context) -> UIView {
        KanbanCollapseSyncUIView(coordinator: coordinator)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private final class KanbanCollapseSyncUIView: UIView {
    private let coordinator: KanbanCollapseCoordinator

    init(coordinator: KanbanCollapseCoordinator) {
        self.coordinator = coordinator
        super.init(frame: .zero)
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, let scrollView = enclosingScrollView else { return }
        coordinator.register(scrollView)
    }

    private var enclosingScrollView: UIScrollView? {
        var ancestor: UIView? = superview
        while let current = ancestor {
            if let scrollView = current as? UIScrollView { return scrollView }
            ancestor = current.superview
        }
        return nil
    }
}
