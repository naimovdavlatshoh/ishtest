
class AppLocalizations {
  static const Map<String, String> en = {
    'app_name': 'LinkedIn Clone',
    'welcome': 'Welcome',
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'name': 'Name',
    'forgot_password': 'Forgot Password?',
    'dont_have_account': "Don't have an account?",
    'already_have_account': 'Already have an account?',
    'sign_up': 'Sign Up',
    'sign_in': 'Sign In',
    'logout': 'Logout',
    'feed': 'Feed',
    'profile': 'Profile',
    'chat': 'Chat',
    'jobs': 'Jobs',
    'post': 'Post',
    'like': 'Like',
    'comment': 'Comment',
    'share': 'Share',
    'connections': 'Connections',
    'followers': 'Followers',
    'skills': 'Skills',
    'experience': 'Experience',
    'send': 'Send',
    'type_message': 'Type a message...',
    'search': 'Search',
    'apply': 'Apply',
    'save': 'Save',
    'saved': 'Saved',
  };

  static String translate(String key) {
    return en[key] ?? key;
  }
}
