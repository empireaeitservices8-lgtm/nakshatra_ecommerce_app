class ReferralHistoryItem {
  final String friendName;
  final String status;
  final double rewardAmount;
  final String date;

  ReferralHistoryItem({
    required this.friendName,
    required this.status,
    required this.rewardAmount,
    required this.date,
  });

  factory ReferralHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryItem(
      friendName: json['friend_name'] ?? json['friendName'] ?? '',
      status: json['status'] ?? '',
      rewardAmount: (json['reward_amount'] ?? json['rewardAmount'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friend_name': friendName,
      'status': status,
      'reward_amount': rewardAmount,
      'date': date,
    };
  }
}

class ReferralInfo {
  final String referralCode;
  final int referredCount;
  final double rewardsEarnedInr;
  final List<ReferralHistoryItem> history;

  ReferralInfo({
    required this.referralCode,
    required this.referredCount,
    required this.rewardsEarnedInr,
    required this.history,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    final list = json['history'] as List?;
    final historyList = list != null
        ? list.map((item) => ReferralHistoryItem.fromJson(item)).toList()
        : <ReferralHistoryItem>[];
    return ReferralInfo(
      referralCode: json['referral_code'] ?? json['referralCode'] ?? '',
      referredCount: json['referred_count'] ?? json['referredCount'] ?? 0,
      rewardsEarnedInr: (json['rewards_earned_inr'] ?? json['rewardsEarnedInr'] ?? 0.0).toDouble(),
      history: historyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referral_code': referralCode,
      'referred_count': referredCount,
      'rewards_earned_inr': rewardsEarnedInr,
      'history': history.map((item) => item.toJson()).toList(),
    };
  }
}
