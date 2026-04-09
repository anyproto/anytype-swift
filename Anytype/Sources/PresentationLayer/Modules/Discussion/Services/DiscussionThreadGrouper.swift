import Services

struct DiscussionThreadGroupResult {
    let roots: [FullChatMessage]
    let threadReplies: [String: [FullChatMessage]]
}

struct DiscussionThreadGrouper {

    /// Walk the replyToMessageID chain to find the root parent message id.
    /// Returns nil if the chain is broken (orphan) or cyclic.
    /// Uses `rootCache` to memoize results — all intermediate nodes in a resolved
    /// chain are cached so subsequent lookups are O(1).
    private func findRootParentId(
        messageId: String,
        messageById: [String: FullChatMessage],
        rootCache: inout [String: String]
    ) -> String? {
        if let cached = rootCache[messageId] {
            return cached
        }

        var currentId = messageId
        var visited = Set<String>()
        var chain: [String] = []

        while true {
            if let cached = rootCache[currentId] {
                for id in chain { rootCache[id] = cached }
                return cached
            }

            guard let current = messageById[currentId] else {
                return nil
            }

            let parentId = current.message.replyToMessageID
            if parentId.isEmpty {
                for id in chain { rootCache[id] = currentId }
                return currentId
            }

            if visited.contains(parentId) {
                return nil
            }
            visited.insert(currentId)
            chain.append(currentId)
            currentId = parentId
        }
    }

    /// Group messages into root messages and their thread replies.
    /// - Builds a lookup by message.id
    /// - For each message with replyToMessageID, chain-walks to find root
    /// - Orphan replies (parent not loaded) and cyclic chains are filtered out
    /// - Replies within each thread are sorted by orderID
    func groupMessagesIntoThreads(
        messages: [FullChatMessage]
    ) -> DiscussionThreadGroupResult {
        let messageById = Dictionary(
            messages.map { ($0.message.id, $0) },
            uniquingKeysWith: { _, last in last }
        )

        var roots: [FullChatMessage] = []
        var threadReplies: [String: [FullChatMessage]] = [:]
        var rootCache: [String: String] = [:]

        for fullMessage in messages {
            let message = fullMessage.message
            if message.replyToMessageID.isEmpty {
                // This is a root message
                roots.append(fullMessage)
            } else {
                // This is a reply — find its root parent
                if let rootId = findRootParentId(messageId: message.replyToMessageID, messageById: messageById, rootCache: &rootCache) {
                    threadReplies[rootId, default: []].append(fullMessage)
                }
                // else: orphan or cyclic — filtered out
            }
        }

        // Sort replies within each thread by orderID
        for (rootId, replies) in threadReplies {
            threadReplies[rootId] = replies.sorted { $0.message.orderID < $1.message.orderID }
        }

        return DiscussionThreadGroupResult(roots: roots, threadReplies: threadReplies)
    }
}
