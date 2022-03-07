import SwiftUI
import Amplitude
import BlocksModels

struct ObjectSettingsContainerView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
        
    @State private var mainViewPresented = false
    
    @State private var isIconPickerPresented = false
    @State private var isCoverPickerPresented = false
    @State private var isLayoutPickerPresented = false
    @State private var isRelationsViewPresented = false
    
    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .popup(
                isPresented: $mainViewPresented,
                type: .floater(verticalPadding: 42),
                animation: .fastSpring,
                closeOnTap: false,
                closeOnTapOutside: true,
                backgroundOverlayColor: Color.black.opacity(0.25),
                dismissCallback: {
                    guard !isLayoutPickerPresented else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.onDismiss()
                    }
                },
                view: {
                    ObjectSettingsView(
                        isCoverPickerPresented: $isCoverPickerPresented,
                        isIconPickerPresented: $isIconPickerPresented,
                        isLayoutPickerPresented: $isLayoutPickerPresented,
                        isRelationsViewPresented: $isRelationsViewPresented
                    )
                        .horizontalReadabilityPadding(8)
                        .environmentObject(viewModel)
                }
            )
            .sheet(
                isPresented: $isCoverPickerPresented
            ) {
                ObjectCoverPicker(viewModel: viewModel.coverPickerViewModel)
            }
            .sheet(
                isPresented: $isIconPickerPresented
            ) {
                ObjectIconPicker(viewModel: viewModel.iconPickerViewModel)
            }
            .sheet(
                isPresented: $isRelationsViewPresented
            ) {
                RelationsListView(viewModel: viewModel.relationsViewModel)
                    .onChange(of: isRelationsViewPresented) { isRelationsViewPresented in
                        if isRelationsViewPresented {
                            Amplitude.instance().logEvent(AmplitudeEventsName.objectRelationShow)
                        }
                    }
            }
            .popup(
                isPresented: $isLayoutPickerPresented,
                type: .floater(verticalPadding: 0),
                closeOnTap: false,
                closeOnTapOutside: true,
                backgroundOverlayColor: Color.black.opacity(0.25),
                view: {
                    ObjectLayoutPicker()
                        .horizontalReadabilityPadding()
                        .environmentObject(viewModel.layoutPickerViewModel)
                }
            )
            .onChange(of: isLayoutPickerPresented) { showLayoutSettings in
                withAnimation() {
                    mainViewPresented = !showLayoutSettings
                }
            }
            .onAppear {
                withAnimation(.fastSpring) {
                    mainViewPresented = true
                }
            }
    }
}

struct ObjectSettingsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingsContainerView(
            viewModel: ObjectSettingsViewModel(
                objectId: "dummyPageId",
                objectDetailsService: DetailsService(objectId: ""),
                popScreenAction: {},
                onRelationValueEditingTap: { _ in }
            )
        )
    }
}
