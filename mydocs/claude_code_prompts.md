# Claude Code 프롬프트 시퀀스 (Windows 11 환경)

> 아래 프롬프트를 Claude Code에서 **순서대로** 실행하세요.
> 각 Phase는 `---` 로 구분됩니다.
> 한 번에 하나씩 실행하고 결과 확인 후 다음으로 넘어가세요.

---

## Phase 0-1: Flutter 프로젝트 생성

```
Flutter 프로젝트를 생성해줘. Windows 11 환경이야.

flutter create medisby_roboarm --platforms=windows,linux,android
cd medisby_roboarm

생성 후:
1. flutter pub add flutter_svg google_fonts provider go_router
2. 폴더 구조 생성:
   - lib\theme\
   - lib\widgets\
   - lib\screens\home\
   - lib\screens\settings\admin\
   - lib\screens\pre_treatment\
   - lib\screens\treatment\
   - lib\screens\exit\
   - lib\screens\emergency\
   - lib\models\
   - lib\providers\
   - assets\icons\
   - assets\images\
3. pubspec.yaml에 assets 폴더 등록
4. lib\models\body_part.dart 생성:
   enum BodyPart { upper, lower }
   — 상지/하지 분기를 위한 핵심 enum. 많은 화면에서 사용됨.
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

lib\theme\colors.dart
- AppColors 클래스, static const Color로 정의
- 배경(네이비), 사이드바, 카드(화이트), 버튼(그린/블루/레드/다크), 텍스트, 상태색, 모달 오버레이

lib\theme\text_styles.dart
- AppTextStyles 클래스
- 대제목, 소제목, 본문, 버튼, 캡션 등 최소 5단계
- 폰트: Pretendard (없으면 Noto Sans KR 폴백)

lib\theme\dimensions.dart
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

1. lib\widgets\app_scaffold.dart — AppScaffold
   - 1280×720 고정 레이아웃
   - 좌측: SidebarMenu (약 230px)
   - 우측 상단: DeviceStatusBadge 영역 + 메인 콘텐츠 (child 위젯)
   - 하단: StatusBar
   - 배경: AppColors.background

2. lib\widgets\sidebar_menu.dart — SidebarMenu
   - 상단: MEDISBY 로고/홈 아이콘
   - 중간: 메뉴 버튼들 (아이콘 + 텍스트, 세로 배열)
   - 하단: 설정 버튼, 종료 버튼
   - 활성 메뉴: 그린 또는 블루 배경
   - 비활성: 어두운 네이비
   - 파라미터: currentMenu (enum), onMenuTap 콜백
   - 설정은 Settings 모달을 열고, 그 안에 관리자 모드(Admin)가 하위 메뉴로 있음

3. lib\widgets\status_bar.dart — StatusBar
   - 좌측: 연결 상태 인디케이터 (초록 점 + "연결됨" 텍스트)
   - 우측: 현재 시각 (HH:MM 형식)
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

1. lib\widgets\device_status_badge.dart — DeviceStatusBadge
   - 우상단 장비 상태 표시 (Ready/Run/비상정지 등)
   - Home 섹션 스크린샷에서 우상단 뱃지 디자인 확인

2. lib\widgets\app_button.dart — AppButton
   - variant: green, blue, red, dark
   - 각 variant별 색상, hover, disabled 상태
   - 크기: large, medium, small

3. lib\widgets\content_card.dart — ContentCard
   - 흰색 배경, border-radius ≈16px, child 감싸는 컨테이너

4. lib\widgets\modal_overlay.dart — ModalOverlay
   - 반투명 어두운 배경 + 중앙 child 배치

5. lib\widgets\confirm_dialog.dart — ConfirmDialog
   - ModalOverlay 위에 흰색 카드 + 제목/메시지/확인/취소 버튼

디자인 토큰: AppColors, AppTextStyles, AppDimensions 사용
```

---

## Phase 1-3: 커스텀 위젯 (게이지, 프로그레스, 스텝)

```
Figma MCP에서 Treatment 섹션 (노드 ID: 332:10150)과 
Pre-treatment 섹션 (노드 ID: 332:10149)의 디자인을 읽어서
커스텀 위젯들을 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

1. lib\widgets\gauge_meter.dart — GaugeMeter (CustomPainter)
   - 반원형 부하도 미터, value(0.0~1.0), 색상 구간(초록→노랑→빨강)

2. lib\widgets\circular_progress.dart — CircularProgress (CustomPainter)
   - 원형 프로그레스 링, value(0.0~1.0), 중앙 퍼센트 표시

3. lib\widgets\step_indicator.dart — StepIndicator
   - 도트 네비게이션, currentStep/totalSteps 파라미터

4. lib\widgets\trajectory_progress_bar.dart — TrajectoryProgressBar
   - 궤적 내 위치 프로그레스 바

CustomPainter로 구현 (이미지 아닌 코드)
디자인 토큰: AppColors, AppTextStyles, AppDimensions 사용
```

---

## Phase 1-4: 라우팅 설정

```
go_router로 앱 라우팅을 설정해줘.

메뉴 구조 참고:
- Settings(설정)은 사이드바 버튼 → 모달로 열림
- Admin(관리자 모드)은 Settings 모달 내의 하위 메뉴 중 하나
- Settings 모달에서 관리자 모드 선택 → 비밀번호 입력 → Admin 화면으로 이동

라우트 구조:
- / → HomeScreen
- /admin → AdminMenuScreen (Settings에서 진입)
- /admin/users → UserManagementScreen
- /admin/rom-test → RomTestFlow
- /admin/vel-test → VelTestFlow
- /pre-treatment → PreTreatmentFlow (12단계 위저드)
- /treatment → TreatmentDashboard
- /treatment/trajectory-add → TrajectoryAddFlow
- /treatment/result → TreatmentResultScreen
- /exit → ExitFlow

Settings는 라우트 불필요 (showDialog 모달).
비상정지/안전정지는 전역 Overlay (라우트 불필요).
Go-Home 팝업도 showDialog 패턴.

main.dart에서:
- MaterialApp.router 사용
- 1280×720 고정, 랜드스케이프 고정
- 테마에 AppColors 기반 ThemeData 적용
- MultiProvider 설정
```

---

## Phase 2: Home 섹션

```
Figma MCP에서 Home 섹션 (노드 ID: 329:13651)의 모든 화면을 읽어서
Home 화면을 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

get_screenshot으로 전체 섹션 확인 후,
개별 프레임들의 get_design_context로 상세 디자인을 파악해줘.

lib\screens\home\home_screen.dart — HomeScreen
- AppScaffold 활용
- 메인 콘텐츠: ROBOARM 장비 일러스트 + 상태 메시지
- 상태별 분기:
  - ready: "준비 완료" 메시지
  - resetting: 리셋 진행 중 (step 1~4)
  - error: 에러 메시지
- 하나의 위젯에서 state 파라미터로 처리
- 일러스트 이미지 에셋 없으면 Placeholder + TODO 주석
```

---

## Phase 3: Settings + Admin 섹션

```
Figma MCP에서 Settings 섹션 (노드 ID: 332:10147)과
Admin 섹션 (노드 ID: 332:10148)의 디자인을 읽어서 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

⚠️ Admin은 Settings의 하위 메뉴이다 (독립 메뉴 아님).
Settings 모달에서 "관리자 모드" 선택 → 비밀번호 입력 → Admin 화면.

Settings 부분 (lib\screens\settings\):
- settings_modal.dart — 설정 메뉴 모달 (초기화/관리자모드/시스템정보)
- reset_confirm_dialog.dart — 초기화 확인 팝업
- reset_progress_screen.dart — 초기화 진행 (step 파라미터)
- system_info_screen.dart — 시스템 정보
- admin_access_screen.dart — 관리자 비밀번호 입력

Admin 부분 (lib\screens\settings\admin\):
- admin_menu_screen.dart — 관리자 메뉴
- user_management_screen.dart — 탭 UI (전체 사용자 / 등록 요청)
- rom_test_flow.dart — ROM 테스트 (관절 선택 → 이동 중 → 준비 → 실행)
- vel_test_flow.dart — 속도 테스트 (관절 선택 → 속도 선택 → 이동 중 → 실행)

⚠️ ROM 테스트/속도 테스트에서 상지/하지에 따라 텍스트/이미지만 바뀌는 화면은
BodyPart enum 파라미터로 분기 처리. 별도 위젯 만들지 않기.
```

---

## Phase 4: Pre-treatment 섹션

```
Figma MCP에서 Pre-treatment 섹션 (노드 ID: 332:10149)의 디자인을 읽어서
치료 준비 12단계 위저드를 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

⚠️ 매우 중요 — 화면 중복 방지 원칙:

1. 상지/하지 분기: 많은 스텝에서 상지(Upper)/하지(Lower)에 따라
   텍스트와 이미지만 바뀐다. 이런 화면들은 절대 별도 위젯으로 만들지 않고
   BodyPart 파라미터 하나로 분기 처리한다.

2. 유사 구조 스텝: 라디오 선택 등 구조가 같은 스텝들은
   공통 StepTemplate 위젯으로 재사용한다.

3. 상태 변화: 같은 스텝 내 선택 상태(_1, _2, _3)는
   단일 위젯 + selectedIndex 파라미터.

구현:
lib\screens\pre_treatment\
- pre_treatment_flow.dart — 전체 위저드 컨트롤러
- step_screens/ — 각 스텝 (가능한 한 공통 템플릿 재사용)
- 공통: StepIndicator(currentStep, totalSteps: 12) + 이전/다음 버튼

먼저 get_screenshot으로 전체 섹션을 확인하고,
상지/하지로 분기되는 화면이 어떤 것인지 파악한 후 구현해줘.
```

---

## Phase 5: Treatment 섹션

```
Figma MCP에서 Treatment 섹션 (노드 ID: 332:10150)의 디자인을 읽어서
치료 진행 화면들을 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

⚠️ 상지/하지 분기 동일 적용 — BodyPart 파라미터로 처리.

lib\screens\treatment\
- treatment_dashboard.dart — 속도/부하도 게이지/남은시간 + 궤적 프로그레스
  (GaugeMeter, TrajectoryProgressBar 등 공통 위젯 활용)
- trajectory_add_flow.dart — 궤적 추가 단계
- treatment_pause_overlay.dart — 일시정지 (isPaused 파라미터)
- treatment_quit_confirm.dart — 치료 중단 확인
- treatment_result_screen.dart — 결과 (CircularProgress 3개)
- treatment_end_flow.dart — 종료 단계
```

---

## Phase 6: Exit + Stop 섹션

```
Figma MCP에서 Exit 섹션 (노드 ID: 332:10152)과
Stop 섹션 (노드 ID: 332:10153)의 디자인을 읽어서 구현해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

lib\screens\exit\
- exit_flow.dart — 종료 확인 → 이동 중 → 완료

lib\screens\emergency\
- stop_flow.dart — 공통 StopFlow 위젯
  - StopType enum: emergency, safe
  - 비상정지/안전정지는 구조가 거의 같으므로 하나의 위젯 + type 파라미터
  - currentStep: int로 4단계 처리
  - 전역 Overlay로 어떤 화면에서든 띄울 수 있도록 구현
```

---

## Phase 7: Go-Home(Popups) + 폴리싱

```
Figma MCP에서 Go-Home 섹션 (노드 ID: 332:10151)의 디자인을 읽어서
팝업들을 구현하고 전체 앱을 폴리싱해줘.

Figma File Key: 8pB0iV0zAVNG5Sw5XcwznC

1. 홈 복귀 확인 팝업 등 (ConfirmDialog 활용)
2. 화면 전환 애니메이션 추가
3. 전체 플로우 통합 확인
4. 누락된 상태 처리 점검
```

---

## 매 Phase 완료 후

```
claude.md의 현재 진행 상태에서 Phase [N]을 완료로 표시해줘.
새로 만든 위젯이나 주의사항이 있으면 claude.md에도 추가해줘.
```

---

## 빠른 참조: 섹션 노드 ID

| Phase | 섹션 | 노드 ID |
|-------|------|---------|
| 2 | Home | 329:13651 |
| 3 | Settings | 332:10147 |
| 3 | Admin | 332:10148 |
| 4 | Pre-treatment | 332:10149 |
| 5 | Treatment | 332:10150 |
| 6 | Exit | 332:10152 |
| 6 | Stop | 332:10153 |
| 7 | Go-Home | 332:10151 |
