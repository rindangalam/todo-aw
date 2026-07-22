import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/category.dart';
import 'package:todoaw/providers/category_provider.dart';
import 'package:todoaw/data/repositories/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockCategoryRepository();
  });

  Future<void> awaitAsync() => Future(() {});

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('CategoryListNotifier', () {
    test('loads categories on initialization', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => [
            const Category(uuid: '1', name: 'Work'),
            const Category(uuid: '2', name: 'Personal'),
          ]);

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(categoryListProvider);
      await container.read(categoryListProvider.notifier).load();
      final state = container.read(categoryListProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 2);
      expect(state.value!.first.name, 'Work');
    });

    test('create adds a category and reloads', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);
      when(() => mockRepo.create(
            name: any(named: 'name'),
            color: any(named: 'color'),
            icon: any(named: 'icon'),
          )).thenAnswer((_) async => const Category(uuid: '1', name: 'New'));

      final container = createContainer();
      addTearDown(container.dispose);

      await awaitAsync();
      await container.read(categoryListProvider.notifier).create(name: 'New');

      verify(() => mockRepo.create(name: 'New', color: 0xFF5B67CA)).called(1);
    });

    test('delete removes a category and reloads', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => [
            const Category(uuid: '1', name: 'Work'),
          ]);
      when(() => mockRepo.delete(any())).thenAnswer((_) async => {});

      final container = createContainer();
      addTearDown(container.dispose);

      await awaitAsync();
      await container.read(categoryListProvider.notifier).delete('1');

      verify(() => mockRepo.delete('1')).called(1);
    });
  });
}
