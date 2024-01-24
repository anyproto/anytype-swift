import Foundation
import SwiftUI

struct ShareOptionsView: View {
    
    @StateObject var model: ShareOptionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text(Loc.Sharing.saveAs)) {
                    
                    if model.availableOptions.contains(.container) {
                        ShareSelectionRow(text: model.newContainerTitle, selected: model.saveAsType == .container)
                            .fixTappableArea()
                            .onTapGesture {
                                model.onTapSaveAsContainer()
                            }
                    }
                    
                    if model.availableOptions.contains(.object) {
                        ShareSelectionRow(text: model.newObjectTitle, selected: model.saveAsType == .object)
                            .fixTappableArea()
                            .onTapGesture {
                                model.onTapSaveAsNewObject()
                            }
                    }
                    
                    if model.availableOptions.contains(.block) {
                        ShareSelectionRow(text: model.newBlockTitle, selected: model.saveAsType == .block)
                            .fixTappableArea()
                            .onTapGesture {
                                model.onTapSaveAsBlock()
                            }
                    }
                }
                
                Section {
                    ShareArrowRow(title: Loc.Sharing.selectSpace, description: model.spaceName)
                        .fixTappableArea()
                        .onTapGesture {
                            model.onTapSelectSpace()
                        }
                    ShareArrowRow(title: model.linkTitle, description: model.linkObjectName)
                        .fixTappableArea()
                        .onTapGesture {
                            model.onTapLinkObject()
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
        .onChange(of: model.dismiss) { _ in
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
