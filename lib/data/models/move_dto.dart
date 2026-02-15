class MoveDto {
  final int from;
  final int to;
  final String type;

  MoveDto({
    required this.from,
    required this.to,
    required this.type,
  });

  factory MoveDto.fromJson(Map<String, dynamic> json) {
    return MoveDto(
      from: json['from'] as int,
      to: json['to'] as int,
      type: json['type'] as String,
    );
  }

  @override
  String toString() => 'MoveDto(from: $from, to: $to, type: $type)';
}
