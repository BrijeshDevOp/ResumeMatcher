// To use dummy service:

// import 'package:frontend/services/match_service_interface.dart';
// import 'dummy_match_service.dart' as service;
// final MatchServiceInterface matchService = service.DummyMatchService();

// To use real API service:

import 'package:frontend/services/match_service_interface.dart';
import 'real_match_service.dart' as service;

final MatchServiceInterface matchService = service.RealMatchService();
