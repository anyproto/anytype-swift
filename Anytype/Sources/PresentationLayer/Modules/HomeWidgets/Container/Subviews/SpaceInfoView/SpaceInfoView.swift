import Foundation
import SwiftUI

struct SpaceInfoView: View {
    @State private var model: SpaceInfoViewModel

    init(spaceId: String) {
        _model = State(initialValue: SpaceInfoViewModel(spaceId: spaceId))
    }

    var body: some View {
        HStack(spacing: 16) {
            IconView(icon: model.spaceIcon)
                .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 3) {
                titleRow
                subtitleView
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .task {
            await model.startSubscriptions()
        }
    }

    @ViewBuilder
    private var titleRow: some View {
        if model.isOneToOne {
            HStack(spacing: 6) {
                AnytypeText(model.spaceName, style: .heading)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                if model.hasMembership {
                    Image(asset: .X18.membershipBadge)
                        .frame(width: 20, height: 20)
                }
            }
        } else {
            AnytypeText(model.spaceName, style: .heading)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if model.isOneToOne {
            AnytypeText(model.anytypeName, style: .relation2Regular)
                .foregroundStyle(Color.Text.transparentSecondary)
                .lineLimit(1)
        } else if model.sharedSpace {
            AnytypeText(model.spaceMembers, style: .relation2Regular)
                .foregroundStyle(Color.Text.transparentSecondary)
                .lineLimit(1)
        } else {
            AnytypeText(model.spaceUxType, style: .relation2Regular)
                .foregroundStyle(Color.Text.transparentSecondary)
                .lineLimit(1)
        }
    }
}
