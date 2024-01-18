import Foundation
import SwiftUI

struct ShareOptionsView: View {
    
    @StateObject var model: ShareOptionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section(header: Text(Loc.Sharing.saveAs)) {
                ShareSelectionRow(text: model.newObjectTitle, selected: model.saveAsType == .newObject)
                    .fixTappableArea()
                    .onTapGesture {
                        model.onTapSaveAsNewObject()
                    }
                ShareSelectionRow(text: model.embededObjectTitle, selected: model.saveAsType == .block)
                    .fixTappableArea()
                    .onTapGesture {
                        model.onTapSaveAsBlock()
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
                .disabled(!model.isSaveButtonAvailable)
        )
    }
}
