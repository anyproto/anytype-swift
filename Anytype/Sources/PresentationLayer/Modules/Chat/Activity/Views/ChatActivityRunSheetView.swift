import SwiftUI
import UIKit

/// A run's calls in first-seen order. Updates live and keeps its scroll position; no actions on calls.
struct ChatActivityRunSheetView: View {

    let controller: ChatActivityController
    let runId: String

    @State private var toastBarData: ToastBarData?

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            if let run = controller.runModel(id: runId) {
                header(run: run)
                list(run: run)
            }
            Spacer(minLength: 0)
        }
        .mediumPresentationDetents()
        .snackbar(toastBarData: $toastBarData)
    }

    private func header(run: ActivityRunModel) -> some View {
        let names = run.summary.publishers.compactMap { controller.participant(identity: $0)?.title }
        return HStack(spacing: 0) {
            Spacer.fixedWidth(48)
            Spacer()
            AnytypeText(ChatActivityText.runTitle(names: names, summary: run.summary), style: .uxTitle2Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
            Spacer()
            Menu {
                Button {
                    copyAsJson(run: run)
                } label: {
                    Label(Loc.Chat.Activity.copyAsJson, systemImage: "doc.on.doc")
                }
            } label: {
                Image(asset: .X24.more)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 48, height: 48)
            }
        }
        .frame(height: 48)
    }

    private func list(run: ActivityRunModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(run.items) { item in
                    ChatActivityCallRowView(item: item)
                }
            }
        }
        .scrollIndicators(.never)
    }

    /// Every call of the run, merged `data` with results, as received.
    private func copyAsJson(run: ActivityRunModel) {
        UIPasteboard.general.string = ActivityJSON.array(run.items.map(\.data)).serialized(pretty: true)
        toastBarData = ToastBarData(Loc.copied)
    }
}

struct ChatActivityCallRowView: View {

    let item: ActivityItemSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                AnytypeText(title, style: .previewTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                status
            }
            if item.isToolCall {
                AnytypeText(ChatActivityText.displayText(item.text), style: .relation2Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(3)
            }
            ForEach(item.metadata, id: \.key) { field in
                AnytypeText("\(field.key): \(field.value.preview)", style: .caption1Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        item.isToolCall ? ChatActivityText.toolName(item.toolName) : ChatActivityText.displayText(item.text)
    }

    @ViewBuilder
    private var status: some View {
        if let label = ChatActivityText.status(lifecycle: item.lifecycle, isFresh: item.isFresh) {
            HStack(spacing: 4) {
                statusIcon
                AnytypeText(label, style: .caption1Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
            }
            .fixedSize()
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch item.lifecycle {
        case .inProgress:
            if item.isFresh {
                TypingDotsView()
            }
        case .complete:
            Image(asset: .X18.tick)
                .foregroundStyle(Color.Control.secondary)
        case .error:
            Image(asset: .X18.redAttention)
        case nil:
            EmptyView()
        }
    }
}
