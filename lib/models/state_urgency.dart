// lib/models/state_urgency.dart
class StateUrgency {
  final String state;
  final double needMetricScore;
  final String urgency;

  StateUrgency({
    required this.state,
    required this.needMetricScore,
    required this.urgency,
  });

  factory StateUrgency.fromJson(Map<String, dynamic> json) {
    return StateUrgency(
      state: json['state'],
      needMetricScore: json['need_metric_score'],
      urgency: json['urgency'],
    );
  }
}