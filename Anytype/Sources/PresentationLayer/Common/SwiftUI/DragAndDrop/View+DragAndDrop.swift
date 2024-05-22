import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct AnytypeVerticalDragViewModifier: ViewModifier {
    let itemId: String
    @Environment(\.anytypeDragState) @Binding var state: DragState
    @Environment(\.anytypeDragAndDropFrames) var framesStorage
    
    func body(content: Content) -> some View {
        content
            .onDrag {
                state.dragInitiateId = itemId
                
                let provider = DragItemProvider(object: "\(itemId)" as NSString)

                provider.didEnd = {
                    state.resetState()
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

struct AnytypeVerticalDropViewModifier<Data>: ViewModifier where Data: Identifiable<String> {
    let data: [Data]
    @Binding var state: DragState
    let dropUpdate: (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    let dropFinish: (_ from: DropDataElement<Data>, _ to: DropDataElement<Data>) -> Void
    
    @State private var dropState = DropState<Data>()
    @State private var framesStorage = DragAndDropFrames()
    
    func body(content: Content) -> some View {
        content
            .onDrop(
                of: [.plainText],
                delegate: DragAndDropVerticalDelegate(
                    data: data,
                    dragState: $state,
                    dropState: $dropState,
                    framesStorage: framesStorage,
                    dropUpdate: dropUpdate,
                    dropFinish: dropFinish
                )
            )
            .coordinateSpace(name: "anytypeDropSpace")
            .environment(\.anytypeDragState, $state)
            .environment(\.anytypeDragAndDropFrames, framesStorage)
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
