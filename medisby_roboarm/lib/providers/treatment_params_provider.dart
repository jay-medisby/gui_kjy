import 'package:flutter/material.dart';
import '../models/body_part.dart';

class TreatmentParamsProvider extends ChangeNotifier {
  int _speed = 5;
  int _minutes = 30;
  BodyPartSelection _bodyPart = BodyPartSelection.rightUpper;

  int get speed => _speed;
  int get minutes => _minutes;
  BodyPartSelection get bodyPart => _bodyPart;
  bool get isUpper => _bodyPart.isUpper;
  String get limbLabel => _bodyPart.limbLabel;

  void setSpeed(int value) {
    _speed = value;
    notifyListeners();
  }

  void setMinutes(int value) {
    _minutes = value;
    notifyListeners();
  }

  void setBodyPart(BodyPartSelection value) {
    _bodyPart = value;
    notifyListeners();
  }
}
