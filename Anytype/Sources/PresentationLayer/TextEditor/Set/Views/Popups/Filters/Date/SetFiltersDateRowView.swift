import SwiftUI

struct SetFiltersDateRowView: View {
    let configuration: SetFiltersDateRowConfiguration
    @Binding var date: Date
    
    var body: some View {
        Button {
            configuration.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(
                    configuration.title,
                    style: .uxBodyRegular,
                    color: .Text.primary
                )
                .layoutPriority(1)
                Spacer()
                
                if configuration.isSelected {
                    valueView
                    Image(asset: .X24.tick)
                        .foregroundColor(.Button.button)
                }
            }
        }
    }
    
    private var valueView: some View {
        Group {
            switch configuration.dateType {
            case .exactDate:
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .frame(height: 24)
                    .accentColor(Color.System.amber100)
                Spacer.fixedWidth(4)
            case let .days(count):
                AnytypeText(count, style: .uxBodyRegular, color: .Text.primary)
                    .lineLimit(1)
                Spacer.fixedWidth(4)
            default:
                EmptyView()
            }
        }
    }
}
