import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal dialog for user authentication: Google 1-Tap OAuth & Email/Password Sign-In/Up.
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
  late String _activeTab;
  String _email = 'alex.rivera@readmore.org';
  String _password = '••••••••••••';
  String _displayName = 'Alex Rivera';

  @override
  void initState() {
    super.initState();
    _activeTab = widget.vm.authModalTab;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final isSignIn = _activeTab == 'signin';

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
                            isSignIn ? 'Sign In to ReadMore' : 'Subscriber Registration',
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
                    isSignIn
                        ? 'Access your synced reading streak, saved stories, and personalized topic intelligence.'
                        : 'Create your free account to personalize your feed, bookmark stories, and tune recommendations.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const FDSizedBox(height: 20),

                  // Google 1-Tap OAuth Button
                  FDGestureDetector(
                    onTap: () => vm.signInWithGoogle(),
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
                          // Google 'G' Styled Mark
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
                          onTap: () => setState(() => _activeTab = 'signin'),
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
                                      ? AppColors.primaryBlueLight
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FDGestureDetector(
                          onTap: () => setState(() => _activeTab = 'signup'),
                          child: FDContainer(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: !isSignIn ? AppColors.primaryBlue : FlartColors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: FDCenter(
                              child: FDText(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: !isSignIn ? FontWeight.w800 : FontWeight.w600,
                                  color: !isSignIn
                                      ? AppColors.primaryBlueLight
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
                  if (!isSignIn) ...[
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
                    placeholder: 'name@example.com',
                    backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                    borderColor: AppColors.borderRegular,
                    borderRadius: 10,
                    onChanged: (val) => _email = val,
                  ),
                  const FDSizedBox(height: 12),

                  // Password Field
                  const FDText(
                    'Password',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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

                  // Primary Submit Button in Broadsheet Monochrome
                  FDGestureDetector(
                    onTap: () {
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
                          isSignIn ? 'SIGN IN' : 'CREATE SUBSCRIBER ACCOUNT',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
