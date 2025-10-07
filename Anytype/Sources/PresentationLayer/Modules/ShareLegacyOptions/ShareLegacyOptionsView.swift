import Foundation
import SwiftUI
import SharedContentManager

struct ShareLegacyOptionsView: View {
    
    @StateObject private var model: ShareLegacyOptionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String, output: (any ShareLegacyOptionsModuleOutput)?) {
        self._model = StateObject(wrappedValue: ShareLegacyOptionsViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text(Loc.Sharing.saveAs)) {
                    
                    if model.availableOptions.contains(.container) {
                        ShareLegacySelectionRow(text: model.newContainerTitle, selected: model.saveAsType == .container)
                            .fixTappableArea()
                            .onTapGesture {
                                model.onTapSaveAsContainer()
                            }
                    }
                    
                    if model.availableOptions.contains(.object) {
                        ShareLegacySelectionRow(text: model.newObjectTitle, selected: model.saveAsType == .object)
                            .fixTappableArea()
                            .onTapGesture {
                                model.onTapSaveAsNewObject()
                            }
                    }
                    
                    if model.availableOptions.contains(.block) {
                        ShareLegacySelectionRow(text: model.newBlockTitle, selected: model.saveAsType == .block)
                            .fixTappableArea()
                            .onTapGesture {
                                model.onTapSaveAsBlock()
                            }
                    }
                }
                
                Section {
                    ShareLegacyArrowRow(title: Loc.Sharing.selectSpace, description: model.spaceName)
                        .fixTappableArea()
                        .onTapGesture {
                            model.onTapSelectSpace()
                        }
                    ShareLegacyArrowRow(title: model.linkTitle, description: model.linkObjectName)
                        .fixTappableArea()
                        .onTapGesture {
                            model.onTapLinkObject()
                        }
                }
                
                if let debugItems = model.debugInfo?.items {
                    Section(header: Text(Loc.Debug.info)) {
                        ForEach(0..<debugItems.count, id: \.self) { index in
                            ShareLegacyDebugRowView(index: index, mimeTypes: debugItems[index].mimeTypes)
                        }
                    }
                }
            }
            if model.saveInProgress {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                DotsView()
                    .frame(width: 80, height: 8)
            }
        }
        .disabled(model.saveInProgress)
        .onChange(of: model.dismiss) {
            dismiss()
        }
        .navigationTitle(Loc.Sharing.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading:
                Button(Loc.Sharing.Navigation.LeftButton.title, role: .cancel) {
                    model.onTapCancel()
                },
            trailing:
                Button(Loc.Sharing.Navigation.RightButton.title, role: .destructive) {
                    model.onTapSave()
                }
                .disabled(!model.isSaveButtonAvailable || model.saveInProgress)
        )
    }
}
