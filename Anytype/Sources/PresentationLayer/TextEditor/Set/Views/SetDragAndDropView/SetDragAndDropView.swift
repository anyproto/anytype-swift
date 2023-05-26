import SwiftUI
import UniformTypeIdentifiers
import AnytypeCore

struct SetDragAndDropView<Content>: View where Content: View {
    
    @Binding private var dropData: SetCardDropData
    private let configuration: SetContentViewItemConfiguration?
    private let groupId: String
    private let dragAndDropDelegate: SetDragAndDropDelegate
    private let content: () -> Content
    
    init(
        dropData: Binding<SetCardDropData>,
        configuration: SetContentViewItemConfiguration?,
        groupId: String,
        dragAndDropDelegate: SetDragAndDropDelegate,
        @ViewBuilder content: @escaping () -> Content)
    {
        self._dropData = dropData
        self.configuration = configuration
        self.groupId = groupId
        self.dragAndDropDelegate = dragAndDropDelegate
        self.content = content
    }
    
    var body: some View {
        content()
            .if(FeatureFlags.dndOnCollectionsAndSets) {
                $0.ifLet(configuration) { view, configuration in
                    view
                        .onDrag {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            updateDropData(with: configuration, groupId: groupId)
                            let provider = DragItemProvider(object: SetItemProviderObject())
                            provider.didEnd = {
                                defer { dropData.clear() }
                                guard let fromGroupId = dropData.initialFromGroupId,
                                      let toGroupId = dropData.toGroupId else {
                                    return
                                }
                                let _ = dragAndDropDelegate.onDrop(
                                    configurationId: configuration.id,
                                    fromGroupId: fromGroupId,
                                    toGroupId: toGroupId
                                )
                            }
                            return provider
                        }
                        .opacity(dropData.draggingCard?.id == configuration.id ? 0.4 : 1)
                }
                .onDrop(
                    of: SetItemProviderObject.writableTypeIdentifiersForItemProvider,
                    delegate: buildDelegate(with: configuration, groupId: groupId)
                )
            }
    }
    
    private func updateDropData(with configuration: SetContentViewItemConfiguration, groupId: String) {
        dropData.draggingCard = configuration
        dropData.initialFromGroupId = groupId
        dropData.fromGroupId = groupId
    }
    
    private func buildDelegate(
        with configuration: SetContentViewItemConfiguration?,
        groupId: String) -> SetCardDropInsideDelegate
    {
        SetCardDropInsideDelegate(
            dragAndDropDelegate: dragAndDropDelegate,
            droppingCard: configuration,
            toGroupId: groupId,
            data: $dropData
        )
    }
}
