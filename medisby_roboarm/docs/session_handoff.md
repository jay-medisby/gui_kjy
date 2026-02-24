# Session Handoff — Medisby ROBOARM GUI

> 작성일: 2026-02-24
> 환경: Windows 11, Flutter 3.38.9, Dart 3.10.8
> 프로젝트 경로: `C:\Users\HP\Desktop\github\gui_kjy\medisby_roboarm`
> `flutter analyze`: **No issues found**

---

## 1. 완료된 작업

### Phase 0: 프로젝트 초기화 + 디자인 시스템

| 작업 | 상태 |
|------|------|
| `flutter create medisby_roboarm --platforms=windows,linux,android` | 완료 |
| 패키지 추가 (flutter_svg, google_fonts, provider, go_router) | 완료 |
| 폴더 구조 생성 (theme, widgets, screens/*, models, providers, assets/*) | 완료 |
| pubspec.yaml에 assets 폴더 등록 | 완료 |

**디자인 시스템 파일 (Figma MCP 실측값 기반):**

| 파일 | 내용 |
|------|------|
| `lib/theme/colors.dart` | AppColors — 22개 컬러 토큰 (배경 #002060, 그린 #10B981, 블루 #3B82F6 등) |
| `lib/theme/text_styles.dart` | AppTextStyles — 10단계 텍스트 스타일, Noto Sans KR (google_fonts) |
| `lib/theme/dimensions.dart` | AppDimensions — 화면(1280×720), 사이드바(230), 상태바(29), 버튼/모달/아이콘/간격 전체 |

### Phase 1: 공통 위젯 구현

**레이아웃 위젯 (3개):**

| 파일 | 위젯 | 핵심 파라미터 |
|------|------|-------------|
| `app_scaffold.dart` | AppScaffold | child, currentMenu, onMenuTap, deviceStatus, isConnected |
| `sidebar_menu.dart` | SidebarMenu | currentMenu (MenuType enum), onMenuTap 콜백 |
| `status_bar.dart` | StatusBar | isConnected (연결 상태 점 + 실시간 시계) |

**기본 공통 위젯 (5개):**

| 파일 | 위젯 | 핵심 파라미터 |
|------|------|-------------|
| `device_status_badge.dart` | DeviceStatusBadge | DeviceStatus enum (Online/Ready/Run/Emergency) |
| `app_button.dart` | AppButton | ButtonVariant(green/blue/red/dark) × ButtonSize(large/medium/small) |
| `content_card.dart` | ContentCard | child, width, height, borderRadius, padding |
| `modal_overlay.dart` | ModalOverlay | child, dismissible, barrierColor |
| `confirm_dialog.dart` | ConfirmDialog | title, message, confirmLabel, cancelLabel, showBack, content |

**커스텀 위젯 (4개, CustomPainter):**

| 파일 | 위젯 | 핵심 파라미터 |
|------|------|-------------|
| `gauge_meter.dart` | GaugeMeter | value(0~1), size, label, unit — 반원형 3구간(초록→노랑→빨강) |
| `circular_progress.dart` | CircularProgress | value(0~1), size, activeColor, strokeWidth, centerLabel |
| `step_indicator.dart` | StepIndicator | currentStep, totalSteps, dotSize(20), gap(14) |
| `trajectory_progress_bar.dart` | TrajectoryProgressBar | value(0~1), height, startLabel, endLabel |

**모델 (2개):**

| 파일 | 내용 |
|------|------|
| `lib/models/body_part.dart` | `enum BodyPart { upper, lower }` |
| `lib/models/menu_type.dart` | `enum MenuType { start, patient, treatmentLog, settings, exit }` (label, icon 포함) |

**기타:**
- `lib/main.dart` — MedisbyApp + _DemoHome (AppScaffold 동작 확인용 임시 화면)
- `test/widget_test.dart` — MedisbyApp 렌더링 smoke test
- assets/icons/ — SVG 아이콘 32개 다운로드 완료
- assets/images/ — PNG 이미지 30개 다운로드 완료

---

## 2. 현재 진행 중이던 작업

Phase 1까지 **완전히 완료**된 상태. Phase 2 (Home 섹션)는 아직 시작하지 않음.

Figma MCP를 통해 아래 섹션들의 데이터를 이미 조회/분석 완료:

| 섹션 | 노드 ID | 분석 상태 | 주요 발견 |
|------|---------|----------|----------|
| Home | 329:13651 | depth=3 완료 | 5개 화면 (ready, reset_1~4), 레이아웃 좌표 확보 |
| Settings | 332:10147 | depth=3 완료 | 10개 화면, 모달 패턴 (icon_back/icon_close 위치) |
| Go-Home | 332:10151 | depth=3 완료 | 5개 화면, 홈 복귀 모달 패턴 |
| Pre-treatment | 332:10149 | depth=2 완료 | 36개 화면, 도트 인디케이터 14단계 상세 좌표 |
| Treatment | 332:10150 | depth=3 완료 | 19개 화면, 카드 260×257 3개 (게이지/프로그레스/궤적) |

---

## 3. 다음에 이어서 해야 할 작업

### Phase 2: Home 섹션
- `lib/screens/home/home_screen.dart` 구현
  - 상태: ready / resetting (reset_1~4를 하나의 위젯으로)
  - 로봇 팔 이미지, 상태 텍스트, 홈 이동 버튼
  - Home 노드 Figma 데이터 이미 확보 — 바로 구현 가능
- go_router 셋업 (`lib/main.dart`에 라우팅 추가)
- Provider 기본 셋업 (장비 연결 상태, 현재 메뉴 상태)

### Phase 3: Settings 섹션
- 설정 모달 (초기화/관리자모드/시스템정보)
- 관리자 비밀번호 입력 모달
- 장비 초기화 플로우 (reset_moving1→2→done)
- Admin 하위: 사용자 관리, ROM 테스트, 속도 테스트

### Phase 4: Pre-treatment 섹션
- 12단계 위저드 (StepIndicator 활용)
- Step별 화면 구현 (BodyPart 분기)
- Step 5 오버레이 패턴

### Phase 5: Treatment 섹션
- 치료 대시보드 (GaugeMeter, CircularProgress, TrajectoryProgressBar 활용)
- 일시정지/재개 플로우
- 치료 결과 화면

### Phase 6: Exit + Stop 섹션
- 종료 플로우
- 비상정지 / 안전정지 (전역 Overlay 패턴)

### Phase 7~8: 통합, 폴리싱

---

## 4. 발견된 이슈 및 주의사항

### 환경 이슈
- **Developer Mode 미활성화**: Windows 빌드 시 symlink 관련 경고 발생. `ms-settings:developers`에서 개발자 모드를 켜야 함.
- **Figma API Rate Limit**: depth=5~6으로 깊은 조회 시 429 에러 발생. 30초~1분 대기 후 재시도 필요.

### 디자인 토큰 차이
가이드 문서 초기값과 Figma 실측값이 다름. **Figma 실측값을 코드에 적용함:**

| 항목 | 가이드 문서 | Figma 실측 (적용됨) |
|------|-----------|---------------------|
| 배경색 | #1A1F3D | #002060 |
| 그린 | #2ECC71 | #10B981 |
| 블루 | #4A90D9 | #3B82F6 |
| 레드 | #E74C3C | #FF6D6D |
| 카드 radius | 16px | 10px (버튼/상태), 16px (콘텐츠 카드) |
| 폰트 | Pretendard | Noto Sans KR |

### Figma MCP 조회 주의사항
- depth=3이면 카드 내부 벡터(게이지/프로그레스 도형)가 안 보임 → depth=5~6 필요
- JSON 결과가 단일 라인으로 저장되어 grep 불가 → python 파싱 또는 에이전트에 위임
- 큰 섹션(Pre-treatment 36화면)은 결과 93K+ 문자 → 반드시 에이전트로 분석

### 코드 설계 주의사항
- **상지/하지 분기**: 절대 별도 위젯으로 만들지 않음 → `BodyPart` enum 파라미터로 통합
- **상태 변화 화면**: 같은 레이아웃 상태만 다른 화면 → 하나의 위젯 + state 파라미터
- **SidebarMenu**: 설정은 모달로 열림 (별도 라우트 아님), Admin은 Settings 하위 메뉴
- **StatusBar**: Timer.periodic으로 1초마다 시간 갱신 — dispose 필수

---

## 5. 현재 파일 구조 트리

```
medisby_roboarm/
├── CLAUDE.md                     # 프로젝트 컨벤션 + 진행 상태
├── pubspec.yaml                  # Flutter 패키지 설정
├── docs/
│   └── session_handoff.md        # 이 문서
├── lib/
│   ├── main.dart                 # MedisbyApp + _DemoHome (임시)
│   ├── models/
│   │   ├── body_part.dart        # enum BodyPart { upper, lower }
│   │   └── menu_type.dart        # enum MenuType (label, icon 포함)
│   ├── providers/                # (비어 있음 — Phase 2에서 구현)
│   ├── screens/
│   │   ├── home/                 # (비어 있음 — Phase 2)
│   │   ├── settings/
│   │   │   └── admin/            # (비어 있음 — Phase 3)
│   │   ├── pre_treatment/        # (비어 있음 — Phase 4)
│   │   ├── treatment/            # (비어 있음 — Phase 5)
│   │   ├── exit/                 # (비어 있음 — Phase 6)
│   │   └── emergency/            # (비어 있음 — Phase 6)
│   ├── theme/
│   │   ├── colors.dart           # AppColors (22개 토큰)
│   │   ├── text_styles.dart      # AppTextStyles (10단계)
│   │   └── dimensions.dart       # AppDimensions (레이아웃 수치)
│   └── widgets/
│       ├── app_scaffold.dart     # 1280×720 전체 레이아웃
│       ├── sidebar_menu.dart     # 좌측 사이드바 메뉴
│       ├── status_bar.dart       # 하단 상태바
│       ├── device_status_badge.dart  # 우상단 장비 상태
│       ├── app_button.dart       # 공통 버튼 (4색 × 3크기)
│       ├── content_card.dart     # 흰색 라운드 카드
│       ├── modal_overlay.dart    # 모달 오버레이
│       ├── confirm_dialog.dart   # 확인/취소 다이얼로그
│       ├── step_indicator.dart   # 도트 네비게이션
│       ├── gauge_meter.dart      # 반원형 부하도 미터
│       ├── circular_progress.dart    # 원형 프로그레스 링
│       └── trajectory_progress_bar.dart  # 궤적 프로그레스 바
├── assets/
│   ├── icons/                    # SVG 아이콘 32개
│   └── images/                   # PNG 이미지 30개
└── test/
    └── widget_test.dart          # smoke test
```
