import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/profile_screen.dart';
import 'features/onboarding/consent_screen.dart';
import 'features/assessments/assessments_list_screen.dart';
import 'features/assessments/assessment_form_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/privacy/privacy_center_screen.dart';
import 'features/resources/resources_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'consent',
          builder: (context, state) => const ConsentScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/assessments',
      builder: (context, state) => const AssessmentsListScreen(),
    ),
    GoRoute(
      path: '/assessments/form',
      builder: (context, state) => const AssessmentFormScreen(),
    ),
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyCenterScreen(),
    ),
    GoRoute(
      path: '/resources',
      builder: (context, state) => const ResourcesScreen(),
    ),
  ],
);
