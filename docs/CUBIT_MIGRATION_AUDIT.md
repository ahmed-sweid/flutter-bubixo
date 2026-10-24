# Bubixo — Cubit Migration Audit and Plan

Target branch: `feature/database-bootstrap`

## Goal

Move application and feature-level UI state into focused Cubits without changing the existing visual design or user flows. Keep repositories responsible for data access, and keep speech/platform work in services. Do not create one global Cubit for every concern.

## Current audit (from the branch)

### Existing state management
- `WordsCubit` + `WordsState` exist and are provided to `WordsScreen`.
- `WordsScreen` still has local `setState` state for dictionary loading, translation/loading/errors, filters, and some custom-word UI. This is only a partial Cubit migration.
- The root app currently starts at `SplashScreen`; `BubixoShell` owns selected tab and refresh keys with `setState`.

### Feature state still in widgets
- **Learn:** `LearnScreen` loads story count and learner progress directly from `SharedPreferences` and `StoryRepository` using a `FutureBuilder`; retry uses `setState`.
- **Lessons:** `LessonsScreen` loads lessons and completed lesson IDs itself; lesson navigation and last-activity writes happen in the widget.
- **Lesson detail:** quiz index, selected answer, and answer visibility use local `setState`; completion and quiz stats are written through `LearningProgressRepository`.
- **Stories:** `DiscoverScreen` loads stories via `FutureBuilder` and stores the selected level locally. `StoryDetailScreen` owns reader index/interaction state and writes reading progress to `SharedPreferences`.
- **Practice:** `PracticeScreen` loads progress/data via `FutureBuilder`; practice activity owns quiz index, selected answer, checked state, and session writes locally.
- **Grammar:** `GrammarScreen` loads topics via `FutureBuilder`; topic detail owns its interaction state with `setState`.
- **Navigation:** `BubixoShell` owns selected bottom-navigation index and refresh keys locally.

### Data sources and persistence
- Static course content currently comes from JSON assets (lessons, words, grammar, stories, sentence-builder exercises, and game words).
- `LearningProgressRepository` still uses `SharedPreferences` for lesson completion, last lesson, and quiz statistics.
- Story reading progress and practice counters also use `SharedPreferences`.
- Drift/SQLite infrastructure and a content seeder exist; vocabulary has a repository and Cubit. Before migrating other persistence, map existing keys and tables and add migration tests. Do not delete or silently reset legacy user data.
- `SpeechService` should remain a service; Cubits may invoke it through an injected dependency where needed, but widgets should not own persistence/business rules.

## Target responsibilities

- **App/navigation:** `AppCubit` or `NavigationCubit` for selected destination and shell-level state; keep route/navigation side effects in the presentation layer.
- **Learn:** `LearnCubit` for dashboard progress, recommendations' input data, loading/error/retry.
- **Lessons:** `LessonsCubit` for lesson list and completion summary; `LessonDetailCubit` for quiz answers and lesson completion.
- **Stories:** `StoriesCubit` for list, filtering, and loading; `StoryReaderCubit` for reading position/progress.
- **Words:** finish moving screen-owned dictionary, translation, filters, and loading/error state into focused Cubit state (translation may be a separate Cubit if it reduces coupling).
- **Practice:** `PracticeCubit` for available activities and progress; `PracticeSessionCubit` for per-session answers and outcomes.
- **Grammar:** `GrammarCubit` for topic list/loading; `GrammarTopicCubit` for topic-level interactions where stateful.
- **Settings:** introduce a settings Cubit only for real persisted settings/preferences present in the product; avoid inventing features.

## Migration order

1. **Baseline and safety:** keep work on this feature branch; inspect tests and run analyzer/tests before broad changes.
2. **Learn dashboard:** introduce explicit state + Cubit, replace its `FutureBuilder` and progress loading in the widget, preserve the current UI and retry behavior.
3. **Lessons and quiz:** move lesson loading/progress and quiz/session state to Cubits; keep navigation and speech service boundaries intact.
4. **Stories and reader:** move story loading/filtering and reader progress/index state to Cubits.
5. **Practice and grammar:** separate catalog state from per-session interaction state; migrate progress writes behind repositories.
6. **Words completion:** remove remaining business/UI state from `WordsScreen` and consolidate state ownership.
7. **Shell + app wiring:** centralize shell state where it adds value and provide Cubits consistently; avoid needless global state.
8. **Persistence alignment:** move durable learner progress to Drift in explicit schema migrations, with one-time import from SharedPreferences and tests for legacy data.
9. **Validation:** run `flutter analyze`, unit/widget/migration tests, and verify the main user flows.

## Guardrails

- Preserve existing UI, labels, navigation order, and behavior unless a separately approved UX change is requested.
- Keep one Cubit per coherent feature/session concern, not per widget and not one giant app Cubit.
- Keep static content in JSON assets unless there is a demonstrated need to query/update it in SQLite.
- Keep all user progress and saved words intact through migrations.
- Make small, reviewable commits and validate each phase before proceeding.
