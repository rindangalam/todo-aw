import 'package:shared_preferences/shared_preferences.dart';

class TourService {
  static const _introSeen = 'tour_intro_seen';
  static const _coachmarkHome = 'tour_coachmark_home';
  static const _coachmarkNotes = 'tour_coachmark_notes';

  static Future<bool> isIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introSeen) ?? false;
  }

  static Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeen, true);
  }

  static Future<bool> isCoachmarkHomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_coachmarkHome) ?? false;
  }

  static Future<void> markCoachmarkHomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_coachmarkHome, true);
  }

  static Future<bool> isCoachmarkNotesSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_coachmarkNotes) ?? false;
  }

  static Future<void> markCoachmarkNotesSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_coachmarkNotes, true);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_introSeen);
    await prefs.remove(_coachmarkHome);
    await prefs.remove(_coachmarkNotes);
  }
}
