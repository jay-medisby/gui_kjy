# 메디스비 ROBOARM GUI 프로젝트

## 프로젝트 개요
- 의료용 로봇팔(ROBOARM) 치료 장비의 터치스크린 GUI
- 해상도: 1280×720 고정 (랜드스케이프, 임베디드 디스플레이)
- Flutter 프레임워크, 타겟: Windows + Linux + Android
- 개발 환경: Windows 11
- flutter_screenutil 미사용 — 고정 해상도이므로 고정 레이아웃

## Figma 연동
- Figma File Key: `8pB0iV0zAVNG5Sw5XcwznC`
- Figma MCP 연동 완료 — 디자인 토큰 및 노드 데이터 직접 조회 가능
- MCP 도구: get_design_context, get_screenshot, get_variable_defs, get_metadata 활용

### ⚠️ 디자인 참조 우선순위
1. **로컬 스크린샷 우선** — `../screenshot/` 폴더의 PNG 파일을 Read 도구로 직접 열어서 확인
2. **Figma API는 보조** — 로컬 스크린샷으로 충분하지 않을 때만 사용 (rate limit 주의)
3. 파일명 패턴: `{번호}_{섹션}_{상태}.png` — 번호가 섹션을 구분

### 스크린샷 폴더 (../screenshot/)

| 섹션 | 번호 범위 | 파일 수 | 파일 접두사 패턴 |
|------|----------|--------|----------------|
| Home | 01 | 5 | `01_home_*` |
| Settings | 03~05, 10~11 | 7 | `03_setting`, `04_setting_reset`, `05_setting_reset_yes`, `10_setting_reset_*`, `11_setting_systeminfo` |
| Admin | 12~24 | 20 | `12_setting_adminaccess*`, `13_setting_admin`, `14~15_*usermanagement*`, `16~19_*romtest*`, `20~24_*veltest*` |
| Pre-treatment | 30~43 | 36 | `30_start_pre_step1*` ~ `43_start_pre_step14` |
| Treatment | 44~59 | 19 | `44_start_treat` ~ `59_start_treat_end_3` |
| Exit | 62~64 | 5 | `62_exit*`, `63_exit_moving*`, `64_exit_done` |
| Emergency Stop | 70~75 | 6 | `70_emergency_stop_step1` ~ `75_emergency_stop_step4` |
| Safe Stop | 80~85 | 6 | `80_safe_stop_step1` ~ `85_safe_stop_step4` |
| Go-Home | 90~94 | 5 | `90` ~ `94` (접두사 없음) |

#### 사용법
```
# 특정 섹션 구현 전 — 해당 스크린샷들을 Read 도구로 열어 디자인 확인
Read ../screenshot/01_home_ready.png
Read ../screenshot/01_home_reset_1.png
# Glob으로 섹션 파일 일괄 검색
Glob ../screenshot/01_home_*.png
Glob ../screenshot/30_start_pre_*.png
```

### 섹션 노드 ID 매핑표 (Figma API용)

| 섹션 | 노드 ID | 화면 수 | 설명 |
|------|---------|--------|------|
| Home | 329:13651 | 5 | 홈 화면 + 리셋 플로우 |
| Settings | 332:10147 | 10 | 설정 메뉴 (초기화/관리자모드/시스템정보) |
| Admin | 332:10148 | 17 | Settings의 하위 — 사용자 관리, ROM/속도 테스트 |
| Pre-treatment | 332:10149 | 36 | 치료 준비 12단계 위저드 |
| Treatment | 332:10150 | 19 | 치료 진행 대시보드, 궤적, 결과 |
| Exit | 332:10152 | 5 | 종료 플로우 |
| Stop | 332:10153 | 12 | 비상정지 + 안전정지 |
| Go-Home | 332:10151 | 5 | 홈 복귀 확인 팝업 등 |

### 메뉴 구조
```
사이드바 메뉴
├── 홈
├── [치료 시작 관련 메뉴들]
├── 설정 (Settings)
│   ├── 초기화
│   ├── 관리자 모드 (Admin) ← Settings의 하위 메뉴
│   │   ├── 사용자 관리 (탭: 전체 사용자 / 등록 요청)
│   │   ├── ROM 테스트
│   │   └── 속도 테스트
│   └── 시스템 정보
└── 종료
```

## 핵심 설계 원칙

### ⚠️ 상지/하지 분기 패턴 (매우 중요)
많은 화면이 "상지(Upper Limb)"와 "하지(Lower Limb)"에 따라 **동일 레이아웃에 텍스트와 이미지만 바뀌는 구조**이다.
이런 화면들을 절대 별도 위젯으로 만들지 않고, **하나의 위젯 + BodyPart 파라미터**로 처리한다.

```dart
enum BodyPart { upper, lower }

// 예시: 치료 준비 화면
class PreTreatmentStepScreen extends StatelessWidget {
  final BodyPart bodyPart;
  final int step;
  // bodyPart에 따라 텍스트, 이미지, 설명이 바뀜
}
```

**적용 대상**: Pre-treatment, Treatment 등에서 상지/하지에 따라 다른 화면들 전부.
Figma에서 상지/하지 화면이 따로 있더라도 Flutter에서는 하나의 위젯으로 통합한다.

### 상태 변화 화면 그룹핑
같은 레이아웃에서 상태만 바뀌는 화면 → 하나의 위젯 + 상태 파라미터로 처리:
- HomeScreen(state: ready/resetting) ← 01_home_ready, 01_home_reset_1~4
- ResetProgressScreen(step: 1/2/done) ← 10_setting_reset_moving1~done
- RomTestScreen(isPaused: bool) ← 17_romtest_moving, moving_pause
- Step1Screen(selectedCard: int?) ← 30_start_pre_step1, step1_1~3
- TreatmentScreen(isPaused: bool) ← 44_start_treat, 52_pause
- EmergencyStopFlow(currentStep: int) ← 70~75
- SafeStopFlow(currentStep: int) ← 80~85

### 화면 중복 방지 원칙 요약
1. **상지/하지 분기** → BodyPart enum 파라미터
2. **상태 변화** → state/step 파라미터
3. **유사 레이아웃 스텝** → 공통 StepTemplate 위젯 재사용
4. **Emergency/SafeStop** → 공통 StopFlow + type 파라미터

## 디자인 규칙

### 레이아웃 (모든 화면 공통)
- 좌측 사이드바: 약 230px, 홈 아이콘 + 메뉴 버튼들 + 설정/종료
- 우측 메인 콘텐츠: 약 1050px, 흰색 라운드 카드 (border-radius ≈16px)
- 하단 상태바: 연결 상태 + 현재 시각
- 우상단: 장비 상태 뱃지 (Ready/Run + 상태 텍스트)

### 컬러 (Figma MCP 실측값 — lib/theme/colors.dart)
- 배경: #002060 (Deep Navy)
- 사이드바 활성: 블루(#3B82F6), 비활성: rgba(255,255,255,0.05)
- 주요 액션 버튼: 그린(#10B981), 블루(#3B82F6), 레드(#FF6D6D), 다크(#262626)
- 카드/콘텐츠: 화이트(#FFFFFF), 라운드 코너 10~16px
- 모달: rgba(0,0,0,0.6) 오버레이 + 970×544 흰색 카드
- 상태바: rgba(255,255,255,0.1) 배경
- 경고/오렌지: #FF8C42, 민트그린: #E6FFE8

### 컴포넌트 패턴
- 모달 다이얼로그 (showDialog + ModalOverlay/ConfirmDialog, 별도 라우트 불필요)
- 스텝 인디케이터 (도트 20px, gap 14px, 최대 14단계, 활성 #10B981)
- 게이지/미터 (반원형 부하도 → CustomPainter, 3구간 초록→노랑→빨강)
- 원형 프로그레스 (치료 결과 → CustomPainter, 링 strokeWidth 16)
- 궤적 프로그레스 바 (완료 초록40% + 미완료 파랑50%, 마커선 #6C6A6A)
- 숫자 조절 (속도 ↑↓, 시간 ±1분/±5분)
- 탭 UI, 카드 선택 UI

## 코드 컨벤션
- 상태 관리: Provider
- 라우팅: go_router
- 한글 폰트: Noto Sans KR (google_fonts 패키지, Figma 디자인 기준)
- CustomPainter: 게이지, 원형 프로그레스 등은 이미지 아닌 코드 구현
- 비상정지: 어떤 화면에서든 발생 가능 → 전역 상태, Overlay 패턴

### 폴더 구조
```
lib/
├── main.dart
├── theme/          → colors.dart, text_styles.dart, dimensions.dart
├── widgets/        → 공통 위젯 (AppScaffold, SidebarMenu, StatusBar 등)
├── screens/
│   ├── home/
│   ├── settings/       → 설정 메뉴 + 초기화 + 시스템 정보
│   │   └── admin/      → 관리자 모드 (Settings 하위)
│   ├── pre_treatment/
│   ├── treatment/
│   ├── exit/
│   └── emergency/      → 비상정지 + 안전정지
├── models/         → BodyPart enum, 데이터 모델
└── providers/      → 상태 관리
assets/
├── icons/          → SVG 아이콘
└── images/         → PNG 일러스트 (상지/하지별 이미지 포함)
```

### 공통 위젯 목록 (lib/widgets/ — 전부 구현 완료)
| 파일 | 위젯 | 설명 |
|------|------|------|
| app_scaffold.dart | AppScaffold | 1280×720 고정, 사이드바+콘텐츠+상태바+배지 |
| sidebar_menu.dart | SidebarMenu | 좌측 230px, MenuType enum, 활성/비활성 |
| status_bar.dart | StatusBar | 하단 29px, 연결상태 + HH:MM:SS |
| device_status_badge.dart | DeviceStatusBadge | 170×70, DeviceStatus enum (Online/Ready/Run/Emergency) |
| app_button.dart | AppButton | ButtonVariant(green/blue/red/dark/white) × ButtonSize(large/medium/small/dialog) |
| content_card.dart | ContentCard | 흰색 라운드 카드, 커스텀 크기/radius/padding |
| modal_overlay.dart | ModalOverlay | rgba(0,0,0,0.6) 배경, 중앙 child |
| confirm_dialog.dart | ConfirmDialog | 970×544 모달, 제목/메시지/확인/취소/뒤로/닫기 |
| step_indicator.dart | StepIndicator | 도트 20px, gap 14px, 최대 14단계 |
| gauge_meter.dart | GaugeMeter | CustomPainter 반원형 부하도, 3구간 색상+니들 |
| circular_progress.dart | CircularProgress | CustomPainter 원형 링, 중앙 % 표시 |
| trajectory_progress_bar.dart | TrajectoryProgressBar | 궤적 바, 초록/파랑 영역+마커+라벨 |
| settings_modal_base.dart | SettingsModalBase | 다크 모달 컨테이너 970×544, 타이틀/브레드크럼/뒤로/닫기 |
| joint_selector.dart | JointSelector | J1~J6 관절 선택 그리드 (ROM/속도 테스트) |
| long_press_move_button.dart | LongPressMoveButton | 롱프레스 이동 버튼 (Home/Reset 공통) |
| warning_box.dart | WarningBox | 오렌지 경고 텍스트 (boxed/inline) |
| flow_step_widgets.dart | DetachStepView, MovingStepView | Exit/GoHome 공통 탈착·이동 스텝 위젯 |

### 화면 목록 (lib/screens/)
| 경로 | 위젯 | 설명 |
|------|------|------|
| home/home_screen.dart | HomeScreen | 상태별 분기(initializing/armNotHome/moving/ready) |
| settings/settings_flow.dart | SettingsFlow | 18페이지 상태머신 모달 (설정+초기화+시스템정보+관리자+ROM/속도테스트+사용자관리) |
| pre_treatment/pre_treatment_flow.dart | PreTreatmentFlow | 12단계 위저드 (환자군→부위→암이동→정렬→바퀴→착용→체결→시작자세→궤적→확인→파라미터→핸드스위치) |
| treatment/treatment_dashboard.dart | TreatmentDashboard | 치료 대시보드 (속도/부하도/남은시간 + 궤적바 + 일시정지/종료/궤적추가 모달) |
| treatment/trajectory_add_flow.dart | TrajectoryAddFlow | 궤적 추가 3단계 (끝으로이동→새궤적입력→확인) |
| treatment/treatment_result_screen.dart | TreatmentResultScreen | 치료결과 + 구동장착부탈착 + 착용해제 + 홈위치이동 4단계 |
| exit/exit_flow.dart | ExitFlow | 종료 모달 4단계 (확인→탈착→홈이동→완료) — showDialog 패턴 |
| emergency/stop_flow.dart | StopFlow | 비상정지/보호정지 통합 4단계 (StopType.emergency/safe) — 전역 Overlay |
| home/go_home_flow.dart | GoHomeFlow | 홈 복귀 모달 4단계 (확인→탈착→이동→완료) — 치료 중 홈 아이콘 탭 시 |

### 모델 목록 (lib/models/)
| 파일 | 설명 |
|------|------|
| body_part.dart | `enum BodyPart { upper, lower }` + `enum BodyPartSelection { rightUpper, leftUpper, rightLower, leftLower }` — 상지/하지/좌/우 분기 |
| menu_type.dart | `enum MenuType { start, patient, treatmentLog, settings, exit }` — 사이드바 메뉴 |

### Figma MCP 조회 시 주의사항
- **로컬 스크린샷(`../screenshot/`)을 먼저 확인** — Figma API 호출 전에 항상 로컬 파일 우선 사용
- depth=3이면 카드 내부 벡터(게이지/프로그레스 도형)가 안 보임 → depth=5~6 필요
- Figma API rate limit (429) 발생 시 30초~1분 대기 후 재시도
- JSON이 단일 라인으로 저장되어 grep이 안 됨 → python 파싱 또는 에이전트 위임

## 현재 진행 상태
- [x] Phase 0: 프로젝트 초기화 + 디자인 시스템
- [x] Phase 1: 공통 위젯 구현
- [x] Phase 2: Home 섹션
- [x] Phase 3: Settings 섹션 (Admin 포함)
- [x] Phase 4: Pre-treatment 섹션
- [x] Phase 5: Treatment 섹션
- [x] Phase 6: Exit + Stop 섹션
- [x] Phase 7: Go-Home(Popups) + 폴리싱
- [x] Phase 8: 코드 리팩토링 (아래 검토 결과 기반) ✅ 2025-02-25
- [ ] Phase 9: 상태 관리 & 백엔드 통합

---

## 코드 검토 결과 (2025-02-25)

### 검토 통과 항목
- **flutter analyze**: 경고/에러 0건
- **라우팅 정합성**: 10개 context.go() 호출 모두 router.dart 정의와 일치
- **Provider 사용**: watch/read 구분 정확, 안티패턴 없음
- **Navigator 사용**: 모달 dismiss 용도로만 사용 (라우팅과 혼용 없음)
- **리소스 관리**: Timer dispose 정상, 메모리 누수 없음
- **에셋 경로**: 모든 참조 파일 존재 확인

### 리팩토링 대상 (우선순위순)

#### P0: 대형 파일 분할 — ⏸️ 보류 (Dart 언어 제약)
Dart의 `part`/`extension` 패턴으로 클래스 분할 시도 → 실패.
- Extension 간 메서드 교차 호출 불가 (Dart에서 `this.method()`는 extension 메서드를 탐색하지 않음)
- `setState`가 `@protected`이므로 extension에서 호출 시 경고 발생
- 대안: 별도 StatelessWidget으로 분할하려면 콜백/상태 전달이 과도하여 비실용적

#### P1: 하드코딩 컬러 → AppColors 통합 — ✅ 완료
- colors.dart에 14개 토큰 추가 (divider, contentBgGray, contentBgGreen, placeholderBg, buttonDisabled, darkGray, gaugeYellow, gaugeBg, trajectoryMarker, warningBgLight, warningYellow, warningAmber, warningOrangeDark)
- 10개 파일에서 ~43개 하드코딩 Color(0x...) 교체

#### P2: 중복 버튼 → AppButton 통합 — ✅ 완료
- AppButton에 `ButtonVariant.white` (흰색 배경/검정 텍스트) + `ButtonSize.dialog` (200×60) 추가
- exit_flow, go_home_flow, treatment_dashboard, stop_flow의 커스텀 버튼 → AppButton 교체
- treatment_result_screen (380×55) 및 stop_flow의 accent 색상 버튼은 고유 사이즈/스타일이므로 유지

#### P3: 중복 플로우 스텝 통합 — ✅ 완료
- `lib/widgets/flow_step_widgets.dart` 생성: `DetachStepView` + `MovingStepView` 공통 위젯
- exit_flow.dart, go_home_flow.dart에서 중복 코드 → 공통 위젯 사용으로 교체

#### P4: 미사용 스텁 파일 정리 — ✅ 완료
- 삭제된 파일 4개 (settings_flow.dart에 이미 통합 구현되어 미참조):
  - admin_menu_screen.dart, rom_test_flow.dart, vel_test_flow.dart, user_management_screen.dart

#### P5: 하드코딩 치수 → AppDimensions 추가 — ✅ 완료
- dimensions.dart에 4개 상수 추가: navButtonWidth(380), navButtonHeight(55), smallBorderRadius(8), mediumBorderRadius(12)
- 7개 nav 버튼 인스턴스, 10개 BorderRadius.circular(12), 14개 BorderRadius.circular(8) 교체

### 리팩토링 시 원칙
- 기능 변경 없이 구조만 개선 (동작 동일 유지)
- 파일 분할 시 import 경로 정리 + flutter analyze 통과 확인
- 한 번에 하나의 P단계만 진행하고 빌드 확인 후 다음 단계로
