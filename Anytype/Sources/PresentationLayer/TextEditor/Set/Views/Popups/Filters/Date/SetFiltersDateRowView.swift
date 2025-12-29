import SwiftUI

struct SetFiltersDateRowView: View {
    let configuration: SetFiltersDateRowConfiguration
    @Binding var date: Date
    
    var body: some View {
        HStack(spacing: 0) {
            option
            if configuration.isSelected {
                valueView
                Image(asset: .X24.tick)
                    .foregroundStyle(Color.Control.primary)
            }
        }
    }
    
    private var option: some View {
        Button {
            configuration.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(
                    configuration.title,
                    style: .uxBodyRegular
                )
                .foregroundStyle(Color.Text.primary)
                .layoutPriority(1)
                Spacer()
            }
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }
    
    private var valueView: some View {
        Group {
            switch configuration.dateType {
            case .exactDate:
                DatePicker("", selection: $date, in: ClosedRange.anytypeDateRange, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .frame(height: 24)
                    .accentColor(Color.Control.accent100)
                Spacer.fixedWidth(4)
            case let .days(count):
                AnytypeText(count, style: .uxBodyRegular)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer.fixedWidth(4)
            default:
                EmptyView()
            }
        }
    }
}
