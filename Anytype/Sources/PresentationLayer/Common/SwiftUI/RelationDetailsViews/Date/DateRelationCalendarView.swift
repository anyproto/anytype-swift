import SwiftUI
import Services

struct DateRelationCalendarView: View {
    
    @StateObject var viewModel: DateRelationCalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    init(date: Date?, configuration: RelationModuleConfiguration) {
        _viewModel = StateObject(wrappedValue: DateRelationCalendarViewModel(
            date: date,
            configuration: configuration
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            content
        }
        .background(Color.Background.secondary)
        .frame(height: 525)
        .fitPresentationDetents()
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
    }
    
    private var content: some View {
        NavigationView {
            list
                .navigationTitle(viewModel.config.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    private var list: some View {
        PlainList {
            calendar
            
            ForEach(DateRelationCalendarQuickOption.allCases) { option in
                quickOptionRow(option)
                    .padding(.horizontal, 16)
                    .if(!option.isLast, transform: {
                        $0.newDivider(leadingPadding: 16)
                    })
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                clearButton
            }
        }
        .bounceBehaviorBasedOnSize()
        .background(Color.Background.secondary)
    }
    
    private var calendar: some View {
        DatePicker("", selection: $viewModel.date, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .accentColor(Color.System.amber125)
            .onChange(of: viewModel.date) { _ in
                viewModel.dateChanged()
            }
            .padding(.horizontal, 16)
            .newDivider(leadingPadding: 16)
    }
    
    private func quickOptionRow(_ option: DateRelationCalendarQuickOption) -> some View {
        Button {
            viewModel.onQuickOptionTap(option)
        } label: {
            AnytypeText(option.title, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixTappableArea()
        }
        
    }
    
    private var clearButton: some View {
        Button {
            viewModel.clear()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular)
                .foregroundColor(.Button.active)
        }
    }
}

#Preview {
    DateRelationCalendarView(
        date: nil,
        configuration: RelationModuleConfiguration.default
    )
}
