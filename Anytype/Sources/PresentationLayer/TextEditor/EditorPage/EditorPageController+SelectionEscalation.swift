import UIKit

// Escalates an in-block text selection into block multi-select at the block boundary
// (cross-block selection, phase 0). Entry points:
// - a native selection drag (grabber or selection body) that leaves the focused text block,
// - shift+arrow at the block edge, routed from TextViewWithPlaceholder through
//   `escalateToBlockSelection`; further shift+arrows here grow the block selection.
// Both end in the existing `.selecting` state, so copy/style/move work unchanged.

struct SelectionEscalationPanContext {
    let startedNearSelectionEdge: Bool
    var isEscalated: Bool
}

extension EditorPageController {

    private enum EscalationConstants {
        static let edgeGrabSlop: CGFloat = 60
        static let escapeThreshold: CGFloat = 32
        static let autoscrollBand: CGFloat = 100
        static let autoscrollMaxStep: CGFloat = 10
    }

    // MARK: - Grabber-drag escalation

    @objc func handleSelectionEscalationPan(_ recognizer: UIPanGestureRecognizer) {
        // A sniffed system range-adjustment recognizer IS the user dragging a selection handle —
        // no start-proximity heuristic needed. It can also join mid-gesture (addTarget lands
        // after its .began on the first drag), so the context bootstraps on .changed as well.
        let isSystemHandleDrag = recognizer !== selectionEscalationPan
        switch recognizer.state {
        case .began:
            beginEscalationContext(with: recognizer, isSystemHandleDrag: isSystemHandleDrag)
        case .changed:
            if selectionEscalationPanContext == nil {
                beginEscalationContext(with: recognizer, isSystemHandleDrag: isSystemHandleDrag)
            }
            if selectionEscalationPanContext?.isEscalated == true {
                updateEscalatedBlockSelection(with: recognizer)
            } else {
                escalateBlockSelectionIfNeeded(with: recognizer)
            }
        case .ended, .cancelled, .failed:
            // Entering .selecting tears down the text selection UI, which cancels the system
            // drag recognizer mid-touch. The same touch then resurfaces through the collection
            // pan — open a short window for it to be adopted as the continuation.
            var handoffOpened = false
            if recognizer.state != .ended,
               selectionEscalationPanContext?.isEscalated == true,
               case .selecting = viewModel.blocksStateManager.editingState {
                selectionEscalationHandoffDeadline = CACurrentMediaTime() + 0.25
                handoffOpened = true
            } else if recognizer.state == .ended {
                selectionEscalationHandoffDeadline = 0
            }
            if !handoffOpened {
                stopEscalationAutoscroll()
            }
            selectionEscalationPanContext = nil
        default:
            break
        }
    }

    private func beginEscalationContext(with recognizer: UIPanGestureRecognizer, isSystemHandleDrag: Bool) {
        selectionEscalationPanContext = SelectionEscalationPanContext(
            startedNearSelectionEdge: isSystemHandleDrag || panStartedNearSelectionEdge(recognizer),
            isEscalated: false
        )
        adoptContinuationPanIfHandingOff()
    }

    private func adoptContinuationPanIfHandingOff() {
        guard CACurrentMediaTime() < selectionEscalationHandoffDeadline,
              selectionEscalationAnchor != nil,
              case .selecting = viewModel.blocksStateManager.editingState else { return }
        selectionEscalationHandoffDeadline = 0
        selectionEscalationPanContext?.isEscalated = true
        startEscalationAutoscroll()
    }

    private func panStartedNearSelectionEdge(_ recognizer: UIPanGestureRecognizer) -> Bool {
        guard let textView = firstResponderView as? UITextView,
              textView.isFirstResponder,
              textView.selectedRange.length > 0,
              let selectedTextRange = textView.selectedTextRange else { return false }
        let location = recognizer.location(in: collectionView)
        let edgeRects = [
            textView.caretRect(for: selectedTextRange.start),
            textView.caretRect(for: selectedTextRange.end)
        ]
        return edgeRects.contains { rect in
            guard !rect.isNull, !rect.isInfinite else { return false }
            let converted = textView.convert(rect, to: collectionView)
            return converted.insetBy(dx: -EscalationConstants.edgeGrabSlop, dy: -EscalationConstants.edgeGrabSlop)
                .contains(location)
        }
    }

    private func escalateBlockSelectionIfNeeded(with recognizer: UIPanGestureRecognizer) {
        guard let anchorIndexPath = escalationAnchorIfEligible(with: recognizer) else { return }
        selectionEscalationAnchor = anchorIndexPath
        selectionEscalationPanContext?.isEscalated = true
        startEscalationAutoscroll()
        viewModel.blocksStateManager.didLongTap(at: anchorIndexPath)
        updateEscalatedBlockSelection(with: recognizer)
    }

    private func escalationAnchorIfEligible(with recognizer: UIPanGestureRecognizer) -> IndexPath? {
        guard case .editing = viewModel.blocksStateManager.editingState,
              selectionEscalationPanContext?.startedNearSelectionEdge == true,
              !collectionView.isLocked,
              let textView = firstResponderView as? UITextView,
              textView.isFirstResponder,
              textView.selectedRange.length > 0 else { return nil }

        // Screen space, deliberately: a grabber drag auto-scrolls the collection view, so in
        // content coordinates the block runs away from the finger. On the stationary root view
        // the geometry sorts itself out — during a plain scroll finger and block move together
        // (no escape), while a grabber drag (or its autoscroll) moves the finger relative to
        // the block until it escapes. There is no "selection pinned at text end" requirement
        // either: below the last line UITextView maps the drag to the character at that x, so
        // the selection never reaches the text end on a straight-down drag.
        let locationInView = recognizer.location(in: view)
        let textFrameInView = textView.convert(textView.bounds, to: view)
        let escapedDown = locationInView.y > textFrameInView.maxY + EscalationConstants.escapeThreshold
        let escapedUp = locationInView.y < textFrameInView.minY - EscalationConstants.escapeThreshold
        guard escapedDown || escapedUp else { return nil }

        guard let cell = textView.containingCollectionViewCell,
              let anchorIndexPath = collectionView.indexPath(for: cell),
              viewModel.blocksStateManager.canSelectBlock(at: anchorIndexPath) else { return nil }
        return anchorIndexPath
    }

    private func updateEscalatedBlockSelection(with recognizer: UIPanGestureRecognizer) {
        selectionEscalationLastTouchInView = recognizer.location(in: view)
        updateEscalatedBlockSelection(atContentPoint: recognizer.location(in: collectionView))
    }

    private func updateEscalatedBlockSelection(atContentPoint location: CGPoint) {
        guard case .selecting = viewModel.blocksStateManager.editingState,
              let anchor = selectionEscalationAnchor,
              let target = escalationTarget(for: location, anchor: anchor) else { return }

        let lower = min(anchor.row, target.row)
        let upper = max(anchor.row, target.row)
        let desired = Set(
            (lower...upper)
                .map { IndexPath(row: $0, section: anchor.section) }
                .filter { canSelect(indexPath: $0) }
        )
        let current = Set(
            (collectionView.indexPathsForSelectedItems ?? []).filter { $0.section == anchor.section }
        )
        guard desired != current else { return }

        desired.subtracting(current).forEach {
            collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
        current.subtracting(desired).forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
        viewModel.blocksStateManager.didUpdateSelectedIndexPaths(
            collectionView.indexPathsForSelectedItems ?? [],
            allSelected: isAllSelected()
        )
    }

    private func escalationTarget(for location: CGPoint, anchor: IndexPath) -> IndexPath? {
        if let hit = collectionView.indexPathForItem(at: location), hit.section == anchor.section {
            return hit
        }
        let rows = collectionView.numberOfItems(inSection: anchor.section)
        guard rows > 0,
              let firstFrame = collectionView.layoutAttributesForItem(at: IndexPath(row: 0, section: anchor.section))?.frame,
              let lastFrame = collectionView.layoutAttributesForItem(at: IndexPath(row: rows - 1, section: anchor.section))?.frame
        else { return nil }
        if location.y < firstFrame.minY { return IndexPath(row: 0, section: anchor.section) }
        if location.y > lastFrame.maxY { return IndexPath(row: rows - 1, section: anchor.section) }
        // A gap between cells: keep the current selection until the finger reaches a cell.
        return nil
    }

    // MARK: - Scroll lock + edge autoscroll while extending

    private func startEscalationAutoscroll() {
        guard selectionEscalationAutoscroll == nil else { return }
        collectionView.isScrollEnabled = false
        let link = CADisplayLink(target: self, selector: #selector(escalationAutoscrollTick))
        // .common: the run loop sits in tracking mode for the whole drag.
        link.add(to: .main, forMode: .common)
        selectionEscalationAutoscroll = link
    }

    private func stopEscalationAutoscroll() {
        selectionEscalationAutoscroll?.invalidate()
        selectionEscalationAutoscroll = nil
        selectionEscalationLastTouchInView = nil
        collectionView.isScrollEnabled = true
    }

    @objc private func escalationAutoscrollTick() {
        guard selectionEscalationPanContext?.isEscalated == true else {
            // The handoff never arrived (finger lifted between teardown and adoption): restore
            // scrolling once the window has lapsed.
            if CACurrentMediaTime() > selectionEscalationHandoffDeadline {
                stopEscalationAutoscroll()
            }
            return
        }
        guard let touch = selectionEscalationLastTouchInView else { return }

        let topActivation = view.safeAreaInsets.top + EscalationConstants.autoscrollBand
        let bottomActivation = view.bounds.maxY - view.safeAreaInsets.bottom - EscalationConstants.autoscrollBand
        var step: CGFloat = 0
        if touch.y > bottomActivation {
            step = min(1, (touch.y - bottomActivation) / EscalationConstants.autoscrollBand) * EscalationConstants.autoscrollMaxStep
        } else if touch.y < topActivation {
            step = -min(1, (topActivation - touch.y) / EscalationConstants.autoscrollBand) * EscalationConstants.autoscrollMaxStep
        }
        guard step != 0 else { return }

        let insets = collectionView.adjustedContentInset
        let minOffset = -insets.top
        let maxOffset = max(minOffset, collectionView.contentSize.height - collectionView.bounds.height + insets.bottom)
        let newOffset = min(max(collectionView.contentOffset.y + step, minOffset), maxOffset)
        guard newOffset != collectionView.contentOffset.y else { return }

        collectionView.contentOffset.y = newOffset
        // The finger is stationary while content moves under it; retarget from screen space.
        updateEscalatedBlockSelection(atContentPoint: view.convert(touch, to: collectionView))
    }

    // MARK: - Keyboard extension while selecting

    override var canBecomeFirstResponder: Bool {
        true
    }

    override var keyCommands: [UIKeyCommand]? {
        guard case .selecting = viewModel.blocksStateManager.editingState else { return super.keyCommands }
        let commands = [
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: .shift, action: #selector(extendBlockSelectionDown)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: .shift, action: #selector(extendBlockSelectionUp))
        ]
        commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        return (super.keyCommands ?? []) + commands
    }

    @objc private func extendBlockSelectionDown() {
        extendBlockSelection(down: true)
    }

    @objc private func extendBlockSelectionUp() {
        extendBlockSelection(down: false)
    }

    private func extendBlockSelection(down: Bool) {
        guard case .selecting = viewModel.blocksStateManager.editingState else { return }
        let selected = (collectionView.indexPathsForSelectedItems ?? []).sorted()
        guard let first = selected.first, let last = selected.last else { return }

        // Escalation remembers its anchor; a selection begun by long tap anchors at its top row.
        let anchor = selectionEscalationAnchor ?? first
        if selectionEscalationAnchor == nil {
            selectionEscalationAnchor = anchor
        }

        var changed = false
        if down {
            if first.row < anchor.row {
                collectionView.deselectItem(at: first, animated: false)
                changed = true
            } else if let next = nextSelectableRow(from: last, forward: true) {
                collectionView.selectItem(at: next, animated: false, scrollPosition: [])
                revealRow(at: next)
                changed = true
            }
        } else {
            if last.row > anchor.row {
                collectionView.deselectItem(at: last, animated: false)
                changed = true
            } else if let previous = nextSelectableRow(from: first, forward: false) {
                collectionView.selectItem(at: previous, animated: false, scrollPosition: [])
                revealRow(at: previous)
                changed = true
            }
        }
        guard changed else { return }

        viewModel.blocksStateManager.didUpdateSelectedIndexPaths(
            collectionView.indexPathsForSelectedItems ?? [],
            allSelected: isAllSelected()
        )
    }

    private func nextSelectableRow(from indexPath: IndexPath, forward: Bool) -> IndexPath? {
        let rows = collectionView.numberOfItems(inSection: indexPath.section)
        var row = indexPath.row + (forward ? 1 : -1)
        while row >= 0 && row < rows {
            let candidate = IndexPath(row: row, section: indexPath.section)
            if canSelect(indexPath: candidate) { return candidate }
            row += forward ? 1 : -1
        }
        return nil
    }

    private func revealRow(at indexPath: IndexPath) {
        guard let frame = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }
        collectionView.scrollRectToVisible(frame.insetBy(dx: 0, dy: -8), animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension EditorPageController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gestureRecognizer === selectionEscalationPan
    }
}

private extension UIView {
    var containingCollectionViewCell: UICollectionViewCell? {
        var current: UIView? = self
        while let view = current {
            if let cell = view as? UICollectionViewCell { return cell }
            current = view.superview
        }
        return nil
    }
}
