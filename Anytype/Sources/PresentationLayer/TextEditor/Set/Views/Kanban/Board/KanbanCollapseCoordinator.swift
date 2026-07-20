import SwiftUI
import UIKit

/// Drives the shared collapsing object header from the kanban columns' own scroll views.
///
/// The board has no whole-page vertical scroll. Every column reserves the collapse distance with
/// a transparent top spacer in its scroll content, and the column the user is scrolling becomes
/// the driver: its offset is mirrored 1:1 into `headerTravel`, which positions the shared object
/// header — including past the collapse point, so continued card scrolling slides the header
/// fully off-screen the way the other view types do (stopping at the collapse point would leave
/// the header's bottom parked behind the translucent nav bar). All other columns are kept
/// scrolled at least to the collapse point, so switching to them never reveals the reserved
/// spacer as a hole; columns scrolled deeper keep their position.
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
    // The settle point: settings row rests at the top, followers are synced to at least this.
    private var collapseDistance: CGFloat = 0
    // The travel at which the object header is fully off-screen; tracking stops there so deep
    // card scrolling doesn't publish useless updates.
    private var headerTravelDistance: CGFloat = 0
    private var collapse: CGFloat = 0
    private weak var driver: UIScrollView?
    private var isSyncing = false

    func setDistances(collapse collapseDistance: CGFloat, headerTravel headerTravelDistance: CGFloat) {
        self.collapseDistance = max(collapseDistance, 0)
        self.headerTravelDistance = max(headerTravelDistance, self.collapseDistance)

        let clampedTravel = min(headerTravel, self.headerTravelDistance)
        let clampedCollapse = min(max(clampedTravel, 0), self.collapseDistance)
        guard clampedTravel != headerTravel || clampedCollapse != collapse else { return }
        headerTravel = clampedTravel
        collapse = clampedCollapse
        syncFollowers(except: nil)
        onHeaderTravelChange?(headerTravel)
    }

    func reset() {
        headerTravel = 0
        collapse = 0
        driver = nil
    }

    func register(_ scrollView: UIScrollView) {
        entries = entries.filter { $0.value.scrollView != nil }

        let id = ObjectIdentifier(scrollView)
        guard entries[id] == nil else { return }

        let observation = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
            guard let self else { return }
            // UIScrollView reports contentOffset changes on the main thread.
            MainActor.assumeIsolated {
                self.offsetChanged(scrollView)
            }
        }
        entries[id] = Entry(scrollView: scrollView, observation: observation)

        // A column materialized mid-collapse starts at zero offset; consume its spacer right
        // away so it doesn't show a hole where the header used to be.
        followIfBehind(scrollView)
    }

    private func offsetChanged(_ scrollView: UIScrollView) {
        guard !isSyncing else { return }

        let fingerDriven = scrollView.isTracking || scrollView.isDragging
        let isActive = fingerDriven || scrollView.isDecelerating

        if isActive {
            let driverFingerDriven = driver.map { $0.isTracking || $0.isDragging } ?? false
            // A merely decelerating column can't steal the header from a finger-driven one.
            if fingerDriven || driver == nil || driver === scrollView || !driverFingerDriven {
                driver = scrollView
            }
        }

        if driver === scrollView, isActive {
            // Raw below zero so the header follows the driver's rubber band 1:1, capped once
            // the header is fully off-screen.
            let travel = min(relativeOffset(scrollView), headerTravelDistance)
            guard travel != headerTravel else { return }
            headerTravel = travel

            let newCollapse = min(max(travel, 0), collapseDistance)
            if newCollapse != collapse {
                collapse = newCollapse
                syncFollowers(except: scrollView)
            }
            onHeaderTravelChange?(travel)
        } else if !fingerDriven {
            // Programmatic or layout-induced movement (lazy content sizing, drag auto-scroll):
            // the no-hole invariant still applies.
            followIfBehind(scrollView)
        }
    }

    private func syncFollowers(except driver: UIScrollView?) {
        for entry in entries.values {
            guard
                let scrollView = entry.scrollView,
                scrollView !== driver,
                !scrollView.isTracking, !scrollView.isDragging
            else { continue }
            followIfBehind(scrollView)
        }
    }

    private func followIfBehind(_ scrollView: UIScrollView) {
        guard relativeOffset(scrollView) < collapse else { return }
        isSyncing = true
        scrollView.contentOffset.y = collapse - scrollView.adjustedContentInset.top
        isSyncing = false
    }

    private func relativeOffset(_ scrollView: UIScrollView) -> CGFloat {
        scrollView.contentOffset.y + scrollView.adjustedContentInset.top
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
