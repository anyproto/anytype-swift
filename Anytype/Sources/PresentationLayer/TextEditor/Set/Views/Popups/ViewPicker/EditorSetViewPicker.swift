import SwiftUI

struct EditorSetViewPicker: View {
    @ObservedObject var viewModel: EditorSetViewPickerViewModel
    @State private var editMode = EditMode.inactive
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        DragIndicator()
        NavigationView {
            viewsList
                .navigationTitle(Loc.views)
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .onChange(of: viewModel.rows) { newValue in
                    if editMode == .active && viewModel.rows.count == 0 {
                        editMode = .inactive
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private var viewsList: some View {
        List {
            ForEach(viewModel.rows) {
                if #available(iOS 15.0, *) {
                    row(with: $0)
                        .divider()
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(
                            top: 0,
                            leading: editMode == .active && $0.isSupported ? -24 : 20,
                            bottom: 0,
                            trailing: 20
                        ))
                        .moveDisabled(!$0.isSupported)
                } else {
                    row(with: $0)
                        .moveDisabled(!$0.isSupported)
                }
            }
            .onMove { from, to in
                viewModel.move(from: from, to: to)
            }
        }
        .animation(nil)
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.buttonActive)
            }
        }
    }
    
    private func row(with configuration: EditorSetViewRowConfiguration) -> some View {
        EditorSetViewRow(configuration: configuration, onTap: {
            presentationMode.wrappedValue.dismiss()
            configuration.onTap()
        })
        .environment(\.editMode, $editMode)
        .animation(nil)
    }
}
    
