# 메디스비 ROBOARM GUI — Figma → Flutter 변환 작업 가이드 (v2)

> **변경 이력**: Figma 토큰 생성·Claude Code 연동 완료, Figma 섹션 단위 작업 방식 채택, claude.md 활용 반영

---

## 1. 프로젝트 분석 요약

### 디자인 개요
- **해상도**: 1280×720 (16:9, 랜드스케이프 태블릿/임베디드 디스플레이용)
- **총 화면 수**: 106개 PNG (상태 변화 포함)
- **고유 화면 (de-duplicated)**: 약 35~40개
- **언어**: 한국어 (일부 영문: MEDISBY, ROBOARM, Ready, Run 등)

### 주요 화면 그룹 (8개 플로우)

| 번호 | 그룹 | 파일 범위 | 핵심 화면 수 |
|------|------|-----------|-------------|
| 1 | **홈 (Home)** | 01_home_* | 5 |
| 2 | **설정 (Settings)** | 03~13_setting_* | 12 |
| 3 | **관리자 모드 (Admin)** | 14~24_setting_admin_* | 15 |
| 4 | **치료 준비 (Pre-treatment)** | 30~43_start_pre_* | 25 |
| 5 | **치료 진행 (Treatment)** | 44~59_start_treat_* | 18 |
| 6 | **종료 (Exit)** | 62~64_exit_* | 5 |
| 7 | **비상/안전 정지 (Emergency/Safe Stop)** | 70~85_*_stop_* | 12 |
| 8 | **기타 팝업** | 90~94 | 5 |

### 디자인 시스템 특징

**레이아웃 구조** (모든 화면 공통):
- 좌측 사이드바 (≈230px): 홈 아이콘, 메뉴 버튼 4개, 설정/종료
- 우측 메인 콘텐츠 영역 (≈1050px): 흰색 라운드 카드
- 하단 상태바: 연결 상태 + 현재 시각
- 우상단: 장비 상태 뱃지 (Ready/Run + 상태 텍스트)

**컬러 팔레트**:
- 배경: 진한 네이비 블루 (`#1A1F3D` 계열)
- 사이드바 활성 버튼: 그린 (`#2ECC71` 계열) 또는 블루 (`#4A90D9` 계열)
- 주요 액션 버튼: 그린 (다음/시작), 블루 (설정), 레드 (비상정지/경고)
- 카드/콘텐츠: 화이트 (`#FFFFFF`), 라운드 코너 ≈16px
- 텍스트: 블랙/화이트

**컴포넌트 패턴**:
- 모달 다이얼로그 (반투명 어두운 오버레이)
- 스텝 인디케이터 (도트 네비게이션, 12단계)
- 게이지/미터 (부하도 표시)
- 원형 프로그레스 (치료 결과)
- 프로그레스 바 (궤적 내 위치)
- 숫자 조절 (속도 ↑↓, 시간 ±1분/±5분)
- 탭 UI (전체 사용자 / 등록 요청)
- 카드 선택 UI (환자군 선택 등)

---

## 2. 현재 완료 상태 (전제 조건)

### ✅ 이미 완료된 작업
- **Figma 토큰 생성**: 컬러, 타이포그래피, 간격 등 디자인 토큰이 Figma에서 정의됨
- **Claude Code 연동**: Figma MCP를 통해 Claude Code에서 Figma 디자인 데이터를 직접 읽을 수 있음
- **Figma 섹션 분리**: GUI 페이지들을 Figma 내에서 섹션(Section)으로 논리적으로 구분 완료
- **claude.md 활용 검토**: 프로젝트 컨텍스트를 claude.md에 기록하여 세션 간 일관성 유지 방안 확인

### 🔑 이로 인해 달라지는 점
- 컬러/타이포/간격 값을 수동으로 하나씩 뽑을 필요 없음 → **MCP가 토큰에서 직접 읽음**
- 화면별 Inspect 정보를 스프레드시트에 기록할 필요 없음 → **MCP로 노드 데이터 직접 조회**
- PNG 이미지를 일일이 첨부하는 대신 → **Figma 섹션 노드 ID로 참조**
- 작업 단위가 파일명 기반이 아닌 → **Figma 섹션 기반**

---

## 3. Figma에서 해야 할 전처리/가공

### 3-1. 섹션 구조 확정 및 노드 ID 정리 (최우선)

Figma에서 이미 나눈 섹션들의 **노드 ID를 정리**합니다. Claude Code에서 MCP로 접근할 때 이 ID가 핵심 키입니다.

**섹션 ↔ 화면 그룹 매핑표 작성**:

| Figma 섹션 이름 | 노드 ID | 화면 수 |
|----------------|---------|--------|
| Home | 329-13651 | 5 |
| Settings | 332-10147 | 10 |
| Admin | 332-10148 | 17 |
| Pre-treatment | 332-10149 | 36 |
| Treatment | 332-10150 | 19 |
| Exit | 332-10152 | 5 |
| Stop | 332-10153 | 12 |
| Go-Home | 332-10151 | 5 |

> **Tip**: Figma에서 섹션 클릭 → URL의 `node-id=` 파라미터가 노드 ID입니다.

### 3-2. 토큰 검증 및 보완

이미 생성한 토큰이 아래 항목을 모두 포함하는지 확인:

**필수 토큰 체크리스트**:
- [ ] 배경색 (사이드바, 메인, 카드)
- [ ] 버튼 색상 (그린/블루/레드/다크 × 기본/활성/비활성)
- [ ] 텍스트 색상 (제목/본문/비활성/화이트)
- [ ] 상태 색상 (Ready 초록, Run 초록, 경고 노랑, 비상 빨강)
- [ ] 폰트 패밀리 (Pretendard 또는 Noto Sans KR)
- [ ] 폰트 사이즈 (대제목, 소제목, 본문, 버튼, 캡션 — 최소 5단계)
- [ ] 간격 (사이드바 너비, 상태바 높이, 카드 padding, 버튼 크기)
- [ ] 보더 (카드 border-radius, 버튼 border-radius)

누락된 토큰이 있으면 Figma에서 추가 정의합니다.

### 3-3. 아이콘/이미지 에셋 내보내기

MCP로 자동화할 수 없는 에셋은 여전히 수동 내보내기가 필요합니다:

**① SVG 아이콘 내보내기** (≈20~30개)
- 홈, 설정(톱니바퀴), 종료(전원), 재생, 일시정지
- 화살표 (←, →, ↑, ↓), 닫기(X), 뒤로가기
- 체크, 잠금, 사용자, 검색, 정보(i)
- 상태 인디케이터 (초록 점 등)
- 내보내기: 아이콘 레이어 선택 → Export → SVG

**② 일러스트/이미지 PNG @2x 내보내기** (≈10~15개)
- ROBOARM 장비 일러스트 (홈 화면)
- 환자군 선택 이미지 3종 (저부하/중부하/고부하)
- 치료 부위 일러스트 (어깨 등)
- 비상정지 버튼 이미지

**③ 코드로 구현할 위젯** (내보내기 불필요 — 색상/각도만 확인)
- 부하도 게이지 (반원형 미터) → CustomPainter
- 원형 프로그레스 링 (치료 결과) → CustomPainter
- 궤적 프로그레스 바 → 기본 위젯 조합

### 3-4. 섹션 내 상태 변화 화면 그룹핑

같은 레이아웃에서 상태만 바뀌는 화면들을 미리 묶어둡니다. Flutter에서 하나의 위젯 + 상태 파라미터로 처리하기 위해서입니다:

| 기본 화면 | 상태 변화 화면들 | Flutter 처리 방식 |
|----------|----------------|------------------|
| 01_home_ready | 01_home_reset_1~4 | HomeScreen(state: reset/ready) |
| 10_setting_reset_moving1 | moving2, done | ResetProgressScreen(step: 1/2/done) |
| 17_romtest_moving | moving_pause | RomTestScreen(isPaused: bool) |
| 30_start_pre_step1 | step1_1, step1_2, step1_3 | Step1Screen(selectedCard: int?) |
| 44_start_treat | 52_pause | TreatmentScreen(isPaused: bool) |
| 70~75_emergency_stop | step1~4 | EmergencyStopFlow(currentStep: int) |
| 80~85_safe_stop | step1~4 | SafeStopFlow(currentStep: int) |

---

## 4. Claude Code에서 해야 할 작업

### 4-1. claude.md 설정 (가장 먼저)

프로젝트 루트에 `claude.md`를 작성하여 Claude Code 세션마다 일관된 컨텍스트를 유지합니다:

```markdown
# 메디스비 ROBOARM GUI 프로젝트

## 프로젝트 개요
- 의료용 로봇팔(ROBOARM) 치료 장비의 터치스크린 GUI
- 해상도: 1280×720 고정 (랜드스케이프, 임베디드 디스플레이)
- Flutter 프레임워크, 타겟: Linux + Android

## Figma 연동
- Figma MCP 연동 완료 — 디자인 토큰 및 노드 데이터 직접 조회 가능
- 섹션 노드 ID: [여기에 3-1에서 정리한 매핑표 삽입]

## 디자인 규칙
- 모든 화면: 좌측 사이드바(230px) + 우측 메인 콘텐츠 + 하단 상태바
- 공통 위젯: AppScaffold, SidebarMenu, StatusBar, DeviceStatusBadge 등
- 컬러: Figma 토큰 참조 (네이비 배경, 그린/블루/레드 버튼, 화이트 카드)
- 모달: 반투명 어두운 오버레이 + 중앙 카드

## 코드 컨벤션
- 상태 관리: Provider (또는 Riverpod)
- 라우팅: go_router
- 폴더 구조: lib/theme/, lib/widgets/, lib/screens/, lib/models/

## 현재 진행 상태
- [ ] Phase 0: 프로젝트 초기화 + 디자인 시스템
- [ ] Phase 1: 공통 위젯 구현
- [ ] Phase 2: Home 섹션
- [ ] Phase 3: Settings 섹션
- [ ] Phase 4: Admin 섹션
- [ ] Phase 5: Pre-treatment 섹션
- [ ] Phase 6: Treatment 섹션
- [ ] Phase 7: Exit + Emergency/Safe Stop 섹션
- [ ] Phase 8: Popups + 폴리싱
```

> **중요**: 각 Phase 완료 시 claude.md의 체크리스트를 업데이트하여 다음 세션에서 진행 상황을 즉시 파악할 수 있게 합니다.

### 4-2. Flutter 프로젝트 초기 설정

```bash
# 프로젝트 생성
flutter create medisby_roboarm --platforms=linux,android
cd medisby_roboarm

# 필수 패키지 추가
flutter pub add flutter_svg        # SVG 아이콘 렌더링
flutter pub add google_fonts       # 또는 커스텀 폰트
flutter pub add provider           # 상태 관리 (또는 riverpod)
flutter pub add go_router          # 라우팅
```

> **참고**: `flutter_screenutil`은 제외합니다. 1280×720 고정 해상도 임베디드 디스플레이이므로 고정 레이아웃이 더 적합합니다.

**폴더 구조**:
```
lib/
├── main.dart
├── theme/
│   ├── colors.dart          # Figma 토큰 기반 자동 생성
│   ├── text_styles.dart     # Figma 토큰 기반 자동 생성
│   └── dimensions.dart      # Figma 토큰 기반 자동 생성
├── widgets/                 # 공통 위젯
│   ├── app_scaffold.dart
│   ├── sidebar_menu.dart
│   ├── status_bar.dart
│   ├── device_status_badge.dart
│   ├── app_button.dart
│   ├── modal_overlay.dart
│   ├── confirm_dialog.dart
│   ├── step_indicator.dart
│   ├── content_card.dart
│   ├── gauge_meter.dart
│   ├── circular_progress.dart
│   └── trajectory_progress_bar.dart
├── screens/                 # 섹션별 화면
│   ├── home/
│   ├── settings/
│   ├── admin/
│   ├── pre_treatment/
│   ├── treatment/
│   ├── exit/
│   └── emergency/
├── models/                  # 데이터 모델
└── providers/               # 상태 관리
assets/
├── icons/                   # SVG 아이콘
└── images/                  # PNG 일러스트
```

### 4-3. 디자인 시스템 코드화 (MCP + 토큰 기반)

기존 가이드에서는 수동으로 값을 옮겨 적었지만, 이제는 **Claude Code가 MCP를 통해 Figma 토큰을 읽어서 자동 생성**합니다.

**Claude Code 프롬프트 예시**:
```
Figma MCP를 통해 디자인 토큰을 읽어서 다음 파일들을 생성해줘:
1. lib/theme/colors.dart — 모든 컬러 토큰을 AppColors 클래스의 static const로
2. lib/theme/text_styles.dart — 타이포그래피 토큰을 AppTextStyles 클래스로
3. lib/theme/dimensions.dart — 간격/크기 토큰을 AppDimensions 클래스로

1280×720 고정 해상도 기준이야.
```

결과물 예시 (MCP가 읽어온 토큰값이 자동 반영됨):
```dart
// lib/theme/colors.dart — Figma 토큰 기반 자동 생성
class AppColors {
  static const background = Color(0xFF1A1F3D);
  static const sidebarBg = Color(0xFF1E2448);
  static const cardBg = Color(0xFFFFFFFF);
  static const primaryGreen = Color(0xFF2ECC71);
  static const primaryBlue = Color(0xFF4A90D9);
  static const dangerRed = Color(0xFFE74C3C);
  // ... Figma 토큰에서 읽어온 값들
}
```

### 4-4. 공통 위젯 구현 (Phase 1 — 화면 구현 전 필수)

**이 단계는 섹션 단위 작업 이전에 반드시 완료해야 합니다.** 공통 위젯 없이 섹션별 화면 구현에 들어가면 중복 코드가 발생합니다.

| 순서 | 위젯 | 용도 | 복잡도 | MCP 활용 |
|------|------|------|--------|---------|
| 1 | `AppScaffold` | 사이드바 + 메인 + 상태바 레이아웃 | ★★ | 레이아웃 수치 조회 |
| 2 | `SidebarMenu` | 좌측 네비게이션 | ★★ | 아이콘/색상 조회 |
| 3 | `StatusBar` | 하단 연결상태 + 시각 표시 | ★ | 높이/색상 조회 |
| 4 | `DeviceStatusBadge` | 우상단 Ready/Run 뱃지 | ★ | 뱃지 스타일 조회 |
| 5 | `AppButton` | 그린/블루/레드/다크 버튼 (variant) | ★★ | 버튼 토큰 조회 |
| 6 | `ModalOverlay` | 반투명 배경 모달 컨테이너 | ★★ | 오버레이 스타일 조회 |
| 7 | `ConfirmDialog` | 예/아니오 확인 팝업 | ★ | 다이얼로그 스타일 조회 |
| 8 | `StepIndicator` | 도트 네비게이션 (12단계) | ★★ | 인디케이터 스타일 조회 |
| 9 | `ContentCard` | 흰색 라운드 카드 | ★ | 카드 토큰 조회 |
| 10 | `GaugeMeter` | 반원형 부하도 미터 | ★★★ | 색상/각도 조회 |
| 11 | `CircularProgress` | 원형 프로그레스 링 | ★★★ | 색상/크기 조회 |
| 12 | `TrajectoryProgressBar` | 궤적 위치 프로그레스 바 | ★★ | 색상/크기 조회 |

**Claude Code 프롬프트 예시 (공통 위젯)**:
```
Figma MCP에서 [Home 섹션 노드 ID]를 참조해서 
AppScaffold 위젯을 구현해줘.
- 좌측 사이드바(230px) + 우측 메인 콘텐츠 + 하단 상태바 구조
- 디자인 토큰은 이미 생성된 AppColors, AppDimensions 사용
- 1280×720 고정 레이아웃
```

---

## 5. 섹션별 화면 구현 (Phase 2~8)

### 핵심 원칙: 하이브리드 방식

```
공통 위젯은 "기존 가이드의 순서"로 먼저 만들고,
화면 구현은 "Figma 섹션 단위"로 진행한다.
```

### 섹션별 구현 순서 및 상세

각 섹션 작업 시 Claude Code에서 **Figma MCP로 해당 섹션 노드를 참조**하여 구현합니다.

#### Phase 2: Home 섹션 (0.5일)

**Figma 참조**: Home 섹션 노드 ID
**포함 화면**: 01_home_ready, 01_home_reset_1~4

```
작업 내용:
├── HomeScreen — ROBOARM 일러스트 + 준비 완료 메시지
├── HomeResetFlow — reset 진행 상태 (1~4단계)
└── 상태: ready / resetting(step1~4)
```

**Claude Code 프롬프트**:
```
Figma MCP에서 Home 섹션 [노드 ID]의 디자인을 읽어서
HomeScreen을 구현해줘. AppScaffold 위젯을 활용하고,
01_home_ready 화면과 01_home_reset_1~4 상태 변화를
하나의 위젯에서 state 파라미터로 처리해줘.
```

#### Phase 3: Settings 섹션 (1일)

**Figma 참조**: Settings 섹션 노드 ID
**포함 화면**: 03~13_setting_*

```
작업 내용:
├── SettingsModal — 설정 메뉴 (초기화/관리자/시스템정보)
├── ResetConfirmDialog — 초기화 확인 팝업
├── ResetProgressScreen — 초기화 진행 (moving1~2, done)
├── SystemInfoScreen — 시스템 정보 표시
├── AdminAccessScreen — 비밀번호 입력
└── AdminMenuScreen — 관리자 메뉴
```

#### Phase 4: Admin 섹션 (2일)

**Figma 참조**: Admin 섹션 노드 ID
**포함 화면**: 14~24_setting_admin_*

```
작업 내용:
├── UserManagementScreen — 탭 UI (전체 사용자 / 등록 요청)
├── RomTestFlow — ROM 테스트 4단계
│   ├── 관절 선택 → 이동 중(+일시정지) → 준비 → 실행(+일시정지)
└── VelTestFlow — 속도 테스트 4단계
    ├── 관절 선택 → 속도 선택 → 이동 중(+일시정지) → 실행(+over)
```

#### Phase 5: Pre-treatment 섹션 (2~3일) — 가장 화면 수 많음

**Figma 참조**: Pre-treatment 섹션 노드 ID
**포함 화면**: 30~43_start_pre_*

```
작업 내용:
├── Step1 — 환자군 선택 카드 (저부하/중부하/고부하)
├── Step2 ~ Step14 — 12단계 위저드
│   각 스텝은 StepIndicator(currentStep, totalSteps: 12) 활용
│   같은 스텝 내 선택 상태(_1, _2, _3)는 단일 위젯 + 상태 파라미터
└── 공통: 이전/다음 네비게이션 버튼
```

> **효율화 포인트**: Step3~4는 구조가 동일 (라디오 선택), Step6도 유사 → 재사용 가능한 StepTemplate 위젯 고려

#### Phase 6: Treatment 섹션 (2~3일) — 가장 복잡한 위젯

**Figma 참조**: Treatment 섹션 노드 ID
**포함 화면**: 44~59_start_treat_*

```
작업 내용:
├── TreatmentDashboard — 속도/부하도 게이지/남은시간 + 궤적 프로그레스
│   ├── GaugeMeter (CustomPainter)
│   ├── 속도 조절 (↑↓)
│   ├── 시간 조절 (±1분/±5분)
│   └── TrajectoryProgressBar
├── TrajectoryAddFlow — 궤적 추가 6단계 (45~50)
├── TreatmentPauseOverlay — 일시정지 상태
├── TreatmentQuitConfirm — 치료 중단 확인
├── TreatmentSeparateScreens — 개별 화면 (54~55)
├── TreatmentResultScreen — 결과 (원형 프로그레스 3개)
└── TreatmentEndFlow — 종료 3단계 (57~59)
```

#### Phase 7: Exit + Emergency/Safe Stop 섹션 (1~2일)

**Figma 참조**: Exit 섹션 + Emergency/Safe Stop 섹션 노드 ID
**포함 화면**: 62~64, 70~85

```
작업 내용:
├── ExitFlow — 종료 확인 → 이동 중 → 완료
├── EmergencyStopFlow — 비상정지 4단계
│   (원인 확인 → 리셋1 → 리셋2 → 완료)
└── SafeStopFlow — 안전정지 4단계
    (동일 구조, 다른 안내 텍스트/색상)
```

> EmergencyStopFlow와 SafeStopFlow는 구조가 거의 같으므로 **공통 StopFlow 위젯 + 타입 파라미터**로 처리

#### Phase 8: Popups + 폴리싱 (1일)

**Figma 참조**: Popups 섹션 노드 ID
**포함 화면**: 90~94

```
작업 내용:
├── HomeReturnConfirm — "홈 화면으로 돌아가시겠습니까?"
├── 기타 확인 팝업들 (91~94)
├── 화면 전환 애니메이션 추가
└── 전체 플로우 통합 테스트
```

---

## 6. 권장 작업 순서 총정리

### Phase 0: 환경 준비 (0.5일)
1. ~~Figma 컬러/타이포/간격 수동 추출~~ → **완료 (토큰 + MCP 연동)**
2. claude.md 작성 (섹션 노드 ID 매핑표 포함)
3. Flutter 프로젝트 생성 + 패키지 설치
4. 에셋 내보내기 (SVG 아이콘 + PNG 일러스트만)
5. 에셋 파일 배치 + pubspec.yaml 등록

### Phase 1: 디자인 시스템 + 공통 위젯 (2일)
1. MCP로 토큰 읽어서 colors.dart, text_styles.dart, dimensions.dart 자동 생성
2. AppScaffold + SidebarMenu + StatusBar (뼈대)
3. AppButton, ContentCard, ModalOverlay, ConfirmDialog (기본 컴포넌트)
4. GaugeMeter, CircularProgress (커스텀 위젯)
5. StepIndicator, TrajectoryProgressBar (플로우 위젯)
6. go_router 라우팅 설정

### Phase 2~8: 섹션별 화면 구현 (8~10일)

| Phase | 섹션 | 소요 | 핵심 포인트 |
|-------|------|------|-----------|
| 2 | Home | 0.5일 | 첫 화면, AppScaffold 검증 |
| 3 | Settings | 1일 | 모달 패턴 확립 |
| 4 | Admin | 2일 | 탭 UI, 테스트 플로우 |
| 5 | Pre-treatment | 2~3일 | 12단계 위저드, 가장 많은 화면 |
| 6 | Treatment | 2~3일 | 게이지/프로그레스, 가장 복잡 |
| 7 | Exit + Stop | 1~2일 | 공통 StopFlow 패턴 |
| 8 | Popups + 폴리싱 | 1일 | 최종 통합 |

### Phase 9: 상태 관리 & 통합 (2일)
1. 장비 상태 (Ready/Run/Stop) 전역 상태
2. 치료 세션 데이터 모델
3. 화면 간 전환 로직 통합
4. 비상정지 인터럽트 처리 (어떤 화면에서든 발생 가능)

**총 예상 소요: 약 13~16일**

---

## 7. Claude Code 활용 팁

### 섹션 기반 프롬프트 템플릿

```
Figma MCP에서 [섹션이름] 섹션 (노드 ID: [노드ID])의 디자인을 읽어서
[화면이름]을 Flutter 위젯으로 구현해줘.

조건:
- 1280×720 고정 해상도
- AppScaffold, SidebarMenu 등 기존 공통 위젯 활용
- 디자인 토큰: AppColors, AppTextStyles, AppDimensions 참조
- [해당 화면의 상태 변화 설명]
```

### claude.md 업데이트 습관

각 Phase 완료 시:
1. claude.md의 진행 상태 체크리스트 업데이트
2. 새로 만든 공통 위젯이 있으면 목록에 추가
3. 다음 Phase에서 주의할 점 메모 (예: "Treatment 섹션의 게이지는 GaugeMeter 위젯 사용")

### MCP 조회가 안 될 때 대비

Figma 무료 플랜 제한으로 MCP 응답이 불완전할 경우:
- **1차**: 해당 섹션의 PNG 파일을 직접 참고 이미지로 첨부
- **2차**: Figma에서 해당 요소를 클릭하여 수동으로 값 확인 후 전달
- PNG 파일은 이미 전체 내보내기 완료 상태이므로 백업 참조용으로 항상 사용 가능

### 주의사항

1. **1280×720 고정 해상도**: flutter_screenutil 미사용, 고정 레이아웃
2. **한글 폰트**: Pretendard 또는 Noto Sans KR 폰트 파일을 프로젝트에 직접 포함
3. **CustomPainter**: 게이지, 원형 프로그레스 등은 이미지가 아닌 코드로 구현
4. **상태 변화 화면**: 같은 레이아웃의 상태 변화는 하나의 위젯 + 상태 파라미터로 처리
5. **모달/팝업**: showDialog 패턴 사용, 별도 라우트 불필요
6. **비상정지**: 어떤 화면에서든 발생 가능 → 전역 상태로 관리, Overlay 패턴 권장
