# 메디스비 ROBOARM GUI 프로젝트

## 프로젝트 개요
- 의료용 로봇팔(ROBOARM) 치료 장비의 터치스크린 GUI
- 해상도: 1280×720 고정 (랜드스케이프, 임베디드 디스플레이)
- Flutter 프레임워크, 타겟: Linux + Android
- flutter_screenutil 미사용 — 고정 해상도이므로 고정 레이아웃

## Figma 연동
- Figma File Key: `8pB0iV0zAVNG5Sw5XcwznC`
- Figma MCP 연동 완료 — 디자인 토큰 및 노드 데이터 직접 조회 가능
- MCP 도구: get_design_context, get_screenshot, get_variable_defs, get_metadata 활용

### 섹션 노드 ID 매핑표

| 섹션 | 노드 ID | 화면 수 | 설명 |
|------|---------|--------|------|
| Home | 329:13651 | 5 | 홈 화면 + 리셋 플로우 |
| Settings | 332:10147 | 10 | 설정 메뉴, 초기화, 시스템 정보 |
| Admin | 332:10148 | 17 | 사용자 관리, ROM/속도 테스트 |
| Pre-treatment | 332:10149 | 36 | 치료 준비 12단계 위저드 |
| Treatment | 332:10150 | 19 | 치료 진행 대시보드, 궤적, 결과 |
| Exit | 332:10152 | 5 | 종료 플로우 |
| Stop | 332:10153 | 12 | 비상정지 + 안전정지 |
| Go-Home | 332:10151 | 5 | 홈 복귀 확인 팝업 등 |

## 디자인 규칙

### 레이아웃 (모든 화면 공통)
- 좌측 사이드바: 약 230px, 홈 아이콘 + 메뉴 버튼 4개 + 설정/종료
- 우측 메인 콘텐츠: 약 1050px, 흰색 라운드 카드 (border-radius ≈16px)
- 하단 상태바: 연결 상태 + 현재 시각
- 우상단: 장비 상태 뱃지 (Ready/Run + 상태 텍스트)

### 컬러 (Figma 토큰 참조, 코드에서 추후 보정 가능)
- 배경: 진한 네이비 블루 (#1A1F3D 계열)
- 사이드바 활성: 그린(#2ECC71) 또는 블루(#4A90D9)
- 주요 액션 버튼: 그린(다음/시작), 블루(설정), 레드(비상정지/경고)
- 카드/콘텐츠: 화이트(#FFFFFF), 라운드 코너 ≈16px
- 모달: 반투명 어두운 오버레이 + 중앙 카드

### 컴포넌트 패턴
- 모달 다이얼로그 (showDialog 패턴, 별도 라우트 불필요)
- 스텝 인디케이터 (도트 네비게이션, 최대 12단계)
- 게이지/미터 (반원형 부하도 → CustomPainter)
- 원형 프로그레스 (치료 결과 → CustomPainter)
- 프로그레스 바 (궤적 내 위치)
- 숫자 조절 (속도 ↑↓, 시간 ±1분/±5분)
- 탭 UI, 카드 선택 UI

### 상태 변화 화면 그룹핑
같은 레이아웃에서 상태만 바뀌는 화면 → 하나의 위젯 + 상태 파라미터로 처리:
- HomeScreen(state: ready/resetting) ← 01_home_ready, 01_home_reset_1~4
- ResetProgressScreen(step: 1/2/done) ← 10_setting_reset_moving1~done
- RomTestScreen(isPaused: bool) ← 17_romtest_moving, moving_pause
- Step1Screen(selectedCard: int?) ← 30_start_pre_step1, step1_1~3
- TreatmentScreen(isPaused: bool) ← 44_start_treat, 52_pause
- EmergencyStopFlow(currentStep: int) ← 70~75
- SafeStopFlow(currentStep: int) ← 80~85

## 코드 컨벤션
- 상태 관리: Provider
- 라우팅: go_router
- 한글 폰트: Pretendard (프로젝트 직접 포함)
- CustomPainter: 게이지, 원형 프로그레스 등은 이미지 아닌 코드 구현
- 비상정지: 어떤 화면에서든 발생 가능 → 전역 상태, Overlay 패턴

### 폴더 구조
```
lib/
├── main.dart
├── theme/          → colors.dart, text_styles.dart, dimensions.dart
├── widgets/        → 공통 위젯 (AppScaffold, SidebarMenu, StatusBar 등)
├── screens/        → home/, settings/, admin/, pre_treatment/, treatment/, exit/, emergency/
├── models/         → 데이터 모델
└── providers/      → 상태 관리
assets/
├── icons/          → SVG 아이콘
└── images/         → PNG 일러스트
```

### 공통 위젯 목록
- AppScaffold: 사이드바 + 메인 + 상태바 레이아웃
- SidebarMenu: 좌측 네비게이션
- StatusBar: 하단 연결상태 + 시각
- DeviceStatusBadge: 우상단 Ready/Run 뱃지
- AppButton: 그린/블루/레드/다크 버튼 (variant)
- ModalOverlay: 반투명 배경 모달 컨테이너
- ConfirmDialog: 예/아니오 확인 팝업
- StepIndicator: 도트 네비게이션 (12단계)
- ContentCard: 흰색 라운드 카드
- GaugeMeter: 반원형 부하도 미터 (CustomPainter)
- CircularProgress: 원형 프로그레스 링 (CustomPainter)
- TrajectoryProgressBar: 궤적 위치 프로그레스 바

## 현재 진행 상태
- [ ] Phase 0: 프로젝트 초기화 + 디자인 시스템
- [ ] Phase 1: 공통 위젯 구현
- [ ] Phase 2: Home 섹션
- [ ] Phase 3: Settings 섹션
- [ ] Phase 4: Admin 섹션
- [ ] Phase 5: Pre-treatment 섹션
- [ ] Phase 6: Treatment 섹션
- [ ] Phase 7: Exit + Stop 섹션
- [ ] Phase 8: Go-Home(Popups) + 폴리싱
- [ ] Phase 9: 상태 관리 & 통합
