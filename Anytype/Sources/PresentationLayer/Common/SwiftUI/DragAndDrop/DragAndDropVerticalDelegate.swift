import Foundation
import SwiftUI
import UIKit

struct DragAndDropVerticalDelegate<Data>: DropDelegate where Data: Identifiable<String> {
    let data: [Data]
    @Binding var dragState: DragState
    @Binding var dropState: DropState<Data>
    let framesStorage: DragAndDropFrames
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
        
        withAnimation {
            dropUpdate(fromElement, toElement)
        }
        
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        guard let fromElement = dropState.fromElement,
              let toElement = dropState.toElement else {
            return
        }
        
        dropState.resetState()

        dropFinish(fromElement, toElement)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let fromElement = dropState.fromElement,
              let toElement = dropState.toElement else {
            withAnimation {
                fullClear()
            }
            return false
        }

        withAnimation {
            fullClear()
            dropFinish(fromElement, toElement)
        }

        return true
    }
    
    private func fullClear() {
        dropState.resetState()
        dragState.resetState()
    }
}
