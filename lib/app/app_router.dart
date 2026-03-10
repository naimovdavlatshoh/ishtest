import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/feed/presentation/feed_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/profile_me_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/create_profile_screen.dart';
import '../features/chat/presentation/chat_list_screen.dart';
import '../features/chat/presentation/chat_room_screen.dart';
import '../features/chat/presentation/invitations_screen.dart';
import '../features/jobs/presentation/jobs_screen.dart';
import '../features/jobs/presentation/job_detail_screen.dart';
import '../features/jobs/presentation/saved_jobs_screen.dart';
import '../features/jobs/presentation/my_jobs_screen.dart';
import '../features/jobs/presentation/job_applications_screen.dart';
import '../features/jobs/presentation/job_form_screen.dart';
import '../features/jobs/presentation/my_applications_screen.dart';
import '../features/employees/presentation/employees_screen.dart';
import '../features/main/presentation/main_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/companies/presentation/pages/my_companies_page.dart';
import '../features/companies/presentation/pages/company_form_page.dart';
import '../shared/models/company_model.dart';
import '../shared/models/job_model.dart';

// iOS-style page transition
// Consistent page transition for all "pushed" screens
Page<dynamic> buildPageWithCustomTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;

      final Tween<double> fadeTween = Tween<double>(begin: 0.0, end: 1.0);
      final Animation<double> fadeAnimation = animation.drive(fadeTween.chain(CurveTween(curve: curve)));

      final Tween<double> scaleTween = Tween<double>(begin: 0.95, end: 1.0);
      final Animation<double> scaleAnimation = animation.drive(scaleTween.chain(CurveTween(curve: curve)));

      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final Listenable listenable = ref.watch(routerListenableProvider);

  return GoRouter(
    initialLocation: '/feed',
    refreshListenable: listenable,
    redirect: (context, state) {
      final AuthState authState = ref.read(authProvider);
      final bool isAuthenticated = authState.isAuthenticated;
      final bool isNewUser = authState.isNewUser;
      final bool isLoginRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      
      if (isAuthenticated) {
        if (isNewUser && state.matchedLocation != '/create-profile') {
          return '/create-profile';
        }
        
        if (!isNewUser && (isLoginRoute || state.matchedLocation == '/create-profile')) {
          return '/feed';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        pageBuilder: (context, state, child) {
          // Determine selected index based on current route
          int selectedIndex = 0;
          // Use matchedLocation for robustness
          final String path = state.matchedLocation;
          
          if (path.startsWith('/feed')) {
            selectedIndex = 0;
          } else if (path.startsWith('/profile')) {
            selectedIndex = 1;
          } else if (path.startsWith('/employees')) {
            selectedIndex = 2;
          } else if (path.startsWith('/chat')) {
            selectedIndex = 3;
          } else if (path.startsWith('/invitations')) {
            selectedIndex = 9;
          } else if (path.startsWith('/my-applications')) {
            selectedIndex = 10;
          } else if (path.startsWith('/companies')) {
            selectedIndex = 5;
          } else if (path.startsWith('/jobs/add')) {
            selectedIndex = 8;
          } else if (path.startsWith('/jobs/my-jobs')) {
            selectedIndex = 7;
          } else if (path.startsWith('/jobs/saved')) {
            selectedIndex = 6;
          } else if (path.startsWith('/jobs')) {
            selectedIndex = 4;
          }
          

          return buildPageWithCustomTransition(
            context: context,
            state: state,
            child: MainScreen(
              selectedIndex: selectedIndex,
              child: child,
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/feed',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const FeedScreen(),
            ),
          ),
          GoRoute(
            path: '/employees',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const EmployeesScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const ChatListScreen(),
            ),
          ),
          GoRoute(
            path: '/invitations',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const InvitationsScreen(),
            ),
          ),
          GoRoute(
            path: '/my-applications',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const MyApplicationsScreen(),
            ),
          ),
          GoRoute(
            path: '/jobs',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const JobsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'saved',
                pageBuilder: (context, state) => buildPageWithCustomTransition(
                  context: context,
                  state: state,
                  child: const SavedJobsScreen(),
                ),
              ),
              GoRoute(
                path: 'my-jobs',
                pageBuilder: (context, state) => buildPageWithCustomTransition(
                  context: context,
                  state: state,
                  child: const MyJobsScreen(),
                ),
              ),
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) {
                  int? companyId;
                  if (state.extra is int) {
                    companyId = state.extra as int;
                  } else if (state.extra is Map<String, dynamic>) {
                    companyId = (state.extra as Map<String, dynamic>)['companyId'] as int?;
                  }
                  
                  return buildPageWithCustomTransition(
                    context: context,
                    state: state,
                    child: JobFormScreen(initialCompanyId: companyId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/chat/:chatId',
            pageBuilder: (context, state) {
              final String chatId = state.pathParameters['chatId'] ?? '';
              return buildPageWithCustomTransition(
                context: context,
                state: state,
                child: ChatRoomScreen(chatId: chatId),
              );
            },
          ),
          GoRoute(
            path: '/profile/me',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const ProfileMeScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/edit',
            pageBuilder: (context, state) {
              final String? section = state.extra as String?;
              return buildPageWithCustomTransition(
                context: context,
                state: state,
                child: EditProfileScreen(initialSection: section),
              );
            },
          ),
          GoRoute(
            path: '/profile/:userId',
            pageBuilder: (context, state) {
              final String userId = state.pathParameters['userId'] ?? '';
              return buildPageWithCustomTransition(
                context: context,
                state: state,
                child: ProfileScreen(userId: userId),
              );
            },
          ),
          GoRoute(
            path: '/companies',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const MyCompaniesPage(),
            ),
          ),
          GoRoute(
            path: '/companies/add',
            pageBuilder: (context, state) => buildPageWithCustomTransition(
              context: context,
              state: state,
              child: const CompanyFormPage(),
            ),
          ),
          GoRoute(
            path: '/companies/edit/:id',
            pageBuilder: (context, state) {
              final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final CompanyModel? company = state.extra as CompanyModel?;
              return buildPageWithCustomTransition(
                context: context,
                state: state,
                child: CompanyFormPage(company: company),
              );
            },
          ),
          GoRoute(
            path: '/jobs/:id',
            pageBuilder: (context, state) {
              final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final JobModel? job = state.extra as JobModel?;
              
              return buildPageWithCustomTransition(
                context: context,
                state: state,
                child: JobDetailScreen(job: job, jobId: id),
              );
            },
          ),
          GoRoute(
            path: '/jobs/:id/applications',
            pageBuilder: (context, state) {
              final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              final String jobTitle = state.extra as String? ?? 'Vakansiyalar';
              
              return buildPageWithCustomTransition(
                context: context,
                state: state,
                child: JobApplicationsScreen(jobId: id, jobTitle: jobTitle),
              );
            },
          ),
        ],
      ),
    ],
  );
});

final routerListenableProvider = Provider<ChangeNotifier>((ref) {
  final RouterListenable notifier = RouterListenable();
  ref.listen(authProvider, (_, __) => notifier.notify());
  return notifier;
});

class RouterListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
