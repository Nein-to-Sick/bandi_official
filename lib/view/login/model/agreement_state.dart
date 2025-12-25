class AgreementState {
  final bool option1;
  final bool option2;
  final bool option3;
  final bool option4;

  const AgreementState({
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
  });

  bool get allSelected => option1 && option2 && option3 && option4;

  AgreementState copyWith({
    bool? option1,
    bool? option2,
    bool? option3,
    bool? option4,
  }) {
    return AgreementState(
      option1: option1 ?? this.option1,
      option2: option2 ?? this.option2,
      option3: option3 ?? this.option3,
      option4: option4 ?? this.option4,
    );
  }

  static const AgreementState initial = AgreementState(
    option1: false,
    option2: false,
    option3: false,
    option4: false,
  );
}
