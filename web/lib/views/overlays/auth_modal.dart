import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/web_dom_helper.dart';
import '../../core/widgets/app_text_field.dart';
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
  String _email = '';
  String _password = '';
  String _displayName = '';
  String _resetCode = '';
  String _newPassword = '';
  bool _resetCodeSent = false;
  Object? _keySub;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.vm.authModalTab;
    _keySub = addWindowKeyDownListener((key, _) {
      if (key == 'Escape') {
        widget.vm.closeAuthModal();
      }
    });
  }

  @override
  void didUpdateWidget(AuthModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vm.authModalTab != oldWidget.vm.authModalTab) {
      _activeTab = widget.vm.authModalTab;
    }
  }

  @override
  void dispose() {
    removeWindowKeyDownListener(_keySub);
    _keySub = null;
    super.dispose();
  }

  void _switchTab(String tab) {
    widget.vm.clearAuthFeedback(notify: false);
    setState(() {
      _activeTab = tab;
      if (tab != 'forgot') {
        _resetCodeSent = false;
      }
    });
  }

  void _fillDemoCredentials() {
    widget.vm.clearAuthFeedback(notify: false);
    setState(() {
      _email = 'demo@readmore.com';
      _password = 'Password123!';
    });
  }

  void _submitPrimary() {
    final vm = widget.vm;
    if (vm.isAuthLoading) return;
    if (_activeTab == 'signin') {
      vm.signInWithEmail(_email, _password);
    } else if (_activeTab == 'signup') {
      vm.signUp(_displayName, _email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final isSignIn = _activeTab == 'signin';
    final isSignUp = _activeTab == 'signup';
    final isForgot = _activeTab == 'forgot';

    return FDContainer(
      onClick: () => vm.closeAuthModal(),
      decoration: const BoxDecoration(
        color: FlartColor('rgba(0, 0, 0, 0.85)'),
      ),
      cssStyle: const {
        'position': 'fixed',
        'top': '0',
        'left': '0',
        'right': '0',
        'bottom': '0',
        'z-index': '1000',
        'overflow-y': 'auto',
      },
      child: FDCenter(
        cssStyle: const {
          'height': 'auto',
          'min-height': '100%',
          'align-items': 'safe center',
        },
        child: FDElement(
          tag: 'div',
          id: 'auth-modal-dialog',
          attributes: {
            'role': 'dialog',
            'aria-modal': 'true',
            'aria-label': isForgot
                ? 'Recover Subscriber Access'
                : isSignIn
                    ? 'Sign In to ReadMore'
                    : 'Subscriber Registration',
          },
          styles: {
            'box-sizing': 'border-box',
            'width': widget.isMobile ? 'calc(100% - 16px)' : 'min(460px, calc(100% - 40px))',
            'max-width': 'calc(100vw - 16px)',
            'min-width': '0',
            'margin': widget.isMobile ? '8px auto' : '20px auto',
            'cursor': 'default',
          },
          events: {
            'click': (dynamic e) => stopEventPropagation(e),
          },
          children: [
            FDContainer(
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
              cssStyle: const {
                'width': '100%',
                'max-width': '100%',
                'min-width': '0',
                'box-sizing': 'border-box',
              },
              child: FDConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0'},
                child: FDSingleChildScrollView(
                  cssStyle: {
                    'max-height': widget.isMobile ? 'calc(100vh - 20px)' : 'calc(100vh - 48px)',
                  },
                  child: FDContainer(
                    padding: EdgeInsets.all(widget.isMobile ? 16 : 28),
                    cssStyle: const {
                      'width': '100%',
                      'max-width': '100%',
                      'min-width': '0',
                      'box-sizing': 'border-box',
                      'overflow-wrap': 'break-word',
                    },
                    child: FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      cssStyle: const {'width': '100%', 'min-width': '0', 'max-width': '100%'},
                      children: [
                        // Header Bar with Close Button
                        FDRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FDRow(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FDContainer(
                                    width: 32,
                                    height: 32,
                                    cssStyle: const {'flex-shrink': '0'},
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
                                  Expanded(
                                    child: FDText(
                                      isForgot
                                          ? 'Recover Subscriber Access'
                                          : isSignIn
                                              ? 'Sign In to ReadMore'
                                              : 'Subscriber Registration',
                                      style: TextStyle(
                                        fontSize: widget.isMobile ? 16 : 18,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Playfair Display',
                                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const FDSizedBox(width: 8),
                            FDGestureDetector(
                              key: const ValueKey('auth-close-btn'),
                              onTap: () => vm.closeAuthModal(),
                              child: FDContainer(
                                padding: const EdgeInsets.all(4),
                                child: const FDIcon(
                                  icon: FDIcons.close,
                                  size: 20,
                                  color: FlartColors.grey,
                                  semanticLabel: 'Close authentication modal',
                                ),
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
                            key: const ValueKey('auth-google-btn'),
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
                                  key: const ValueKey('auth-tab-signin'),
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
                                  key: const ValueKey('auth-tab-signup'),
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
                            AppTextField(
                              key: const ValueKey('auth-name-input'),
                              value: _displayName,
                              placeholder: 'Your full name',
                              ariaLabel: 'Full Name',
                              backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                              borderColor: AppColors.borderRegular,
                              borderRadius: 10,
                              onChanged: (val) => _displayName = val,
                              onSubmitted: (_) => _submitPrimary(),
                            ),
                            const FDSizedBox(height: 12),
                          ],

                          // Email Field
                          FDWrap(
                            alignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            cssStyle: const {'width': '100%', 'max-width': '100%'},
                            children: [
                              const FDText(
                                'Email Address',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                              if (isSignIn)
                                FDGestureDetector(
                                  key: const ValueKey('auth-fill-demo-btn'),
                                  onTap: _fillDemoCredentials,
                                  child: const FDText(
                                    'Use Demo Reader',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlueLight,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const FDSizedBox(height: 6),
                          AppTextField(
                            key: const ValueKey('auth-email-input'),
                            value: _email,
                            placeholder: isSignUp ? 'you@example.com' : 'name@example.com',
                            ariaLabel: 'Email Address',
                            keyboardType: TextInputType.email,
                            backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                            borderColor: AppColors.borderRegular,
                            borderRadius: 10,
                            onChanged: (val) => _email = val,
                            onSubmitted: (_) => _submitPrimary(),
                          ),
                          const FDSizedBox(height: 12),

                          // Password Field
                          FDWrap(
                            alignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            cssStyle: const {'width': '100%', 'max-width': '100%'},
                            children: [
                              const FDText(
                                'Password',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                              if (isSignIn)
                                FDGestureDetector(
                                  key: const ValueKey('auth-forgot-link'),
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
                          AppTextField(
                            key: const ValueKey('auth-password-input'),
                            value: _password,
                            placeholder: isSignUp ? 'At least 6 characters' : '••••••••',
                            ariaLabel: 'Password',
                            obscureText: true,
                            backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                            borderColor: AppColors.borderRegular,
                            borderRadius: 10,
                            onChanged: (val) => _password = val,
                            onSubmitted: (_) => _submitPrimary(),
                          ),
                          const FDSizedBox(height: 20),

                          // Primary Submit Button
                          FDGestureDetector(
                            key: const ValueKey('auth-submit-btn'),
                            onTap: _submitPrimary,
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
                          AppTextField(
                            key: const ValueKey('auth-forgot-email-input'),
                            value: _email,
                            placeholder: 'you@example.com',
                            ariaLabel: 'Account Email',
                            keyboardType: TextInputType.email,
                            backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                            borderColor: AppColors.borderRegular,
                            borderRadius: 10,
                            onChanged: (val) => _email = val,
                          ),
                          const FDSizedBox(height: 12),

                          if (!_resetCodeSent) ...[
                            FDGestureDetector(
                              key: const ValueKey('auth-send-reset-btn'),
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
                            AppTextField(
                              key: const ValueKey('auth-reset-code-input'),
                              value: _resetCode,
                              placeholder: 'Enter 6-digit code',
                              ariaLabel: '6-Digit Reset Code',
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
                            AppTextField(
                              key: const ValueKey('auth-new-password-input'),
                              value: _newPassword,
                              placeholder: 'New passphrase',
                              ariaLabel: 'New Password',
                              obscureText: true,
                              backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                              borderColor: AppColors.borderRegular,
                              borderRadius: 10,
                              onChanged: (val) => _newPassword = val,
                            ),
                            const FDSizedBox(height: 16),
                            FDGestureDetector(
                              key: const ValueKey('auth-confirm-reset-btn'),
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
                            key: const ValueKey('auth-back-to-signin'),
                            onTap: () => _switchTab('signin'),
                            child: FDContainer(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              cssStyle: const {'cursor': 'pointer'},
                              child: const FDCenter(
                                child: FDText(
                                  '← Back to Sign In',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}
