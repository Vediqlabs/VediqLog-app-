import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/emergency_qr_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/phone_otp_screen.dart';
import 'screens/membership_screen.dart';
import 'screens/account_security_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/policy_page.dart';
import 'screens/support_center_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/contact_support_screen.dart';
import 'screens/clear_cache_screen.dart';
import 'screens/notifications_screen.dart';
import 'package:vediqlog/features/doctor/start_consultation_screen.dart';
import 'package:vediqlog/features/doctor/ask_doctor_screen.dart';

final supabase = Supabase.instance.client;

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(phone: state.extra as String?),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String;
        return PhoneOtpScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/phone-login',
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: '/account-security',
      builder: (context, state) => AccountSecurityScreen(),
    ),
    GoRoute(
      path: '/phone-login',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text("Phone login coming next")),
      ),
    ),
    GoRoute(
      path: '/legal',
      builder: (context, state) => const LegalScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PolicyPage(
        title: "Privacy Policy",
        content: "Your privacy policy text here...",
      ),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const PolicyPage(
        title: "Terms & Conditions",
        content: "Your terms text here...",
      ),
    ),
    GoRoute(
      path: '/data-policy',
      builder: (context, state) => const PolicyPage(
        title: "Data Usage Policy",
        content: "Your data usage text here...",
      ),
    ),
    GoRoute(
      path: '/support-center',
      builder: (context, state) => const SupportCenterScreen(),
    ),
    GoRoute(
      path: '/faqs',
      builder: (context, state) => const FaqScreen(),
    ),
    GoRoute(
      path: '/contact-support',
      builder: (context, state) => const ContactSupportScreen(),
    ),
    GoRoute(
      path: '/alarm',
      builder: (context, state) {
        final data = state.extra as Map;

        return AlarmScreen(
          alarmId: data['id'],
          title: data['title'],
          body: data['body'],
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/ask-doctor',
      builder: (context, state) => const AskDoctorScreen(),
    ),
    GoRoute(
      path: '/clear-cache',
      builder: (context, state) => const ClearCacheScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyQRScreen(),
    ),
    GoRoute(path: '/vault', builder: (context, state) => const VaultScreen()),
    GoRoute(
      path: '/membership',
      builder: (context, state) => const MembershipSheet(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final location = state.matchedLocation;

    // Allow splash always
    if (location == '/') return null;

    // User not logged in
    if (session == null) {
      if (location == '/login' ||
          location == '/signup' ||
          location == '/forgot-password' ||
          location == '/phone-login' ||
          location == '/otp' ||
          location == '/ask-doctor') {
        return null;
      }
      return '/login';
    }

    // Logged in user shouldn't see auth screens
    if (location == '/login') {
      return '/home';
    }
    return null;
  },
);
