import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal dialog for user authentication: Google 1-Tap OAuth, Email/Password Sign-In/Up,
/// real backend error feedback, and 6-digit Password Reset flow.
class AuthModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const AuthModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  late String _activeTab; // 'signin', 'signup', 'forgot'
  String _email = 'demo@readmore.com';
  String _password = 'Password123!';
  String _displayName = 'News Reader';
  String _resetCode = '';
  String _newPassword = '';
  bool _resetCodeSent = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.vm.authModalTab;
  }

  void _switchTab(String tab) {
    widget.vm.clearAuthFeedback();
    setState(() {
      _activeTab = tab;
      if (tab != 'forgot') {
        _resetCodeSent = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final isSignIn = _activeTab == 'signin';
    final isSignUp = _activeTab == 'signup';
    final isForgot = _activeTab == 'forgot';

    return FDContainer(
      decoration: const BoxDecoration(
        color: FlartColor('rgba(0, 0, 0, 0.85)'),
      ),
      child: FDCenter(
        child: FDContainer(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? const FlartColor('#111217') : const FlartColor('#F7F5F0'),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: FlartColor('rgba(0, 0, 0, 0.5)'),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: FDSingleChildScrollView(
              child: FDContainer(
                padding: const EdgeInsets.all(28),
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar with Close Button
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDContainer(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                shape: BoxShape.circle,
                              ),
                              child: FDCenter(
                                child: FDText(
                                  'R',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Cinzel',
                                    color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                  ),
                                ),
                              ),
                            ),
                            const FDSizedBox(width: 10),
                            FDText(
                              isForgot
                                  ? 'Recover Subscriber Access'
                                  : isSignIn
                                      ? 'Sign In to ReadMore'
                                      : 'Subscriber Registration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Playfair Display',
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              ),
                            ),
                          ],
                        ),
                        FDGestureDetector(
                          onTap: () => vm.closeAuthModal(),
                          child: FDContainer(
                            padding: const EdgeInsets.all(4),
                            child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
                          ),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 8),

                    FDText(
                      isForgot
                          ? 'Request a 6-digit security verification code to reset your subscriber passphrase.'
                          : isSignIn
                              ? 'Access your synced reading streak, saved stories, and personalized topic intelligence.'
                              : 'Create your free account to personalize your feed, bookmark stories, and tune recommendations.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const FDSizedBox(height: 16),

                    // Error / Success Feedback Banners
                    if (vm.authError != null) ...[
                      FDContainer(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(239, 68, 68, 0.14)'),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const FlartColor('rgba(239, 68, 68, 0.45)')),
                        ),
                        child: FDText(
                          '⚠ ${vm.authError}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: FlartColor('#EF4444'),
                          ),
                        ),
                      ),
                      const FDSizedBox(height: 14),
                    ],
                    if (vm.authSuccessMessage != null) ...[
                      FDContainer(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(16, 185, 129, 0.14)'),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const FlartColor('rgba(16, 185, 129, 0.45)')),
                        ),
                        child: FDColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FDText(
                              '✓ ${vm.authSuccessMessage}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: FlartColor('#10B981'),
                              ),
                            ),
                            if (vm.devResetCodeHint != null) ...[
                              const FDSizedBox(height: 4),
                              FDText(
                                'Dev Verification Code: ${vm.devResetCodeHint}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Space Grotesk',
                                  color: FlartColor('#10B981'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const FDSizedBox(height: 14),
                    ],

                    if (!isForgot) ...[
                      // Google 1-Tap OAuth Button
                      FDGestureDetector(
                        onTap: () => vm.isAuthLoading ? null : vm.signInWithGoogle(),
                        child: FDContainer(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: vm.isDarkMode ? const FlartColor('#1E293B') : FlartColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#CBD5E1'),
                              width: 1,
                            ),
                          ),
                          cssStyle: const {
                            'cursor': 'pointer',
                            'transition': 'all 0.2s ease',
                          },
                          child: FDRow(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FDContainer(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const FlartColor('#4285F4'),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const FDCenter(
                                  child: FDText(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: FlartColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const FDSizedBox(width: 10),
                              FDText(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: vm.isDarkMode ? FlartColors.white : const FlartColor('#1E293B'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const FDSizedBox(height: 16),

                      // Divider
                      FDRow(
                        children: [
                          const Expanded(child: FDDivider(color: AppColors.borderSubtle)),
                          FDPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: FDText(
                              'or continue with email',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Expanded(child: FDDivider(color: AppColors.borderSubtle)),
                        ],
                      ),
                      const FDSizedBox(height: 16),

                      // Tabs: Sign In / Create Account
                      FDRow(
                        children: [
                          Expanded(
                            child: FDGestureDetector(
                              onTap: () => _switchTab('signin'),
                              child: FDContainer(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isSignIn ? AppColors.primaryBlue : FlartColors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: FDCenter(
                                  child: FDText(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSignIn ? FontWeight.w800 : FontWeight.w600,
                                      color: isSignIn
                                          ? (vm.isDarkMode ? FlartColors.white : FlartColors.black)
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FDGestureDetector(
                              onTap: () => _switchTab('signup'),
                              child: FDContainer(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isSignUp ? AppColors.primaryBlue : FlartColors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: FDCenter(
                                  child: FDText(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSignUp ? FontWeight.w800 : FontWeight.w600,
                                      color: isSignUp
                                          ? (vm.isDarkMode ? FlartColors.white : FlartColors.black)
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const FDSizedBox(height: 16),

                      // Name Field (Only on Sign Up)
                      if (isSignUp) ...[
                        const FDText(
                          'Full Name',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const FDSizedBox(height: 6),
                        FDTextField(
                          placeholder: 'Your name',
                          backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                          borderColor: AppColors.borderRegular,
                          borderRadius: 10,
                          onChanged: (val) => _displayName = val,
                        ),
                        const FDSizedBox(height: 12),
                      ],

                      // Email Field
                      const FDText(
                        'Email Address',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const FDSizedBox(height: 6),
                      FDTextField(
                        placeholder: 'demo@readmore.com',
                        backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                        borderColor: AppColors.borderRegular,
                        borderRadius: 10,
                        onChanged: (val) => _email = val,
                      ),
                      const FDSizedBox(height: 12),

                      // Password Field
                      FDRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FDText(
                            'Password',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          if (isSignIn)
                            FDGestureDetector(
                              onTap: () => _switchTab('forgot'),
                              child: const FDText(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const FDSizedBox(height: 6),
                      FDTextField(
                        placeholder: '••••••••',
                        backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                        borderColor: AppColors.borderRegular,
                        borderRadius: 10,
                        onChanged: (val) => _password = val,
                      ),
                      const FDSizedBox(height: 20),

                      // Primary Submit Button
                      FDGestureDetector(
                        onTap: () {
                          if (vm.isAuthLoading) return;
                          if (isSignIn) {
                            vm.signInWithEmail(_email, _password);
                          } else {
                            vm.signUp(_displayName, _email, _password);
                          }
                        },
                        child: FDContainer(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          cssStyle: const {
                            'cursor': 'pointer',
                            'transition': 'all 0.2s ease',
                          },
                          child: FDCenter(
                            child: FDText(
                              vm.isAuthLoading
                                  ? 'VERIFYING CREDENTIALS...'
                                  : isSignIn
                                      ? 'SIGN IN'
                                      : 'CREATE SUBSCRIBER ACCOUNT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 0.08,
                                color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Password Reset Flow
                      const FDText(
                        'Account Email',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const FDSizedBox(height: 6),
                      FDTextField(
                        placeholder: 'demo@readmore.com',
                        backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                        borderColor: AppColors.borderRegular,
                        borderRadius: 10,
                        onChanged: (val) => _email = val,
                      ),
                      const FDSizedBox(height: 12),

                      if (!_resetCodeSent) ...[
                        FDGestureDetector(
                          onTap: () async {
                            if (vm.isAuthLoading) return;
                            final sent = await vm.requestPasswordReset(_email);
                            if (sent && mounted) {
                              setState(() {
                                _resetCodeSent = true;
                                if (vm.devResetCodeHint != null) {
                                  _resetCode = vm.devResetCodeHint!;
                                }
                              });
                            }
                          },
                          child: FDContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FDCenter(
                              child: FDText(
                                vm.isAuthLoading ? 'ISSUING CODE...' : 'SEND RESET CODE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Space Grotesk',
                                  letterSpacing: 0.08,
                                  color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const FDText(
                          '6-Digit Reset Code',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const FDSizedBox(height: 6),
                        FDTextField(
                          placeholder: 'Enter 6-digit code',
                          backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                          borderColor: AppColors.borderRegular,
                          borderRadius: 10,
                          onChanged: (val) => _resetCode = val,
                        ),
                        const FDSizedBox(height: 12),
                        const FDText(
                          'New Password (6+ chars)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const FDSizedBox(height: 6),
                        FDTextField(
                          placeholder: 'New passphrase',
                          backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                          borderColor: AppColors.borderRegular,
                          borderRadius: 10,
                          onChanged: (val) => _newPassword = val,
                        ),
                        const FDSizedBox(height: 16),
                        FDGestureDetector(
                          onTap: () async {
                            if (vm.isAuthLoading) return;
                            final ok = await vm.confirmPasswordReset(_resetCode, _newPassword);
                            if (ok && mounted) {
                              setState(() {
                                _activeTab = 'signin';
                                _resetCodeSent = false;
                                _password = _newPassword;
                              });
                            }
                          },
                          child: FDContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FDCenter(
                              child: FDText(
                                vm.isAuthLoading ? 'UPDATING...' : 'RESET PASSPHRASE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Space Grotesk',
                                  letterSpacing: 0.08,
                                  color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const FDSizedBox(height: 12),
                      FDGestureDetector(
                        onTap: () => _switchTab('signin'),
                        child: const FDCenter(
                          child: FDText(
                            '← Back to Sign In',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
