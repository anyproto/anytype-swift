import SwiftUI
import AnytypeCore

/// Activity at the end of a discussion thread: open runs, text-only status and typing whose
/// `reply_to` / `replyTo` resolves to this thread.
struct DiscussionActivityThreadView: View {

    let controller: ChatActivityController
    let rootId: String

    var body: some View {
        if let bucket = controller.threadBuckets[rootId] {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(bucket.runIds, id: \.self) { runId in
                    ChatActivityRunRowView(controller: controller, runId: runId)
                }
                ForEach(controller.makeRows(bucket: bucket)) { row in
                    ChatActivityRowView(data: row)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 8)
        }
    }
}

/// Finished runs under the header of the comment that closed them.
struct DiscussionAttachedRunsView: View {

    let controller: ChatActivityController
    let messageId: String

    var body: some View {
        if let runIds = controller.attachedRuns[messageId], runIds.isNotEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Spacer.fixedHeight(4)
                ForEach(runIds, id: \.self) { runId in
                    ChatActivityRunRowView(controller: controller, runId: runId)
                }
            }
        }
    }
}

/// Discussion-level activity above the main composer: open runs without a resolvable thread,
/// text-only status and main-composer typing.
struct DiscussionActivityRootView: View {

    let controller: ChatActivityController

    var body: some View {
        let bucket = controller.rootBucket
        VStack(alignment: .leading, spacing: 0) {
            ForEach(bucket.runIds, id: \.self) { runId in
                ChatActivityRunRowView(controller: controller, runId: runId)
                    .padding(.horizontal, 16)
            }
            ChatActivityComposerRowsView(controller: controller)
        }
    }
}
