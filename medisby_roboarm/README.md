# Medisby ROBOARM GUI

의료용 로봇팔(ROBOARM) 치료 장비의 터치스크린 GUI 애플리케이션

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 프레임워크 | Flutter 3.10.8+, Dart 3.10.8 |
| 타겟 플랫폼 | Windows, Linux, Android |
| 디스플레이 | 1280×720 고정 해상도 (랜드스케이프) |
| 상태 관리 | Provider (ChangeNotifier) |
| 라우팅 | go_router (ShellRoute) |
| 폰트 | Noto Sans KR (google_fonts) |

## 주요 기능

### Home
- 장비 초기화 상태 표시 (initializing → armNotHome → moving → ready)
- 롱프레스 홈 복귀 버튼

### Pre-treatment (치료 준비)
- 12단계 위저드: 환자군 선택 → 부위 선택(상지/하지 × 좌/우) → 로봇팔 이동 → 정렬 → 바퀴 선택 → 착용 → 체결 → 시작 자세 → 궤적 설정 → 궤적 확인 → 속도/시간 파라미터 → 핸드스위치 확인
- 상지/하지 분기를 BodyPart enum으로 통합 처리

### Treatment (치료 진행)
- 실시간 대시보드: 속도(1-10), 부하도 게이지(0-100%), 남은 시간
- 시간 조절 (±1분, ±5분)
- 궤적 프로그레스 바 (시작↔끝 위치 표시)
- 궤적 추가 3단계 플로우
- 치료 결과 화면 (평균 속도 / 치료 시간 / 평균 부하 원형 프로그레스)

### Settings (설정)
- 18페이지 상태머신 모달
- 장비 초기화 플로우 (5단계)
- 시스템 정보 조회
- 관리자 모드 (비밀번호 보호)
  - 사용자 관리 (전체 사용자 / 등록 요청 탭)
  - ROM 테스트 위저드 (J1~J6 관절 선택)
  - 속도 테스트 위저드

### Exit / Stop
- 종료 플로우: 확인 → 구동장착부 탈착 → 홈 이동 → 완료
- 비상정지 / 보호정지 통합 (StopType enum): 어떤 화면에서든 전역 Overlay로 호출
- Go-Home 플로우: 치료 중 홈 아이콘 탭 시 4단계 모달

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, Provider 설정, 랜드스케이프 고정
├── router.dart                        # go_router 설정 (ShellRoute + AppScaffold)
│
├── models/
│   ├── body_part.dart                 # BodyPart(upper/lower), BodyPartSelection(4방향)
│   └── menu_type.dart                 # MenuType(start/patient/treatmentLog/settings/exit)
│
├── providers/
│   └── device_provider.dart           # DeviceProvider: 연결 상태, 장비 상태
│
├── theme/
│   ├── colors.dart                    # 22개 컬러 토큰
│   ├── text_styles.dart               # 10단계 텍스트 스타일 (displayLarge~caption)
│   └── dimensions.dart                # 레이아웃 상수 (1280×720, 사이드바 230px 등)
│
├── widgets/                           # 15개 공통 위젯
│   ├── app_scaffold.dart              # 메인 레이아웃: 사이드바 + 콘텐츠 + 상태바 + 뱃지
│   ├── sidebar_menu.dart              # 좌측 네비게이션 (230px)
│   ├── status_bar.dart                # 하단 상태바: 연결 상태 + 현재 시각
│   ├── device_status_badge.dart       # 우상단 장비 상태 뱃지
│   ├── app_button.dart                # 통합 버튼 (4 variant × 3 size)
│   ├── content_card.dart              # 흰색 라운드 카드 컨테이너
│   ├── modal_overlay.dart             # 반투명 오버레이
│   ├── confirm_dialog.dart            # 확인 다이얼로그 (970×544)
│   ├── step_indicator.dart            # 도트 네비게이션 (최대 14단계)
│   ├── gauge_meter.dart               # 반원형 게이지 (CustomPainter, 3구간)
│   ├── circular_progress.dart         # 원형 프로그레스 링 (CustomPainter)
│   ├── trajectory_progress_bar.dart   # 궤적 프로그레스 바
│   ├── joint_selector.dart            # J1~J6 관절 선택 그리드
│   ├── long_press_move_button.dart    # 롱프레스 이동 버튼
│   ├── warning_box.dart               # 경고 박스
│   └── settings_modal_base.dart       # 설정 모달 컨테이너 (브레드크럼 지원)
│
└── screens/
    ├── home/
    │   ├── home_screen.dart           # 홈 화면 (4개 상태)
    │   └── go_home_flow.dart          # 홈 복귀 모달 (4단계)
    ├── settings/
    │   ├── settings_flow.dart         # 설정 모달 (18페이지 상태머신)
    │   └── admin/
    │       ├── admin_menu_screen.dart
    │       ├── user_management_screen.dart
    │       ├── rom_test_flow.dart
    │       └── vel_test_flow.dart
    ├── pre_treatment/
    │   └── pre_treatment_flow.dart    # 치료 준비 위저드 (12단계)
    ├── treatment/
    │   ├── treatment_dashboard.dart   # 치료 대시보드
    │   ├── trajectory_add_flow.dart   # 궤적 추가 (3단계)
    │   └── treatment_result_screen.dart # 치료 결과 (4단계)
    ├── exit/
    │   └── exit_flow.dart             # 종료 모달 (4단계)
    └── emergency/
        └── stop_flow.dart             # 비상정지/보호정지 (4단계, Overlay)

assets/
├── icons/    # 32개 SVG 아이콘
└── images/   # 33개 PNG 이미지 (로봇팔, 환자군, 부위별 이미지 등)
```

## 아키텍처

### 라우팅
```
/ (ShellRoute → AppScaffold)
├── /                    → HomeScreen
├── /pre-treatment       → PreTreatmentFlow
└── /treatment           → TreatmentDashboard
    ├── /trajectory-add  → TrajectoryAddFlow
    └── /result          → TreatmentResultScreen

모달 (showDialog / Overlay):
├── Settings, Exit       → showDialog()
└── Stop (Emergency/Safe)→ 전역 Overlay
```

### 상태 관리
- **전역**: `DeviceProvider` (Provider) — 장비 연결 상태, 장비 상태 (Online/Ready/Run/Emergency)
- **화면별**: `StatefulWidget.setState()` — 각 플로우의 단계별 로컬 상태

### 설계 패턴
- **상지/하지 분기**: BodyPart enum 파라미터로 단일 위젯에서 처리
- **상태 변화 그룹핑**: enum으로 동일 레이아웃의 상태 분기 (HomeStatus, PreTreatmentStep 등)
- **모달 우선 네비게이션**: Settings, Exit, Stop은 라우트가 아닌 showDialog/Overlay 사용
- **CustomPainter**: 게이지, 원형 프로그레스 등 커스텀 렌더링

## 디자인 시스템

### 컬러 팔레트
| 용도 | 색상 |
|------|------|
| 배경 | `#002060` Deep Navy |
| 확인/시작 | `#10B981` Green |
| 활성/선택 | `#3B82F6` Blue |
| 경고/종료 | `#FF6D6D` Red |
| 설정/다크 | `#262626` Dark |
| 경고 텍스트 | `#FF8C42` Orange |
| 카드/다이얼로그 | `#FFFFFF` White |

### 레이아웃 상수
| 요소 | 크기 |
|------|------|
| 전체 화면 | 1280×720 |
| 사이드바 | 230px |
| 콘텐츠 영역 | 984×549 |
| 상태바 | 29px |
| 모달 카드 | 970×544 |

## 의존성

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.5+1          # 상태 관리
  go_router: ^17.1.0          # 라우팅
  google_fonts: ^8.0.2        # Noto Sans KR
  flutter_svg: ^2.2.3         # SVG 아이콘 렌더링
  cupertino_icons: ^1.0.8
```

## 빌드 및 실행

```bash
# 의존성 설치
flutter pub get

# Windows 실행
flutter run -d windows

# Linux 실행
flutter run -d linux

# Android 실행
flutter run -d <device_id>
```

## 개발 진행 상태

- [x] Phase 0: 프로젝트 초기화 + 디자인 시스템 (colors, text_styles, dimensions)
- [x] Phase 1: 공통 위젯 구현 (15개)
- [x] Phase 2: Home 섹션
- [x] Phase 3: Settings 섹션 (Admin 포함)
- [x] Phase 4: Pre-treatment 섹션 (12단계 위저드)
- [x] Phase 5: Treatment 섹션 (대시보드 + 궤적 추가 + 결과)
- [x] Phase 6: Exit + Stop 섹션 (비상정지/보호정지)
- [x] Phase 7: Go-Home 플로우
- [ ] Phase 8: 상태 관리 통합 & 백엔드 연동
