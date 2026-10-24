import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/features/discover/presentation/cubit/stories_cubit.dart';
import 'package:bubixo/features/discover/presentation/cubit/stories_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StoriesCubit cubit;

  setUp(() {
    cubit = StoriesCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads story catalog and filters by level', () async {
    await cubit.load();

    expect(cubit.state.status, StoriesStatus.success);
    expect(cubit.state.stories, hasLength(12));
    expect(cubit.state.visibleStories, hasLength(12));

    cubit.selectLevel(1);
    expect(cubit.state.selectedLevel, 1);
    expect(cubit.state.visibleStories, isNotEmpty);
    expect(cubit.state.visibleStories.every((story) => story.level == 1), isTrue);

    cubit.clearLevelFilter();
    expect(cubit.state.selectedLevel, isNull);
    expect(cubit.state.visibleStories, hasLength(12));
  });
}
