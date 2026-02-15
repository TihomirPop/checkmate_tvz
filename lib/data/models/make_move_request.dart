class MakeMoveRequest {
  final int from;
  final int to;
  final int thinkingTime;

  const MakeMoveRequest({
    required this.from,
    required this.to,
    required this.thinkingTime,
  });

  Map<String, dynamic> toJson() {
    return {'from': from, 'to': to, 'thinkingTime': thinkingTime};
  }
}
