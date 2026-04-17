import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/match_plan.dart';
import 'models/prediction_item.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/teams/add_edit_team_screen.dart';
import 'screens/planner/add_edit_match_screen.dart';
import 'screens/planner/match_details_screen.dart';
import 'screens/predictions/predictions_screen.dart';
import 'screens/predictions/add_edit_prediction_screen.dart';
import 'screens/journal/add_edit_journal_screen.dart';
import 'screens/tournaments/tournaments_screen.dart';
import 'screens/tournaments/add_edit_tournament_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'widgets/app_shell.dart';
import 'widgets/debug_overlay.dart';

class FanArenaApp extends StatelessWidget {
  const FanArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();

    return MaterialApp(
      title: 'FanArena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: provider.themeModeEnum,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      builder: (context, child) => Stack(
        children: [
          child!,
          const Visibility(
            visible: false,
            child: DebugOverlay(),
          ),
        ],
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case '/onboarding':
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const AppShell(),
        );
      case '/add-team':
        return MaterialPageRoute(
          builder: (_) => const AddEditTeamScreen(),
        );
      case '/edit-team':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddEditTeamScreen(),
        );
      case '/add-match':
        return MaterialPageRoute(
          builder: (_) => const AddEditMatchScreen(),
        );
      case '/edit-match':
        return MaterialPageRoute(
          builder: (_) => AddEditMatchScreen(
            match: settings.arguments as MatchPlan?,
          ),
        );
      case '/match-details':
        return MaterialPageRoute(
          builder: (_) => MatchDetailsScreen(
            matchId: settings.arguments as String,
          ),
        );
      case '/predictions':
        return MaterialPageRoute(
          builder: (_) => const PredictionsScreen(),
        );
      case '/add-prediction':
        return MaterialPageRoute(
          builder: (_) {
            final args = settings.arguments;
            if (args is String) {
              return AddEditPredictionScreen(matchId: args);
            }
            return const AddEditPredictionScreen();
          },
        );
      case '/edit-prediction':
        return MaterialPageRoute(
          builder: (_) => AddEditPredictionScreen(
            prediction: settings.arguments as PredictionItem?,
          ),
        );
      case '/add-journal':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddEditJournalScreen(),
        );
      case '/edit-journal':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddEditJournalScreen(),
        );
      case '/tournaments':
        return MaterialPageRoute(
          builder: (_) => const TournamentsScreen(),
        );
      case '/add-tournament':
        return MaterialPageRoute(
          builder: (_) => const AddEditTournamentScreen(),
        );
      case '/edit-tournament':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddEditTournamentScreen(),
        );
      case '/planner':
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 2),
        );
      case '/teams':
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 1),
        );
      case '/journal':
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 3),
        );
      case '/stats':
        return MaterialPageRoute(
          builder: (_) => const StatsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
