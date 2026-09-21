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
    this.history = const [],
  });

  int get friendsInvited => referredCount;
  double get goldEarned => rewardsEarnedInr;

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    final list = json['history'] as List?;
    final historyList = list != null
        ? list.map((item) => ReferralHistoryItem.fromJson(item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item))).toList()
        : <ReferralHistoryItem>[];

    final rawCode = json['referral_code'] ?? json['referralCode'] ?? '';

    int friendsCount = 0;
    final rawFriends = json['friends_invited'] ?? json['referred_count'] ?? json['referredCount'] ?? 0;
    if (rawFriends is num) {
      friendsCount = rawFriends.toInt();
    } else {
      friendsCount = int.tryParse(rawFriends.toString()) ?? 0;
    }

    double goldEarned = 0.0;
    final rawGold = json['gold_earned'] ?? json['rewards_earned_inr'] ?? json['rewardsEarnedInr'] ?? 0.0;
    if (rawGold is num) {
      goldEarned = rawGold.toDouble();
    } else {
      goldEarned = double.tryParse(rawGold.toString()) ?? 0.0;
    }

    return ReferralInfo(
      referralCode: rawCode.toString(),
      referredCount: friendsCount,
      rewardsEarnedInr: goldEarned,
      history: historyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referral_code': referralCode,
      'friends_invited': referredCount,
      'gold_earned': rewardsEarnedInr,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}
