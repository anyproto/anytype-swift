import Foundation
import SwiftUI
import UIKit

struct DragAndDropVerticalDelegate<Data>: DropDelegate where Data: Identifiable<String> {
    let data: [Data]
    @Binding var dragState: DragState
    @Binding var dropState: DropState<Data>
    let framesStorage: DragAndDropFrames
    let pendingCommit: DragAndDropPendingCommit
    let dropUpdate: (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    let dropFinish: (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    
    func validateDrop(info: DropInfo) -> Bool {
        return dragState.dragInitiateId.isNotNil
    }
    
    func dropEntered(info: DropInfo) {
        dragState.dragInProgress = true
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        
        guard let dragInitiatedId = dragState.dragInitiateId,
              let (toItemId, toItemFrame) = framesStorage.frames.first(where: { $0.value.contains(info.location) }),
              let toIndex = data.firstIndex(where: { $0.id == toItemId }),
              let fromIndex = data.firstIndex(where: { $0.id == dragInitiatedId }),
              let toItem = data[safe: toIndex],
              let fromItem = data[safe: fromIndex],
              let fromItemFrame = framesStorage.frames[dragInitiatedId]
                else {
            return DropProposal(operation: .move)
        }
        
        // Calcilate percent if drag object is very small compared with drop object
        if fromItemFrame.height < toItemFrame.height * 2 {
            let percent = (info.location.y - toItemFrame.minY) / toItemFrame.height
            guard (percent < 0.5 && toIndex < fromIndex) || (percent > 0.5 && toIndex > fromIndex) else { return DropProposal(operation: .move) }
        }
        
        let dropAfter = toIndex > fromIndex
        let finalToIndex = dropAfter ? toIndex + 1 : toIndex

        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        let fromElement = DropDataElement(data: fromItem, index: fromIndex)
        let toElement = DropDataElement(data: toItem, index: finalToIndex)
        
        dropState.fromElement = fromElement
        dropState.toElement = toElement
        pendingCommit.commit = { [dropFinish] in
            dropFinish(fromElement, toElement)
        }
        
        withAnimation {
            dropUpdate(fromElement, toElement)
        }
        
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        dropState.resetState()
        // Keep `dragInProgress` while a pending commit exists. Edge drops often leave
        // the drop zone before the drag provider ends; clearing the active state here
        // makes the source row reappear and can switch the preview to "not allowed".
        if pendingCommit.commit == nil {
            dragState.dragInProgress = false
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let fromElement = dropState.fromElement,
              let toElement = dropState.toElement else {
            let commit = pendingCommit.commit
            pendingCommit.commit = nil
            // `performDrop` can arrive after `dropExited` has reset `dropState`,
            // while `pendingCommit` still contains the last valid in-zone reorder.
            // Treat that as an accepted edge-drop; returning `false` makes iOS show
            // the "not allowed" badge and can snap the source row back.
            withAnimation {
                fullClear()
                commit?()
            }
            return commit.isNotNil
        }

        withAnimation {
            fullClear()
            dropFinish(fromElement, toElement)
        }
        pendingCommit.commit = nil

        return true
    }
    
    private func fullClear() {
        dropState.resetState()
        dragState.resetState()
    }
}
