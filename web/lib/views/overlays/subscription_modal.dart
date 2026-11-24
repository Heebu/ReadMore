import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal dialog for upgrading to ReadMore Pro with plan selection and payment options.
class SubscriptionModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const SubscriptionModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<SubscriptionModal> {
  String _selectedPlan = 'annual'; // 'annual' | 'monthly'
  String _selectedPaymentMethod = 'google_pay'; // 'google_pay' | 'apple_pay' | 'card'

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

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
                color: FlartColor('rgba(0, 0, 0, 0.6)'),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: FDContainer(
              padding: const EdgeInsets.all(28),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Bar
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FDContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FDText(
                              '✦ PRO ACCESS ✦',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Space Grotesk',
                                color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          const FDSizedBox(width: 10),
                          FDText(
                            'Upgrade to ReadMore Pro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                          ),
                        ],
                      ),
                      FDGestureDetector(
                        onTap: () => vm.closeSubscriptionModal(),
                        child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 8),

                  const FDText(
                    'Experience journalism without interruptions. Enhanced intelligence tools, neural AI voices, and zero ads.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const FDSizedBox(height: 20),

                  // Plan Selection Cards
                  FDRow(
                    children: [
                      // Annual Plan (Selected by default)
                      Expanded(
                        child: FDGestureDetector(
                          onTap: () => setState(() => _selectedPlan = 'annual'),
                          child: FDContainer(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _selectedPlan == 'annual'
                                  ? const FlartColor('rgba(139, 92, 246, 0.12)')
                                  : (vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPlan == 'annual'
                                    ? AppColors.accentPurple
                                    : AppColors.borderRegular,
                                width: 2,
                              ),
                            ),
                            child: FDColumn(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FDRow(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const FDText(
                                      'Annual',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                    ),
                                    FDContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentAmber,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const FDText(
                                        'SAVE 18%',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: FlartColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const FDSizedBox(height: 6),
                                FDRow(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  children: const [
                                    FDText(
                                      '\$49',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                                    ),
                                    FDText(
                                      '/year',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const FDSizedBox(height: 4),
                                const FDText(
                                  'Only \$4.08/mo billed annually',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const FDSizedBox(width: 12),

                      // Monthly Plan
                      Expanded(
                        child: FDGestureDetector(
                          onTap: () => setState(() => _selectedPlan = 'monthly'),
                          child: FDContainer(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _selectedPlan == 'monthly'
                                  ? const FlartColor('rgba(139, 92, 246, 0.12)')
                                  : (vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPlan == 'monthly'
                                    ? AppColors.accentPurple
                                    : AppColors.borderRegular,
                                width: 2,
                              ),
                            ),
                            child: FDColumn(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FDText(
                                  'Monthly',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                                const FDSizedBox(height: 6),
                                FDRow(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  children: const [
                                    FDText(
                                      '\$4.99',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                                    ),
                                    FDText(
                                      '/mo',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const FDSizedBox(height: 4),
                                const FDText(
                                  'Billed monthly, cancel anytime',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 18),

                  // Features Checklist
                  _buildFeatureRow('100% Ad-Free Experience across all views and articles'),
                  _buildFeatureRow('Neural AI Audio Voice Briefings & narrated stories'),
                  _buildFeatureRow('Deep Institutional Financial Screener & tick data'),
                  _buildFeatureRow('Unlimited Story Cluster perspectives & full coverage'),
                  _buildFeatureRow('Self-serve campaign analytics & priority support'),
                  const FDSizedBox(height: 18),

                  // Payment Method Selector
                  const FDText(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const FDSizedBox(height: 8),
                  FDRow(
                    children: [
                      _buildPaymentPill('google_pay', 'Google Pay', '🔵'),
                      const FDSizedBox(width: 8),
                      _buildPaymentPill('apple_pay', 'Apple Pay', ''),
                      const FDSizedBox(width: 8),
                      _buildPaymentPill('card', 'Credit Card', '💳'),
                    ],
                  ),
                  const FDSizedBox(height: 22),

                  // Upgrade Action Button
                  FDGestureDetector(
                    onTap: () {
                      vm.upgradeToPro(
                        plan: _selectedPlan,
                        paymentMethod: _selectedPaymentMethod,
                      );
                    },
                    child: FDContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                          'AUTHORIZE PRO SUBSCRIPTION',
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
                  const FDSizedBox(height: 10),
                  const FDCenter(
                    child: FDText(
                      '🔒 Encrypted 256-bit payment. Instant activation. Cancel anytime.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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

  Widget _buildFeatureRow(String text) {
    return FDPadding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FDRow(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FDText('✓', style: TextStyle(fontSize: 14, color: AppColors.accentEmerald, fontWeight: FontWeight.bold)),
          const FDSizedBox(width: 8),
          Expanded(
            child: FDText(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPill(String id, String label, String icon) {
    final isSelected = _selectedPaymentMethod == id;

    return Expanded(
      child: FDGestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = id),
        child: FDContainer(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlueSubtle
                : (widget.vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
              width: 1.5,
            ),
          ),
          child: FDCenter(
            child: FDRow(
              mainAxisSize: MainAxisSize.min,
              children: [
                FDText(icon, style: const TextStyle(fontSize: 12)),
                const FDSizedBox(width: 4),
                FDText(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primaryBlueLight : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
