//
//  ObjectSettingsContainerView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Amplitude
import BlocksModels

struct ObjectSettingsContainerView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
    
    var onHide: () -> Void = {}
        
    @State private var mainViewPresented = false
    
    @State private var isIconPickerPresented = false
    @State private var isCoverPickerPresented = false
    @State private var isLayoutPickerPresented = false
    
    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .popup(
                isPresented: $mainViewPresented,
                type: .floater(verticalPadding: 42),
                animation: .ripple,
                closeOnTap: false,
                closeOnTapOutside: true,
                backgroundOverlayColor: Color.black.opacity(0.25),
                dismissCallback: {
                    guard !isLayoutPickerPresented else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onHide()
                    }
                },
                view: {
                    ObjectSettingsView(
                        isCoverPickerPresented: $isCoverPickerPresented,
                        isIconPickerPresented: $isIconPickerPresented,
                        isLayoutPickerPresented: $isLayoutPickerPresented
                    )
                        .padding(8)
                        .environmentObject(viewModel)
                }
            )
            .sheet(
                isPresented: $isCoverPickerPresented,
                onDismiss: {
                    // TODO: is it necessary?
                    isCoverPickerPresented = false
                }
            ) {
                ObjectCoverPicker(viewModel: viewModel.coverPickerViewModel)
            }
            .sheet(
                isPresented: $isIconPickerPresented,
                onDismiss: {
                    // TODO: is it necessary?
                    isIconPickerPresented = false
                }
            ) {
                ObjectIconPicker(viewModel: viewModel.iconPickerViewModel)
            }
            .popup(
                isPresented: $isLayoutPickerPresented,
                type: .floater(verticalPadding: 42),
                closeOnTap: false,
                closeOnTapOutside: true,
                backgroundOverlayColor: Color.black.opacity(0.25),
                dismissCallback: {
                    isLayoutPickerPresented = false
                },
                view: {
                    ObjectLayoutPicker()
                        .padding(8)
                        .environmentObject(viewModel.layoutPickerViewModel)
                }
            )
            .onChange(of: isLayoutPickerPresented) { showLayoutSettings in
                // Analytics
                if showLayoutSettings {
                    Amplitude.instance().logEvent(AmplitudeEventsName.popupChooseLayout)
                }

                withAnimation() {
                    mainViewPresented = !showLayoutSettings
                }
            }
            .onAppear {
                Amplitude.instance().logEvent(AmplitudeEventsName.popupDocumentMenu)
                
                withAnimation(.ripple) {
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
                objectDetailsService: ObjectDetailsService(
                    eventHandler: EventsListener(
                        objectId: "",
                        container: RootBlockContainer(
                            blocksContainer: BlockContainer(),
                            detailsStorage: ObjectDetailsStorage()
                        )
                    ),
                    objectId: ""
                )
            )
        )
    }
}
