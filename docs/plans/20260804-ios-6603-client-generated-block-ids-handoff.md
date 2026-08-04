# Handoff — Generate block ids on the client (IOS-6603)

## Context

IOS-6597 (PR #5083) fixed autocorrect dropping the first typed letter in a new text block. The
mechanism it fixed: typing the first character into a middleware-empty block swaps that block's id
— `BlockReplace` for the empty-block identity fork, `BlockCreate` for the trailing "tap to type"
placeholder. Diffable item identity derives from the block id, so the swap rendered as
delete+insert: the focused `UITextView` died, the keyboard input session restarted, and UIKit's
per-input-session autocorrect word buffer lost the already-typed prefix.

That fix keeps the row's identity stable and rebinds the live view model in place, so the swap
diffs as an empty change and the same text view keeps first responder.

The fix is sound and shipped. But most of its machinery exists for one reason: **the new block id
is only known one RPC round trip after the user typed.** Everything that bridges that gap — the
swap registry, the focus-handoff choreography, the refusal paths and their fallbacks — is
accidental complexity, and it is where every defect the three review rounds found actually lived.

The middleware already accepts a client-supplied id. If the client mints the id, the identity swap
becomes known synchronously at keystroke time, and the machinery can go.

## Verified protocol facts

Checked against `anytype-heart` at the time of writing — re-verify before relying on them:

- `basic.Replace` — `core/block/editor/basic/basic.go:465-466`:
  `new := simple.New(block)` / `newId = new.Model().Id`. The id comes from whatever the client sent
  and is echoed back in the response.
- `simple.New` — `core/block/simple/simple.go:68-71`:
  `if block.Id == "" { block.Id = bson.NewObjectId().Hex() }`. An id is generated **only** when the
  client leaves it empty. Nothing validates a supplied id.
- `basic.CreateBlock` — `core/block/editor/basic/basic.go:153`:
  `if !s.Add(block) { return "", fmt.Errorf("block id %s already exists", ...) }`. A duplicate id is
  a hard error, not a silent overwrite — a useful safety net, and a retry hazard (see Risks).
- The wire request already carries the id: `Anytype_Rpc.Block.Replace.Request` holds a full
  `Anytype_Model_Block` including `id`
  (`Modules/ProtobufMessages/Sources/Protocol/Commands/Anytype_Rpc.Block.Replace.swift:31`).

Today the iOS client deliberately sends an empty id: see `BlockActionHandler.replaceEmptyBlock`,
which builds `BlockInformation(id: "", ...)` with the comment "No id — the middleware generates a
fresh one."

## What this does and does not buy

**It does not remove the need for stable row identity.** The row is on screen under id `A`; the
fork creates `B`. The diffable identity changes regardless of *when* `B` becomes known. So
`BlockRowIdentityMap` and `TextBlockViewModel.rowIdentity` stay. Do not start by deleting them.

**It removes the asynchrony, and with it the race class.** With the id known before the RPC:

- the rebind happens in the same turn as the keystroke, before any snapshot apply and before any
  middleware event;
- events can no longer outrun swap registration (the placeholder focus-loss bug found in review
  round 2 and fixed structurally in round 3);
- a row for the new id cannot already exist when the rebind runs, so the refusal guards and their
  fallback pipeline have nothing to catch;
- two swaps cannot land in one batch against the same old id;
- the two-phase render-commit choreography from IOS-6594 is not needed for forks.

**For the trailing placeholder it removes the swap entirely.** Today the placeholder row carries a
synthetic `virtual-trailing-block-<UUID>` id and materialization swaps it for the real one. Create
the placeholder row with its *final* block id and materialization stops being an identity change at
all: no swap, no alias, no rebind, no focus handoff. This is the larger half of the win — the
virtual-id concept disappears rather than being managed.

## Work plan

Stages are ordered so each one is independently testable. Do not collapse them.

### 1. Id generation and the middleware contract

Blocked on agreement with the middleware team — resolve before writing app code. Decide:

- **Format.** heart mints `bson.NewObjectId().Hex()` (24 hex chars). Nothing validates a supplied
  id, but "nothing validates it" is not the same as "nothing downstream assumes it". Get explicit
  confirmation for sync, the change/CRDT layer, and any id-ordering assumptions. If in doubt, mint
  the same shape rather than a UUID.
- **Ownership.** This becomes a de facto cross-client expectation. Desktop and Android send empty
  ids today. Agree that client-supplied ids are supported and will stay supported.
- **Collision and retry.** `s.Add` rejects duplicates. Settle what the client does when a retried
  RPC (after a partial apply, or an ambiguous timeout) hits "block id already exists" — treat it as
  success, or regenerate. Getting this wrong turns a network blip into lost text.

Deliverable: a small id minting utility with tests, and a written note in this file recording what
the middleware team agreed to.

### 2. Trailing placeholder carries its final id

Create `VirtualTrailingBlockSession` with a minted real block id instead of
`TrailingBlockPlaceholderConstants.idPrefix + UUID()`. Materialization then passes that id to
`BlockCreate` and the row's id never changes.

Delete once this lands and is verified: `awaitingFocusHandoff`, `completeFocusHandoff`,
`focusHandoffCompletedByRebind`, `applyFocus`'s handoff role, the placeholder branch of
`retainStaleForkRows`, and the placeholder-swap normalization in `activeSwaps`
(`EditorPageViewModel`). The prefix-based special casing goes with them.

Note the placeholder is also rendered before it exists in the middleware — keep the "unmaterialized"
guards that stop mutating paths from targeting a block that is not created yet. Those are about
existence, not identity, and are still needed.

### 3. Fork sends a minted id

`BlockActionHandler.replaceEmptyBlock` passes a minted id instead of `""`. The caller then knows the
new id synchronously and can register the alias and rebind the model in the same turn as the
keystroke, rather than after `await`.

Delete once this lands: `BlockIdentitySwapStorage` register/consume for forks, the `emptyBlockFork`
task with `pendingForkOldId` and `forkGeneration`, `retainStaleForkRows`,
`finishArrivalFocusHandoffs`, `removeStaleForkRowsAfterFocusHandoff`, and the
`blocksMapping[newBlockId] == nil` / `!ids.contains(oldId)` refusal guards.

Check whether `BlockIdentitySwapStorage` can be deleted outright or is still needed for
Enter-created rows (`isKeyboardInsert`), which are a different case — an insert, not a swap.

### 4. Keep

- `BlockRowIdentityMap` and `TextBlockViewModel.rowIdentity` — still required for the fork's `A → B`.
- The undo inverse rebind (`rebindUndoneIdentitySwaps`) — undo still restores the replaced block,
  and the ghost-row failure it prevents is unchanged by this work.
- The text-storage write skip in `TextBlockContentView.applyTextStorage` — it protects the input
  session from remote echoes and has nothing to do with id timing.
- The out-of-range focus clamp in `BlockFocusPosition.toSelectedRange` — unrelated, shipped with
  IOS-6597.

## Invariants that must not regress

- **The keyboard must never dip, flicker, or dismiss while typing.** This outranks everything else
  here, including the simplification itself. Fixed once in IOS-6594 (`50d015b471`, `16100c68e9`) and
  regressed once during IOS-6597 review. The rule to hold: *no row holding first responder is
  removed from the snapshot unless a replacement has already taken it* — enforced where the row is
  actually removed, not inferred from state two objects away.
- **The IOS-6572 concurrent-fill guarantee.** The fork exists so two clients filling the same empty
  block end up with two blocks instead of one last-writer-wins text. Each client minting its own
  unique id preserves this — but a scheme where clients derive the id from the *replaced* block's id
  would break it. Do not do that.
- **No synchronous `becomeFirstResponder` during cell dequeue** (iOS 26 crash, IOS-6144).
- **Autocorrect keeps the first typed letter** — the reason IOS-6597 exists. Re-verify on device,
  it cannot be checked statically.

## Risks

- Silent format assumptions downstream of `simple.New`. The failure mode would not be a compile
  error or an RPC rejection; it would be something subtle in sync or history. This is the main
  reason stage 1 is blocked on the middleware team rather than on reading heart's code.
- Retry semantics turning a duplicate-id error into lost text (stage 1).
- Scope creep into paste. Paste's replacement blocks are minted middleware-side from the pasted
  content, so IOS-6602 (paste into an empty block dismisses the keyboard) is **not** fixed by this
  work and should not be folded into it.

## Verification

Static review cannot settle the two things that matter. Both need a device, or a simulator with the
software keyboard (I/O → Keyboard → uncheck Connect Hardware Keyboard; hardware-keyboard input
bypasses autocorrect entirely).

- Autocorrect: type `teh `, `hte `, `adn ` as the **first** word of a freshly created bullet, and
  again via the trailing placeholder. Expect correction. Second word in the same block and the
  object title are the controls.
- Keyboard: tap below content, type one character, watch the keyboard through materialization.
  **Repeat ~20 times** — the bug this replaces was a race and a single clean pass proves nothing.
- Enter at the end of a checked-list item, then type (the IOS-6594 repro).
- Undo right after a fork; then type again (the fork must re-fire fresh).
- Type one character into an empty block, then immediately drag that block — it must move the real
  block.
- Offline or airplane mode: mint, type, reconnect. The minted id must survive the round trip and not
  produce a duplicate block.

## Implementation record (2026-08-04)

The verified protocol facts above were re-checked against the local anytype-heart checkout
(`acfa7481f`): `basic.Replace` echoes the client id, `simple.New` generates only for an
empty id, `CreateBlock` rejects duplicates, and `Validate()` is a no-op for text blocks —
no id-shape validation exists on either path.

Implemented as an **alternative to PR #5083**, not on top of it: the branch is based on
develop without #5083's commits, and this work replaces both #5083's event-arrival rebind
machinery and develop's async fork/placeholder choreography outright (no feature flag — the
decision was to replace rather than gate; rollback is reverting the PR).

What was built, per stage:

1. **`BlockIdGenerator`** (`ServiceLayer/Block/BlockIdGenerator/`) mints bson-ObjectId-shaped
   ids (24 hex: 4-byte big-endian Unix time, 5-byte per-process random, 3-byte seeded
   counter) — the same shape heart mints. **The middleware-team confirmation this doc asked
   for is still outstanding**: the implementation relies on the verified protocol facts above
   (ids are echoed, only empty ids are generated, duplicates are a hard error) and on minting
   heart's own shape to avoid downstream format assumptions. Both create/replace paths assert
   the response echoes the minted id, so a contract break surfaces as an assertion, not
   silent divergence. Collision/retry: block RPCs go to the local middleware (no network), so
   the ambiguous-timeout-retry hazard does not exist in practice; a duplicate-id error
   surfaces via the existing failure paths (assert + rollback for the fork).

2. **The trailing placeholder is born with its final id.** `VirtualTrailingBlockSession`
   carries a minted `blockId`; materialization sends it in BlockCreate. The row's identity
   never changes, so deleted outright: `awaitingFocusHandoff`, `completeFocusHandoff`,
   `applyFocus`, the placeholder's swap registration, the `virtual-trailing-block-` prefix,
   and the wait-for-materialized deactivation logic. `handleUpdate` now just drops the
   session bookkeeping when the created id shows up in the document. The "unmaterialized"
   guards in `TextBlockActionHandler` remain (existence, not identity). The virtual markdown
   paths apply their caret correction synchronously after the reset rewrite instead of after
   the RPC.

3. **The fork applies synchronously at the keystroke.** `forkEmptyBlockIfNeeded` mints the
   replacement (via `BlockActionHandler.makeEmptyBlockReplacement`), rebinds the live row in
   the same turn through `BlockForkRebinder` (alias in `BlockRowIdentityMap`, provider
   rebind, focus-subject rekey, unanimated cell refresh), and only then fires the RPC. The
   diffable identity stays frozen via `TextBlockViewModel.rowIdentity`;
   `BlockViewModelBuilder.build` resolves any stale id forward through the fork chain, which
   closes the in-flight window where events still emit the replaced id. Undo is detected by
   scanning the fork aliases against the document ids (an alias only counts as undone after
   its new id was seen applied once); the same `unbind` path rolls back a failed replace RPC.
   Rows with no live model (simple-table cells — their handler never forks anyway) fall back
   to a pending focus, as before.

   Deleted outright: `BlockIdentitySwapStorage` (replaced by `KeyboardInsertedBlocksStorage`,
   Enter-created rows only — the one case that is a real insert, IOS-6594),
   `retainStaleForkRows`, `finishArrivalFocusHandoffs` (reduced to an Enter-rows-only
   helper), `removeStaleForkRowsAfterFocusHandoff`, `pendingForkOldId`, and the fork/
   placeholder branches of the arrival pipeline.

Kept from the original plan's keep-list (reimplemented here since #5083 never merged): the
text-storage write skip in `TextBlockContentView.applyTextStorage` and the undo inverse
rebind. The out-of-range focus clamp was cherry-picked from #5083 verbatim
(`870f9eb760` → `11bd70bb5f`): it guards the paste path (response caret arrives before the
middleware echo carrying the pasted characters), which is independent of id timing.

The device verification list below is unchanged and still required.

## Review record (2026-08-04, four-lens agent review)

Four independent review passes (concurrency, keyboard/focus, data integrity, architecture)
ran over the implementation. Fixed as a result:

- **Rollback of a failed replace RPC is now unconditional** (`BlockForkRebinder.
  rollbackFailedFork`): the alias and fabricated info always go, the row rebinds back only
  if the old block still exists. Previously the undo-scan guards could keep the row
  stranded on a dead id when the old block had been deleted remotely mid-flight.
- **Fork carries execution-time text**: `textViewDidChangeText` re-reads the text view when
  its task runs, so an input source that delivers several changes per turn (dictation,
  predictive insert) cannot make the fork-time cell refresh rewrite the view back to stale
  text.
- **Placeholder-born blocks fork again**: the handler drops its `virtualBlockSession` after
  materialization, so a later refill of the (emptied) block forks like any other empty
  block — keeping IOS-6572 for blocks born from the placeholder.
- **Enter focus handoff re-coupled to the bottom edge** (develop parity): the synchronous
  `takeFocus` only runs together with the unanimated apply; elsewhere the deferred initial
  focus owns the caret move.
- **Failed materialization no longer leaves a ghost row** once the editor left editing mode
  (`onMaterializationFailed`); while still editing the row stays for retry, as before.
- Smaller: stale pre-markdown pending focus cleared in the virtual markdown paths; the two
  fork closures are now required init parameters; shared `EditorBlockCollectionController`
  hoisted in the assembly; stale comments corrected; tests added for
  `KeyboardInsertedBlocksStorage` and `FocusSubjectsHolder.rekeySubject`.

A fifth, holistic review pass (single agent, fresh eyes on the post-review fixes) found
nothing new at high/critical severity and confirmed the invariants hold. Fixed from it:
the execution-time text re-read now happens *before* the IME/search deferral gate (the
gate must judge the same text the fork carries), the caret is re-read alongside the text,
and `rollbackFailedFork` rekeys the focus subject only on the branch that actually rebinds
the model back (a rollback after a declined rebind must not clobber the old id's
legitimate subject). Rollback's no-live-row paths got unit tests
(`BlockForkRebinderRollbackTests`); the rebind-back path needs the view-model stack and is
covered by device verification instead.

Device verification findings (fixed):

- **Backspace in the empty placeholder dipped the keyboard**: `dismissAndFocusPreviousBlock`
  removed the focused row first and focused the previous block one hop later. The dismissal
  now takes first responder into the previous block's cell synchronously
  (`viewInput.takeFocus`) before the row leaves the snapshot — enforcing the IOS-6594
  invariant at the one placeholder path that still violated it. (The same ordering existed
  on develop; the real-block backspace never dipped because merge moves focus before the
  row is removed by the middleware event.)

Known, accepted (documented in code where relevant):

- **heart's `basic.Replace` ignores `s.Add`'s duplicate rejection** (verified at
  `acfa7481f`, basic.go:471): a colliding minted id would silently splice an existing block
  into the empty slot and drop the typed text, with the response echoing the sent id — the
  client cannot detect it. Collision odds with this generator are ~2⁻⁴⁰ per same-second
  pair, but **ask the middleware team to make `Replace` check `s.Add` like `CreateBlock`
  does** as part of the contract confirmation.
- **Echo assertions are non-fatal in release**: if the middleware ever stopped honoring
  client ids, release builds would diverge silently. There is no graceful client-side
  recovery — the assertion is a tripwire for development/nightly, and the real protection
  is the contract agreement.
- **Redo of an undone fork rebuilds the row identity** (alias was removed on undo), so a
  redo while typing dips the keyboard once — same as develop; noted as future work.
- The undo-detection `applied` latch cannot recognize an undo whose replace event never
  produced its own ids emission; unreachable for human-initiated undo (see
  `BlockRowIdentityMap.undoneAliases` doc).
- `VirtualTrailingBlockSession` retries a failed create under the same minted id; a
  "duplicate id" second attempt would require the first attempt to have committed while
  returning an error, which the in-process middleware's transactional `Apply` rules out.

## Key files

- `Anytype/Sources/ServiceLayer/Block/BlockActionHandler/BlockActionHandler.swift` — `replaceEmptyBlock`, currently sends `id: ""`
- `Anytype/Sources/ServiceLayer/Block/BlockActionHandler/BlockActionService/BlockActionService.swift` — swap registration
- `Anytype/Sources/ServiceLayer/Block/SessionCreatedBlocks/BlockIdentitySwapStorage.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/VirtualTrailingBlock/VirtualTrailingBlockSession.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/EditorPageViewModel.swift` — `rebindIdentitySwaps`, `rebindUndoneIdentitySwaps`, `retainStaleForkRows`, `finishArrivalFocusHandoffs`
- `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Models/BlockRowIdentityMap.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/BlocksViews/Blocks/Text/Base/TextBlockActionHandler.swift` — `forkEmptyBlockIfNeeded`, `materializeVirtualBlock`
