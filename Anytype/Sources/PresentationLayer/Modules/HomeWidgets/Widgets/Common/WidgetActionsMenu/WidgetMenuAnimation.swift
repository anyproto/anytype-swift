import Foundation

// Wait for the context menu's transition-to-list animation before running actions
// that mutate the list, otherwise the removal animation glitches.
let menuDismissAnimationDelay: TimeInterval = 0.7
