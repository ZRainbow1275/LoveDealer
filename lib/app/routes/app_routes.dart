part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const HOME = _Paths.HOME;
  static const HISTORY = _Paths.HISTORY;
  static const PROFILE = _Paths.PROFILE;
  static const DETAIL = _Paths.DETAIL;
  static const EVIDENCE = _Paths.EVIDENCE;
  static const APP_INFO = _Paths.APP_INFO;
  static const AGREEMENT = _Paths.AGREEMENT;
  static const PAIRING = _Paths.PAIRING;
  static const RECORD = _Paths.RECORD;
  static const FACE_RECOGNITION = _Paths.FACE_RECOGNITION;
  static const PHOTO_CAPTURE = _Paths.PHOTO_CAPTURE;
  static const COMPLETION = _Paths.COMPLETION;
}

abstract class _Paths {
  _Paths._();
  
  static const HOME = '/home';
  static const HISTORY = '/history';
  static const PROFILE = '/profile';
  static const DETAIL = '/detail';
  static const EVIDENCE = '/evidence';
  static const APP_INFO = '/app-info';
  static const AGREEMENT = '/agreement';
  static const PAIRING = '/pairing';
  static const RECORD = '/record';
  static const FACE_RECOGNITION = '/face-recognition';
  static const PHOTO_CAPTURE = '/photo-capture';
  static const COMPLETION = '/completion';
} 