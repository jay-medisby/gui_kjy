# Claude Code 프롬프트 시퀀스

> 아래 프롬프트를 Claude Code에서 **순서대로** 실행하세요.
> 각 프롬프트는 `---` 로 구분됩니다. 한 번에 하나씩 실행하고 결과 확인 후 다음으로 넘어가세요.

---

## Phase 0-1: Flutter 프로젝트 생성

```
Flutter 프로젝트를 생성해줘.

flutter create medisby_roboarm --platforms=linux,android

생성 후:
1. flutter pub add flutter_svg google_fonts provider go_router
2. 폴더 구조 생성:
   - lib/theme/
   - lib/widgets/
   - lib/screens/home/
   - lib/screens/settings/
   - lib/screens/admin/
   - lib/screens/pre_treatment/
   - lib/screens/treatment/
   - lib/screens/exit/
   - lib/screens/emergency/
   - lib/models/
   - lib/providers/
   - assets/icons/
   - assets/images/
3. pubspec.yaml에 assets 폴더 등록:
   assets:
     - assets/icons/
     - assets/images/
```

---

## Phase 0-2: 디자인 시스템 코드 생성 (MCP 활용)

```
Figma MCP를 통해 디자인 토큰을 읽어서 디자인 시스템 파일들을 생성해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC
참조할 섹션: Home (노드 ID: 329:13651)

1. Figma MCP의 get_variable_defs로 컬러/타이포/간격 토큰을 조회해줘
2. get_design_context 또는 get_screenshot으로 Home 섹션의 실제 디자인을 확인해줘
3. 조회 결과를 바탕으로 다음 파일들을 생성:

lib/theme/colors.dart
- AppColors 클래스, static const Color로 정의
- 배경(네이비), 사이드바, 카드(화이트), 버튼(그린/블루/레드/다크), 텍스트, 상태색, 모달 오버레이

lib/theme/text_styles.dart
- AppTextStyles 클래스
- 대제목, 소제목, 본문, 버튼, 캡션 등 최소 5단계
- 폰트: Pretendard (없으면 Noto Sans KR 폴백)

lib/theme/dimensions.dart
- AppDimensions 클래스
- 사이드바 너비(230), 상태바 높이, 카드 padding, 카드 border-radius(16), 버튼 크기/radius, 화면 크기(1280×720)

MCP에서 토큰값을 못 읽으면 Figma 스크린샷을 참고해서 가이드 문서의 값 사용:
- 배경: #1A1F3D, 그린: #2ECC71, 블루: #4A90D9, 레드: #E74C3C
```

---

## Phase 1-1: 뼈대 위젯 (AppScaffold + SidebarMenu + StatusBar)

```
Figma MCP에서 Home 섹션 (노드 ID: 329:13651)의 디자인을 읽어서
공통 레이아웃 위젯 3개를 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

1. lib/widgets/app_scaffold.dart — AppScaffold
   - 1280×720 고정 레이아웃
   - 좌측: SidebarMenu (약 230px)
   - 우측 상단: DeviceStatusBadge 영역 + 메인 콘텐츠 (child 위젯)
   - 하단: StatusBar
   - 배경: AppColors.background

2. lib/widgets/sidebar_menu.dart — SidebarMenu
   - 상단: MEDISBY 로고/홈 아이콘
   - 중간: 메뉴 버튼 4개 (아이콘 + 텍스트, 세로 배열)
   - 하단: 설정 버튼, 종료 버튼
   - 활성 메뉴: 그린 또는 블루 배경
   - 비활성: 어두운 네이비
   - 파라미터: currentMenu (enum), onMenuTap 콜백

3. lib/widgets/status_bar.dart — StatusBar
   - 좌측: 연결 상태 인디케이터 (초록 점 + "연결됨" 텍스트)
   - 우측: 현재 시각 (HH:MM 형식)
   - 높이: Figma에서 확인 (약 32~40px)
   - 배경: AppColors.statusBarBg

디자인 토큰: AppColors, AppTextStyles, AppDimensions 사용
Figma 스크린샷으로 실제 레이아웃 비율/여백을 확인해서 반영해줘.
```

---

## Phase 1-2: 기본 컴포넌트

```
Figma MCP에서 다양한 섹션을 참조해서 기본 공통 위젯들을 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC
참조 섹션들:
- Home: 329:13651
- Settings: 332:10147
- Go-Home: 332:10151

1. lib/widgets/device_status_badge.dart — DeviceStatusBadge
   - 우상단에 위치하는 장비 상태 표시
   - Ready(초록) / Run(초록) / 비상정지(빨강) 등 상태별 색상
   - 상태 텍스트 표시
   - Home 섹션 스크린샷에서 우상단 뱃지 디자인 확인

2. lib/widgets/app_button.dart — AppButton
   - variant: green, blue, red, dark
   - 각 variant별 색상, hover, disabled 상태
   - 크기: large, medium, small
   - Settings/Go-Home 섹션에서 버튼 스타일 확인

3. lib/widgets/content_card.dart — ContentCard
   - 흰색 배경, border-radius ≈16px
   - padding, 그림자 등 Figma에서 확인
   - child 위젯을 감싸는 컨테이너

4. lib/widgets/modal_overlay.dart — ModalOverlay
   - 반투명 어두운 배경 (AppColors.modalOverlay)
   - 중앙에 child 위젯 배치
   - Go-Home 섹션의 모달 팝업 디자인 참조

5. lib/widgets/confirm_dialog.dart — ConfirmDialog
   - ModalOverlay 위에 흰색 카드
   - 제목, 메시지, 확인/취소 버튼
   - Go-Home 섹션의 확인 팝업 디자인 참조

디자인 토큰: AppColors, AppTextStyles, AppDimensions 사용
```

---

## Phase 1-3: 커스텀 위젯 (게이지, 프로그레스)

```
Figma MCP에서 Treatment 섹션 (노드 ID: 332:10150)과 
Pre-treatment 섹션 (노드 ID: 332:10149)의 디자인을 읽어서
커스텀 위젯들을 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

1. lib/widgets/gauge_meter.dart — GaugeMeter
   - 반원형 부하도 미터 (CustomPainter)
   - Treatment 섹션에서 게이지 디자인 확인
   - 파라미터: value (0.0~1.0), label, 색상 구간 (초록→노랑→빨강)
   - 중앙에 현재 값 텍스트 표시

2. lib/widgets/circular_progress.dart — CircularProgress
   - 원형 프로그레스 링 (CustomPainter)
   - Treatment 섹션의 치료 결과 화면에서 디자인 확인
   - 파라미터: value (0.0~1.0), label, color
   - 중앙에 퍼센트 표시

3. lib/widgets/step_indicator.dart — StepIndicator
   - 도트 네비게이션 (최대 12단계)
   - Pre-treatment 섹션에서 스텝 인디케이터 디자인 확인
   - 파라미터: currentStep, totalSteps
   - 현재 스텝: 활성 색상, 이전 스텝: 완료 색상, 이후: 비활성

4. lib/widgets/trajectory_progress_bar.dart — TrajectoryProgressBar
   - 궤적 내 현재 위치 표시 프로그레스 바
   - Treatment 섹션에서 디자인 확인
   - 파라미터: currentPosition, totalPositions, labels

디자인 토큰: AppColors, AppTextStyles, AppDimensions 사용
CustomPainter로 구현 (이미지 아닌 코드)
```

---

## Phase 1-4: 라우팅 설정

```
go_router로 앱 라우팅을 설정해줘.

lib/main.dart와 라우팅 설정:

라우트 구조:
- / → HomeScreen
- /settings → SettingsModal (모달이지만 라우트 있으면 편리)
- /admin → AdminMenuScreen
- /admin/users → UserManagementScreen
- /admin/rom-test → RomTestFlow
- /admin/vel-test → VelTestFlow
- /pre-treatment → PreTreatmentFlow (12단계 위저드)
- /treatment → TreatmentDashboard
- /treatment/trajectory-add → TrajectoryAddFlow
- /treatment/result → TreatmentResultScreen
- /exit → ExitFlow

비상정지(EmergencyStop)와 안전정지(SafeStop)는 라우트가 아닌 
전역 Overlay로 처리 (어떤 화면에서든 발생 가능).

Go-Home 팝업도 showDialog 패턴 사용.

main.dart에서:
- MaterialApp.router 사용
- 1280×720 고정, 랜드스케이프 고정
- 테마에 AppColors 기반 ThemeData 적용
- Provider 설정 (MultiProvider)
```

---

## Phase 2: Home 섹션

```
Figma MCP에서 Home 섹션 (노드 ID: 329:13651)의 모든 화면을 읽어서
Home 화면을 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

get_screenshot으로 전체 섹션 확인 후, 
개별 프레임들의 get_design_context로 상세 디자인을 파악해줘.

lib/screens/home/home_screen.dart — HomeScreen
- AppScaffold 활용
- 메인 콘텐츠: ROBOARM 장비 일러스트(이미지) + 상태 메시지
- 상태별 분기:
  - ready: "준비 완료" 메시지, 시작 버튼 활성
  - resetting: 리셋 진행 중 (step 1~4), 프로그레스 표시
  - error: 에러 메시지 (장비 상태 오류 등)
- 01_home_ready와 01_home_reset_1~4를 하나의 위젯에서 state 파라미터로 처리
- 사이드바: 홈 메뉴 활성 상태

아직 일러스트 이미지 에셋이 없으면 Placeholder로 대체하고 
TODO 주석 남겨줘.
```

---

## 이후 Phase 3~8은 같은 패턴으로 진행

각 Phase에서 Claude Code에 입력할 프롬프트 패턴:

```
Figma MCP에서 [섹션이름] 섹션 (노드 ID: [노드ID])의 디자인을 읽어서
[화면이름]을 Flutter 위젯으로 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

get_screenshot으로 전체 섹션 확인 후,
개별 프레임들의 get_design_context로 상세 디자인을 파악해줘.

조건:
- 1280×720 고정 해상도
- AppScaffold, SidebarMenu 등 기존 공통 위젯 활용
- 디자인 토큰: AppColors, AppTextStyles, AppDimensions 참조
- [해당 화면의 상태 변화 설명 — claude.md의 상태 변화 그룹핑 참조]
```

### Phase별 섹션 ID 빠른 참조:
- Phase 3 Settings: 332:10147
- Phase 4 Admin: 332:10148
- Phase 5 Pre-treatment: 332:10149
- Phase 6 Treatment: 332:10150
- Phase 7 Exit: 332:10152 / Stop: 332:10153
- Phase 8 Go-Home: 332:10151

---

## 매 Phase 완료 후: claude.md 업데이트

```
claude.md의 현재 진행 상태에서 Phase [N]을 완료로 표시해줘.
새로 만든 위젯이나 주의사항이 있으면 claude.md에도 추가해줘.
```
