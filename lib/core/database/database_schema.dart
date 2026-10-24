/// SQL schema for the first local database version.
///
/// This project uses Drift's migration and query APIs. The SQL is kept here
/// during the initial migration from SharedPreferences/JSON; feature DAOs can
/// be converted to generated typed tables incrementally without changing the
/// persisted table names.
const int currentDatabaseSchemaVersion = 1;

const List<String> createDatabaseSchemaV1 = <String>[
  '''
  CREATE TABLE IF NOT EXISTS lessons (
    id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    minutes INTEGER NOT NULL CHECK (minutes > 0),
    intro TEXT NOT NULL,
    tip TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    content_version INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS lesson_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lesson_id TEXT NOT NULL REFERENCES lessons(id) ON DELETE RESTRICT,
    position INTEGER NOT NULL CHECK (position >= 0),
    english TEXT NOT NULL,
    turkish TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (lesson_id, position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS lesson_quizzes (
    id TEXT PRIMARY KEY NOT NULL,
    lesson_id TEXT NOT NULL REFERENCES lessons(id) ON DELETE RESTRICT,
    position INTEGER NOT NULL CHECK (position >= 0),
    question TEXT NOT NULL,
    options_json TEXT NOT NULL,
    answer_index INTEGER NOT NULL CHECK (answer_index >= 0),
    explanation TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (lesson_id, position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS grammar_topics (
    id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    badge TEXT NOT NULL,
    formula TEXT NOT NULL,
    explanation TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    content_version INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS grammar_examples (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id TEXT NOT NULL REFERENCES grammar_topics(id) ON DELETE RESTRICT,
    position INTEGER NOT NULL CHECK (position >= 0),
    english TEXT NOT NULL,
    turkish TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (topic_id, position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS grammar_quizzes (
    id TEXT PRIMARY KEY NOT NULL,
    topic_id TEXT NOT NULL REFERENCES grammar_topics(id) ON DELETE RESTRICT,
    position INTEGER NOT NULL CHECK (position >= 0),
    question TEXT NOT NULL,
    options_json TEXT NOT NULL,
    answer_index INTEGER NOT NULL CHECK (answer_index >= 0),
    explanation TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (topic_id, position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS stories (
    id TEXT PRIMARY KEY NOT NULL,
    level INTEGER NOT NULL CHECK (level > 0),
    title TEXT NOT NULL,
    title_tr TEXT NOT NULL,
    intro TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    content_version INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS story_lines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    story_id TEXT NOT NULL REFERENCES stories(id) ON DELETE RESTRICT,
    position INTEGER NOT NULL CHECK (position >= 0),
    english TEXT NOT NULL,
    turkish TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (story_id, position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS story_line_words (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    line_id INTEGER NOT NULL REFERENCES story_lines(id) ON DELETE CASCADE,
    position INTEGER NOT NULL CHECK (position >= 0),
    english TEXT NOT NULL,
    turkish TEXT NOT NULL,
    normalized_english TEXT NOT NULL,
    normalized_turkish TEXT NOT NULL,
    UNIQUE (line_id, position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS vocabulary_entries (
    id TEXT PRIMARY KEY NOT NULL,
    english TEXT NOT NULL,
    turkish TEXT NOT NULL DEFAULT '',
    normalized_english TEXT NOT NULL,
    normalized_turkish TEXT NOT NULL DEFAULT '',
    emoji TEXT,
    kind TEXT NOT NULL DEFAULT 'word',
    source TEXT NOT NULL DEFAULT 'dictionary',
    created_at INTEGER,
    UNIQUE (normalized_english, normalized_turkish)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS sentence_exercises (
    id TEXT PRIMARY KEY NOT NULL,
    source_position INTEGER NOT NULL CHECK (source_position >= 0),
    category TEXT NOT NULL,
    level INTEGER NOT NULL CHECK (level > 0),
    turkish TEXT NOT NULL,
    english TEXT NOT NULL,
    note TEXT NOT NULL,
    distractors_json TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (category, level, english, turkish)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS game_words (
    id TEXT PRIMARY KEY NOT NULL,
    source_position INTEGER NOT NULL CHECK (source_position >= 0),
    english TEXT NOT NULL,
    turkish TEXT NOT NULL,
    theme TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (english, turkish, theme)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS saved_words (
    word_id TEXT PRIMARY KEY NOT NULL REFERENCES vocabulary_entries(id)
      ON DELETE RESTRICT,
    saved_at INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS review_words (
    word_id TEXT PRIMARY KEY NOT NULL REFERENCES vocabulary_entries(id)
      ON DELETE RESTRICT,
    added_at INTEGER NOT NULL,
    last_reviewed_at INTEGER,
    due_at INTEGER,
    repetition_count INTEGER NOT NULL DEFAULT 0 CHECK (repetition_count >= 0)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS lesson_progress (
    lesson_id TEXT PRIMARY KEY NOT NULL REFERENCES lessons(id)
      ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'not_started'
      CHECK (status IN ('not_started', 'in_progress', 'completed')),
    last_quiz_position INTEGER,
    last_opened_at INTEGER,
    completed_at INTEGER
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS lesson_quiz_attempts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lesson_quiz_id TEXT NOT NULL REFERENCES lesson_quizzes(id)
      ON DELETE RESTRICT,
    selected_answer_index INTEGER,
    is_correct INTEGER NOT NULL CHECK (is_correct IN (0, 1)),
    answered_at INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS story_progress (
    story_id TEXT PRIMARY KEY NOT NULL REFERENCES stories(id)
      ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'started'
      CHECK (status IN ('started', 'completed')),
    last_line_position INTEGER NOT NULL DEFAULT 0
      CHECK (last_line_position >= 0),
    started_at INTEGER,
    last_read_at INTEGER,
    completed_at INTEGER
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS practice_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    activity_type TEXT NOT NULL
      CHECK (activity_type IN ('sentence_builder', 'word_game', 'grammar')),
    started_at INTEGER NOT NULL,
    completed_at INTEGER,
    question_count INTEGER NOT NULL DEFAULT 0 CHECK (question_count >= 0),
    correct_count INTEGER NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
    status TEXT NOT NULL DEFAULT 'in_progress'
      CHECK (status IN ('in_progress', 'completed', 'abandoned')),
    CHECK (correct_count <= question_count OR question_count = 0)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS practice_answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL REFERENCES practice_sessions(id)
      ON DELETE CASCADE,
    question_position INTEGER NOT NULL CHECK (question_position >= 0),
    sentence_exercise_id TEXT REFERENCES sentence_exercises(id)
      ON DELETE RESTRICT,
    game_word_id TEXT REFERENCES game_words(id) ON DELETE RESTRICT,
    grammar_quiz_id TEXT REFERENCES grammar_quizzes(id) ON DELETE RESTRICT,
    selected_answer TEXT,
    is_correct INTEGER NOT NULL CHECK (is_correct IN (0, 1)),
    answered_at INTEGER NOT NULL,
    CHECK (
      (sentence_exercise_id IS NOT NULL) +
      (game_word_id IS NOT NULL) +
      (grammar_quiz_id IS NOT NULL) = 1
    ),
    UNIQUE (session_id, question_position)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS learning_stats (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    legacy_quiz_attempts INTEGER NOT NULL DEFAULT 0 CHECK (legacy_quiz_attempts >= 0),
    legacy_quiz_correct INTEGER NOT NULL DEFAULT 0 CHECK (legacy_quiz_correct >= 0),
    legacy_practice_sessions INTEGER NOT NULL DEFAULT 0 CHECK (legacy_practice_sessions >= 0),
    legacy_practice_correct INTEGER NOT NULL DEFAULT 0 CHECK (legacy_practice_correct >= 0),
    updated_at INTEGER NOT NULL,
    CHECK (legacy_quiz_correct <= legacy_quiz_attempts),
    CHECK (legacy_practice_correct >= 0)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS app_state (
    key TEXT PRIMARY KEY NOT NULL,
    value TEXT NOT NULL,
    updated_at INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS content_dataset_versions (
    dataset_key TEXT PRIMARY KEY NOT NULL,
    version INTEGER NOT NULL,
    record_count INTEGER NOT NULL CHECK (record_count >= 0),
    seeded_at INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX IF NOT EXISTS idx_vocabulary_normalized_english ON vocabulary_entries(normalized_english)',
  'CREATE INDEX IF NOT EXISTS idx_vocabulary_normalized_turkish ON vocabulary_entries(normalized_turkish)',
  'CREATE INDEX IF NOT EXISTS idx_stories_level_active ON stories(level, is_active)',
  'CREATE INDEX IF NOT EXISTS idx_sentence_exercises_level_category ON sentence_exercises(level, category, source_position)',
  'CREATE INDEX IF NOT EXISTS idx_game_words_theme_position ON game_words(theme, source_position)',
  'CREATE INDEX IF NOT EXISTS idx_lesson_points_parent_position ON lesson_points(lesson_id, position, is_active)',
  'CREATE INDEX IF NOT EXISTS idx_lesson_quizzes_parent_position ON lesson_quizzes(lesson_id, position, is_active)',
  'CREATE INDEX IF NOT EXISTS idx_grammar_examples_parent_position ON grammar_examples(topic_id, position, is_active)',
  'CREATE INDEX IF NOT EXISTS idx_grammar_quizzes_parent_position ON grammar_quizzes(topic_id, position, is_active)',
  'CREATE INDEX IF NOT EXISTS idx_story_lines_parent_position ON story_lines(story_id, position, is_active)',
  'CREATE INDEX IF NOT EXISTS idx_story_line_words_line_position ON story_line_words(line_id, position)',
  'CREATE INDEX IF NOT EXISTS idx_practice_sessions_type_completion ON practice_sessions(activity_type, completed_at)',
  'CREATE INDEX IF NOT EXISTS idx_lesson_quiz_attempts_quiz_time ON lesson_quiz_attempts(lesson_quiz_id, answered_at)',
];
