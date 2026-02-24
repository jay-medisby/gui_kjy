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

### 섹션 노드 ID 매핑표

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
| app_button.dart | AppButton | ButtonVariant(green/blue/red/dark) × ButtonSize(large/medium/small) |
| content_card.dart | ContentCard | 흰색 라운드 카드, 커스텀 크기/radius/padding |
| modal_overlay.dart | ModalOverlay | rgba(0,0,0,0.6) 배경, 중앙 child |
| confirm_dialog.dart | ConfirmDialog | 970×544 모달, 제목/메시지/확인/취소/뒤로/닫기 |
| step_indicator.dart | StepIndicator | 도트 20px, gap 14px, 최대 14단계 |
| gauge_meter.dart | GaugeMeter | CustomPainter 반원형 부하도, 3구간 색상+니들 |
| circular_progress.dart | CircularProgress | CustomPainter 원형 링, 중앙 % 표시 |
| trajectory_progress_bar.dart | TrajectoryProgressBar | 궤적 바, 초록/파랑 영역+마커+라벨 |

### 모델 목록 (lib/models/)
| 파일 | 설명 |
|------|------|
| body_part.dart | `enum BodyPart { upper, lower }` — 상지/하지 분기 |
| menu_type.dart | `enum MenuType { start, patient, treatmentLog, settings, exit }` — 사이드바 메뉴 |

### Figma MCP 조회 시 주의사항
- depth=3이면 카드 내부 벡터(게이지/프로그레스 도형)가 안 보임 → depth=5~6 필요
- Figma API rate limit (429) 발생 시 30초~1분 대기 후 재시도
- JSON이 단일 라인으로 저장되어 grep이 안 됨 → python 파싱 또는 에이전트 위임

## 현재 진행 상태
- [x] Phase 0: 프로젝트 초기화 + 디자인 시스템
- [x] Phase 1: 공통 위젯 구현
- [ ] Phase 2: Home 섹션
- [ ] Phase 3: Settings 섹션 (Admin 포함)
- [ ] Phase 4: Pre-treatment 섹션
- [ ] Phase 5: Treatment 섹션
- [ ] Phase 6: Exit + Stop 섹션
- [ ] Phase 7: Go-Home(Popups) + 폴리싱
- [ ] Phase 8: 상태 관리 & 통합
