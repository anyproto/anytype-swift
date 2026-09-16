# Quick Capture — what Android changed, for iOS to port

**Date:** 2026-09-05 · **From:** Android (DROID-4587, PR anyproto/anytype-kotlin#3339) · **Depends on:** GO-7499

Android built quick capture from the iOS handoff (IOS-6617), then dogfooded it hard and reworked several parts. This is the reverse handoff: the decisions, the model, and the traps. Nothing here is Android-specific unless marked.

Everything is behind an experimental flag; on-device AI behind a second one.

---

## 1. Product decisions worth adopting

### 1.1 Never ask a question when the user hasn't typed

This is the single most important behavioural rule, and it took three rounds of dogfooding to get right.

Switching the target space mid-capture *feels* like it needs a confirmation, so we added one. Wrong. If the user has not typed anything **this session**, there is no text in flight, nothing is at stake, and any dialog is noise. Switching is then pure navigation: the current draft stays where it is, the target space's draft opens, exactly as if the sheet had been opened there.

It gets worse after the first switch: the draft on screen now belongs to the space you just moved into, so offering to carry it onward is nonsense.

The final tree — a prompt appears **only when something is genuinely given up**:

| Draft on screen | Target space | Result |
|---|---|---|
| empty | anything | opens the target's draft, no dialog |
| **untouched this session** | anything | opens the target's draft, no dialog |
| edited, has text | no draft / empty draft | draft moves with you ("text follows the chip"), no dialog |
| edited, has text | holds text | **Keep both** / **Discard my draft** |

Note "untouched" ≠ "empty". A restored draft is non-empty the moment it opens. You need a separate signal for *the user typed during this sheet session*; emptiness cannot stand in for it.

**Android implementation:** a flag set in the single funnel every text edit passes through (`sendTextChange`, which both the title and body blocks route through), reset naturally because the editor VM is rebuilt per draft. **Known gap:** paste, mention insertion and the first keystroke into a trailing placeholder bypass that funnel, so they don't currently mark the draft as edited. Check the equivalent paths on iOS.

### 1.2 Never overwrite a draft the user cannot see

The original contract had "replace the target space's draft". We shipped it, then removed it.

The target's draft is off-screen and its content is never shown. Asking someone to authorise a permanent delete of something they cannot see is not a real choice. The target's draft is now **never** destroyed by a space switch. The question is only ever about the draft in front of them:

- **Keep both** — this draft stays in its space, the target's opens
- **Discard my draft** — this one is deleted, the target's opens

Both land in the same place. Dismissing does nothing.

### 1.3 The unsent-draft dot

A 6dp amber dot marks an unsent draft, in two places with two scopes:

- **space picker row** — "this space has a draft"
- **space chip in the header** — "some space *other than this one* has a draft"

The chip's dot is the aggregate of the picker's, minus the current space. Without it the feature has a hole: the sheet always opens where you last captured, so after discarding that draft nothing tells you unfinished drafts exist elsewhere — the picker is the only affordance and nothing suggests opening it.

Details that mattered:
- We first used a pencil in the list and a dot on the chip. Two glyphs for one state read as two states. **One mark, one meaning.**
- 6dp is Material's small-badge size. A **numeric** badge is 16dp with 11sp text — nearly 3× the height, next to an 18dp chevron. Don't. The count also wouldn't change what the user does (they'd still open the picker).
- In the list, **reserve the dot's gutter on every row**. Showing it only on marked rows shifts those names sideways and breaks the text column.
- On the chip, put the dot **before** the chevron with an asymmetric gap (wider before, tighter after) so it reads as belonging to the control, not as punctuation after the space name.

### 1.4 Opening must never wait on the cross-space query

Cold start can leave per-space stores warming for seconds. The sheet resolves which draft to open from the **device-local pointer via a direct single-space lookup**, and runs cross-space discovery *alongside* on its own task.

Discovery deliberately does **not** choose which space opens. Jumping the user into a different space because a newer draft exists there moves them somewhere they didn't ask to go — telling them (the dot) is enough.

---

## 2. The `isDraft` model (cross-device drafts)

Drafts always synced between devices. What they lacked was a property to **ask the store for them by**, so each device could only reopen the draft its own local pointer named — a note started on the phone was unreachable from the tablet even though the object was right there.

**GO-7499** adds `isDraft` (bool). Discovery is then one cross-space query:

```
isDraft == true AND creator IN {my participant ids}   ordered by createdDate desc
```

The device-local pointer survives only as a hint for which draft *this* device resumes.

### Non-obvious constraints

- **`creator` is per space.** The same account is a *different* participant object in every space. A cross-space query filtering on one creator id matches drafts in exactly one space and silently reports none anywhere else. Use an `IN` over all your participant ids (the account-wide participant subscription already has them). No per-space fan-out.
- **Publishing must clear `isDraft` and `isHidden` in the same write.** Otherwise every note ever sent keeps matching the query, and newest-first eventually reopens a published note *as a draft*.
- **A partial cross-space result is "unknown", not "empty".** Creating a draft on an inconclusive answer is how a space ends up with two.
- **More than one draft per space becomes reachable** (two devices, both offline). Newest opens; the other must **not** be auto-deleted — deletion is permanent and the loser is someone's unsent text.
- **Hidden is not private.** A hidden draft in a shared space still syncs to every member; `isHidden` only keeps it out of *our* UI. If unsent text must not leave the device, that's a heart-side guarantee this design does not provide.

### GO-7499 also covers resurrection

Undo, version restore, replica merge and duplicate must never bring `isDraft`/`isHidden` back on a published object. The client **cannot** defend against this: "still a draft" and "flags came back from history" are byte-identical states, and the sheet's trash deletes drafts permanently. Worth confirming iOS has the same exposure.

---

## 3. Pitfalls (the expensive part)

These cost the most time. Most are not Android-specific.

### Data loss

1. **Emptiness checks that fail open, feeding a delete.** Our "does the target draft have content?" helper returned `false` on any fetch error, and the delete downstream only checked "does this object still exist". One transient error = permanent deletion of a real note. **A destructive operation must establish its own precondition at the point of deletion, and fail closed.**

2. **Reading a relation you never requested.** The same helper read `snippet`, which wasn't in the fetch's `keys` — so it was *always* null and the check silently degenerated to title-only. Body-only drafts read as empty and were destroyed without a prompt. Audit every `keys` list against the fields actually read afterwards. A mock will happily return the field regardless, so a behavioural test won't catch it — assert on the request.

3. **Bookkeeping placed after an uninterruptible commit.** (Kotlin-specific mechanism, universal shape.) Our move use case deleted the source inside a non-cancellable block, but wrote the draft pointers in the *caller's* success handler — which never runs if the sheet was dismissed mid-move. Result: source deleted, target holding the text, no pointer to it, unreachable by construction. **Write the pointer before destroying the only other copy**, inside the same uninterruptible section. Worst case then is a recoverable duplicate.

4. **Verifying a copy by "some text landed".** After a cross-space copy we checked text arrived before deleting the source. A note plus an image passed the check and could still lose the image. Count non-text blocks on both sides too.

5. **The publish window.** After publishing succeeds there's still bookkeeping and an analytics call before the sheet dismisses, and the UI stays live throughout, with state still naming the now-published object. Tapping the chip or the trash in that window moves or deletes a real note. Latch on send and stand down every destructive path.

6. **Failing to *find* a draft is not proof it's gone.** Whenever a lookup came back empty we cleared the pointer and created a fresh draft — orphaning the real one. Only clear on positive evidence.

### Detection failures (all made a real draft invisible)

7. **Creator as a query filter.** Scoping the fetch with `creator == mine` excluded any object whose `creator` is unset or whose participant we couldn't resolve. "Not found" is indistinguishable from "no draft here". Fetch by id, apply creator to the **result**, and veto only when both sides are known and differ.

8. **Requiring `isDraft == true`.** Drafts created before the client started writing the relation have no value at all. Treat three states: `true` → draft, `false` → published (never resurrect), **absent** → fall back to `isHidden`.

9. **UI and logic reading different sources.** The picker's dot came from the cross-space query; every decision read only the local pointer. A draft made on another device was advertised in the UI and invisible to the logic — so switching there offered to start a new one, which would have orphaned it. **One accessor for "does this space have a draft".**

10. **`Flow.first { }` throws** when the flow completes without a match, and a timeout wrapper does not catch it — failing the whole lookup. Use the nullable variant.

### UI

11. **Material `AlertDialog` renders `dismissButton` on the LEFT.** We had the destructive action there, in exactly the position the same feature's *other* dialog uses for Cancel. Muscle memory would have deleted a note. Destructive belongs in the confirm slot, and ideally in a design-system dialog with a filled warning button rather than red text alone.

12. **Caret landed at position 0 on a non-empty title.** Our title holder applied the cursor *before* setting the text, so it measured the widget's previous (empty) contents, judged the position out of range and dropped it. Latent for years — the base editor only auto-focuses *empty* titles, where 0 and end coincide. Quick capture reopening a saved draft is the first thing that focuses a non-empty one. **Check the equivalent ordering on iOS.**

13. **A permanent type bar fights whatever else owns the bottom edge.** Ours suppressed itself whenever the ordinary block toolbar appeared — which is on every focus change — so it vanished during typing, while never seeing the undo/redo panel it was written for (that lived outside the state object it inspected). It only *looked* correct because the render pipeline re-raised it on the next keystroke: two writers with opposite intent, resolved by whichever fired last.

14. **Restoring focus to a title needs the title's own path.** The title is a child of the header block, not of the root, so a "focus the last text block" helper never sees it. A one-line capture creates no body block at all, so the most common restored draft got no caret, no keyboard and no type bar.

### Process

15. Two four-lens Opus review rounds. **The second round's top finding was that a fix from the first round was wrong in both directions.** Re-review after fixing; the fix is not automatically safer than the bug.
16. Several bugs surfaced as the *wrong dialog* rather than as an obvious failure, which made them easy to misread as UX complaints. When a prompt appears at a strange moment, suspect a predicate returning the wrong answer before redesigning the prompt.

---

## 4. Also fixed along the way (outside the feature)

Latent bugs this work exposed — check for equivalents:

- A space-view subscription didn't request the join-date relation it sorted on, so the tiebreaker had always been dead.
- Internal flags encoded as a scalar rather than a list were parsed into an empty list.
- A space-icon view fell back to a fixed corner radius and font for any size outside a hard-coded whitelist.
- An object-create path dropped its prefilled details on the default-type branch.

---

## 5. Still open on Android

- Space picker stays interactive during the pre-switch flush, so two fast taps can stack dialogs.
- Paste / mentions don't mark a draft as edited (§1.1).
- Reconciliation when two devices both create a draft in one space.
- A loading-placeholder height hint so the editor's skeleton matches the real header instead of collapsing into it.
- On-device AI type suggestion is implemented and silent on every failure path, but has never run — no test device with the required runtime.

**Reference:** `anytype-kotlin/docs/quick-capture-android-spec.md` (§5a is the draft model, §13 the open verification items). Branch `ki/droid-4587-quick-capture-pencil-entry-on-vault-cross-device-drafts`, 14 commits.
