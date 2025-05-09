import 'package:get/get.dart';

import '../modules/agreement/bindings/agreement_binding.dart';
import '../modules/agreement/views/agreement_view.dart';
import '../modules/app_info/bindings/app_info_binding.dart';
import '../modules/app_info/views/app_info_view.dart';
import '../modules/detail/bindings/detail_binding.dart';
import '../modules/detail/views/detail_view.dart';
import '../modules/evidence/bindings/evidence_binding.dart';
import '../modules/evidence/views/evidence_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/pairing/bindings/pairing_binding.dart';
import '../modules/pairing/views/pairing_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/record/bindings/record_binding.dart';
import '../modules/record/views/record_view.dart';
import '../modules/record/face_recognition/bindings/face_recognition_binding.dart';
import '../modules/record/face_recognition/views/face_recognition_view.dart';
import '../modules/record/photo_capture/bindings/photo_capture_binding.dart';
import '../modules/record/photo_capture/views/photo_capture_view.dart';
import '../modules/record/completion/bindings/completion_binding.dart';
import '../modules/record/completion/views/completion_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AGREEMENT,
      page: () => const AgreementView(),
      binding: AgreementBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.APP_INFO,
      page: () => const AppInfoView(),
      binding: AppInfoBinding(),
    ),
    GetPage(
      name: _Paths.PAIRING,
      page: () => const PairingView(),
      binding: PairingBinding(),
    ),
    GetPage(
      name: _Paths.RECORD,
      page: () => const RecordView(),
      binding: RecordBinding(),
    ),
    GetPage(
      name: _Paths.FACE_RECOGNITION,
      page: () => const FaceRecognitionView(),
      binding: FaceRecognitionBinding(),
    ),
    GetPage(
      name: _Paths.PHOTO_CAPTURE,
      page: () => const PhotoCaptureView(),
      binding: PhotoCaptureBinding(),
    ),
    GetPage(
      name: _Paths.COMPLETION,
      page: () => const CompletionView(),
      binding: CompletionBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL,
      page: () => const DetailView(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: _Paths.EVIDENCE,
      page: () => const EvidenceView(),
      binding: EvidenceBinding(),
    ),
  ];
} 