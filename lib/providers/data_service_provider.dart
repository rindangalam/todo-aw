import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/data_service.dart';

final dataServiceProvider = Provider<DataService>((ref) => DataService());
