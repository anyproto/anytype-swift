import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct AnytypeVerticalDragViewModifier: ViewModifier {
    let itemId: String
    @Environment(\.anytypeDragState) @Binding var state: DragState
    @Environment(\.anytypeDragAndDropFrames) var framesStorage
    @Environment(\.anytypeDragAndDropPendingCommit) private var pendingCommit

    func body(content: Content) -> some View {
        content
            .onDrag {
                state.dragInitiateId = itemId

                let provider = DragItemProvider(object: "\(itemId)" as NSString)
                let pendingCommit = self.pendingCommit

                provider.didEnd = {
                    let commit = pendingCommit.commit
                    pendingCommit.commit = nil
                    if let commit {
                        state.resetState()
                        commit()
                    } else if !state.dragInProgress {
                        state.resetState()
                    } else {
                        // iOS can deallocate a transient drag provider while the actual drag
                        // session is still active. Resetting here makes SwiftUI treat the row
                        // as non-draggable mid-gesture, which shows the "not allowed" badge and
                        // puts the source row back into the list.
                        return
                    }
                }

                return provider
            }
            .readFrame(space: .named("anytypeDropSpace")) { frame in
                framesStorage.frames[itemId] = frame
            }
    }
}

extension View {
    func anytypeVerticalDrag<Data: Identifiable<String>>(item: Data) -> some View {
        modifier(AnytypeVerticalDragViewModifier(itemId: item.id))
    }

    func anytypeVerticalDrag(itemId: String) -> some View {
        modifier(AnytypeVerticalDragViewModifier(itemId: itemId))
    }
}

struct AnytypeVerticalDragWithPreviewViewModifier<Preview: View>: ViewModifier {
    let itemId: String
    let preview: () -> Preview
    @Environment(\.anytypeDragState) @Binding var state: DragState
    @Environment(\.anytypeDragAndDropFrames) var framesStorage
    @Environment(\.anytypeDragAndDropPendingCommit) private var pendingCommit

    func body(content: Content) -> some View {
        content
            .onDrag {
                state.dragInitiateId = itemId

                let provider = DragItemProvider(object: "\(itemId)" as NSString)
                let pendingCommit = self.pendingCommit

                provider.didEnd = {
                    let commit = pendingCommit.commit
                    pendingCommit.commit = nil
                    if let commit {
                        state.resetState()
                        commit()
                    } else if !state.dragInProgress {
                        state.resetState()
                    } else {
                        // iOS can deallocate a transient drag provider while the actual drag
                        // session is still active. Resetting here makes SwiftUI treat the row
                        // as non-draggable mid-gesture, which shows the "not allowed" badge and
                        // puts the source row back into the list.
                        return
                    }
                }

                return provider
            } preview: {
                preview()
            }
            .readFrame(space: .named("anytypeDropSpace")) { frame in
                framesStorage.frames[itemId] = frame
            }
    }
}

extension View {
    func anytypeVerticalDrag<Preview: View>(
        itemId: String,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        modifier(AnytypeVerticalDragWithPreviewViewModifier(itemId: itemId, preview: preview))
    }
}

struct AnytypeVerticalDropViewModifier<Data>: ViewModifier where Data: Identifiable<String> {
    let data: [Data]
    @Binding var state: DragState
    let dropUpdate: (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    let dropFinish: (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    
    @State private var dropState = DropState<Data>()
    @State private var framesStorage = DragAndDropFrames()
    @State private var pendingCommit = DragAndDropPendingCommit()
    
    func body(content: Content) -> some View {
        content
            .onDrop(
                of: [.plainText],
                delegate: DragAndDropVerticalDelegate(
                    data: data,
                    dragState: $state,
                    dropState: $dropState,
                    framesStorage: framesStorage,
                    pendingCommit: pendingCommit,
                    dropUpdate: dropUpdate,
                    dropFinish: dropFinish
                )
            )
            .coordinateSpace(name: "anytypeDropSpace")
            .environment(\.anytypeDragState, $state)
            .environment(\.anytypeDragAndDropFrames, framesStorage)
            .environment(\.anytypeDragAndDropPendingCommit, pendingCommit)
    }
}

extension View {
    func anytypeVerticalDrop<Data: Identifiable<String>>(
        data: [Data],
        state: Binding<DragState>,
        dropUpdate: @escaping (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void,
        dropFinish: @escaping (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    ) -> some View {
        modifier(AnytypeVerticalDropViewModifier(data: data, state: state, dropUpdate: dropUpdate, dropFinish: dropFinish))
    }
}
