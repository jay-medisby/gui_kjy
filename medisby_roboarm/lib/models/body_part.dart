enum BodyPart { upper, lower }

/// 치료 부위 선택 (4종) — Pre-treatment Step 2에서 사용
enum BodyPartSelection {
  rightUpper, // 우측 상지
  leftUpper,  // 좌측 상지
  rightLower, // 우측 하지
  leftLower,  // 좌측 하지
}

extension BodyPartSelectionX on BodyPartSelection {
  bool get isUpper =>
      this == BodyPartSelection.rightUpper ||
      this == BodyPartSelection.leftUpper;

  bool get isLeft =>
      this == BodyPartSelection.leftUpper ||
      this == BodyPartSelection.leftLower;

  String get label => switch (this) {
        BodyPartSelection.rightUpper => '우측 상지',
        BodyPartSelection.leftUpper => '좌측 상지',
        BodyPartSelection.rightLower => '우측 하지',
        BodyPartSelection.leftLower => '좌측 하지',
      };

  String get sideLabel => isLeft ? '좌측' : '우측';

  String get limbLabel => isUpper ? '상지' : '하지';

  BodyPart get bodyPart => isUpper ? BodyPart.upper : BodyPart.lower;
}
