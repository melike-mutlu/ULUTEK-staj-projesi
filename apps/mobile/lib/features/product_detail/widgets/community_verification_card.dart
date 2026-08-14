import 'package:flutter/material.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Renders the community verification badge + interactive vote (onay/reddet) buttons
/// when a product is pending/unverified.
/// Prepared to connect to Ranim's backend voting endpoint when available.
class CommunityVerificationCard extends StatelessWidget {
  const CommunityVerificationCard({
    super.key,
    required this.upvotes,
    required this.downvotes,
    required this.userVote,
    required this.onVoteApprove,
    required this.onVoteReject,
  });

  final int upvotes;
  final int downvotes;
  final String? userVote; // 'up', 'down', or null
  final VoidCallback onVoteApprove;
  final VoidCallback onVoteReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isUpvoted = userVote == 'up';
    final isDownvoted = userVote == 'down';
    final totalVotes = upvotes + downvotes;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFFD97706).withOpacity(0.5) : const Color(0xFFFCD34D),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.how_to_vote_rounded, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    const Text(
                      'Topluluk Oylaması',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '($totalVotes Oy)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.amber.shade200 : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bu ürün topluluk tarafından eklendi. Doğruluğunu onaylayın veya reddedin:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF78350F),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Vote Action Buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    onVoteApprove();
                    _showFeedbackToast(
                      context,
                      isUpvoted ? 'Oyunuz geri alındı.' : 'Ürün doğrulamasını onayladınız! (Mock)',
                      isUpvoted ? Colors.grey : const Color(0xFF10B981),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isUpvoted
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white10 : const Color(0xFFECFDF5)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUpvoted ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 16,
                          color: isUpvoted ? Colors.white : const Color(0xFF059669),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Onayla',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isUpvoted ? Colors.white : const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUpvoted
                                ? Colors.white24
                                : const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$upvotes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUpvoted ? Colors.white : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    onVoteReject();
                    _showFeedbackToast(
                      context,
                      isDownvoted ? 'Oyunuz geri alındı.' : 'Ürün doğrulamasını reddettiniz! (Mock)',
                      isDownvoted ? Colors.grey : const Color(0xFFEF4444),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDownvoted
                          ? const Color(0xFFEF4444)
                          : (isDark ? Colors.white10 : const Color(0xFFFEF2F2)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDownvoted ? const Color(0xFFDC2626) : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_down_alt_rounded,
                          size: 16,
                          color: isDownvoted ? Colors.white : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Reddet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDownvoted ? Colors.white : const Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDownvoted
                                ? Colors.white24
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$downvotes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDownvoted ? Colors.white : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeedbackToast(BuildContext context, String message, Color bg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
