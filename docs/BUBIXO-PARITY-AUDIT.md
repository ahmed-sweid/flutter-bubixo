# Bubixo Web → Flutter: Parity Audit

Date: 2026-10-23  
Working branch: `feature/ux-responsive-word-filters`

This audit compares the source repository `ahmed-sweid/bubixo` (branch `ux/four-tab-navigation`) with the Flutter application. It distinguishes verified asset counts from behavior that still needs implementation or runtime validation.

## Content inventory

The six structured content assets exist in Flutter and parse as JSON:

| Content | Source of truth | Flutter asset | Verified Flutter records | Assessment |
|---|---|---|---:|---|
| Lessons | `data.js` / `UNITS` | `assets/data/lessons.json` | 10 | Count matches source inventory |
| Vocabulary | `data2.js` / `WORDS` | `assets/data/words.json` | 3,000 | Count matches source inventory |
| Grammar | `data2.js` / `TENSES` | `assets/data/grammar.json` | 6 | Count matches source inventory |
| Stories | `data5.js` / `STORIES` | `assets/data/stories.json` | 12 | Count matches source inventory |
| Sentence builder | `data6.js` / `BUILDER` | `assets/data/sentence_builder.json` | 120 | Count matches source inventory |
| Game vocabulary | `data7.js` / `GAMEWORDS` | `assets/data/game_words.json` | 240 | Count matches source inventory |

**Important:** Matching record counts do not prove byte-for-byte or field-by-field parity. A deterministic comparison against the source JavaScript data is still required to prove that no records, translations, notes, options, ordering, or audio mappings were lost.

## Behavior parity review

| Source capability | Flutter status | Remaining work |
|---|---|---|
| Four-tab navigation: Learn, Words, Practice, Discover | Present | Verify end-to-end on iOS |
| Lessons and quiz validation | Present | Run complete tests and verify progress behavior |
| Search/filter vocabulary and saved/review lists | Present | Run tests and check edge cases |
| Stories with English/Turkish lines and word mappings | Present | Run reader flow on iOS |
| Resume last story | Implemented; persistence was made eager before opening the reader | Confirm widget test passes |
| TTS speech | Flutter TTS service exists | Verify voice availability, lifecycle, and playback on device |
| Source's generated MP3 library and exact text/audio index | Not yet shown to be integrated in Flutter | Port the manifest/repository and verify URLs/rights/accessibility, or explicitly accept TTS as a product change |
| Source translation panel (`/text-tools/health`, `/token`, `/translate`) | Not yet shown to be integrated in Flutter | Implement a typed repository, token expiry/retry, timeout/error handling, UI, and translation history only after confirming API contract and service availability |
| Source microphone-based speech recognition | Not yet shown to be integrated in Flutter | Decide whether to port with platform permissions or intentionally defer; test supported devices |
| Source spaced-repetition scheduling and daily streak/progress | Flutter has local progress-related code, but equivalent scheduling/streak parity is not yet proven | Compare source `yol.js` state schema/algorithms with Flutter progress implementation and add migration/behavior tests |
| Translation history (`bx-eng-ceviri`) | Not yet shown to be integrated | Port only if translation UI is included |
| Daily sentence, level test, full A1→A2 learning path | Full parity not yet proven | Map each source flow to a Flutter screen and implement/test gaps |
| PWA install/offline/service-worker behavior | Not directly applicable to a native iOS app | Define native offline/cache expectations instead |

## Validation still required

1. Run `flutter analyze` and the full `flutter test` suite on the latest branch.
2. Confirm the last-story-resume widget test passes; previous CI output showed this assertion failing.
3. Compare source and Flutter content field-by-field with a repeatable script, not just counts.
4. Verify audio and translation service contracts from the source implementation and service responses; do not hard-code secrets in the app.
5. Run the main flows on an iOS simulator/device: first launch, lesson completion/resume, word saving/review, story reader/translation, TTS, sentence builder, game, and app relaunch persistence.
6. Restore the local stash only after the branch is stable, and review its changes before committing anything.

## Current conclusion

The structured core content is present in the expected counts. Full source parity is **not yet verified**. Audio assets/index integration, translation service behavior, speech recognition, spaced repetition/daily progression, and the full learning-path/level-test flow need an explicit implementation-or-defer decision and validation.
