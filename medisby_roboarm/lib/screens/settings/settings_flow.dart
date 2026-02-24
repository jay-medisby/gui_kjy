import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/dimensions.dart';
import '../../widgets/settings_modal_base.dart';
import '../../widgets/app_button.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/warning_box.dart';
import '../../widgets/joint_selector.dart';

/// Settings 모달 내부 페이지
enum _SettingsPage {
  menu,
  resetConfirm,
  resetDetach,
  resetMoving,
  resetDone,
  systemInfo,
  adminAccess,
  adminMenu,
  userManagement,
  romTestJoint,
  romTestMoving,
  romTestReady,
  romTestRunning,
  velTestJoint,
  velTestVel,
  velTestMoving,
  velTestRunning,
  velTestDone,
}

/// Settings + Admin 모달 플로우
/// 사이드바 "설정" 탭에서 SettingsFlow.show(context) 호출
class SettingsFlow extends StatefulWidget {
  const SettingsFlow({super.key});

  /// 모달로 열기
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => const SettingsFlow(),
    );
  }

  @override
  State<SettingsFlow> createState() => _SettingsFlowState();
}

class _SettingsFlowState extends State<SettingsFlow> {
  _SettingsPage _currentPage = _SettingsPage.menu;
  final List<_SettingsPage> _history = [];

  // ── 공유 상태 ──
  int? _selectedJoint;
  int _selectedVelocity = 5;
  bool _isMoving = false;
  bool _isPaused = false;
  String _passwordInput = '';
  bool _passwordError = false;
  final double _currentAngle = -125.0;

  // ── 사용자 관리 상태 ──
  int _userTabIndex = 0; // 0: 전체 사용자, 1: 등록 요청
  String _searchQuery = '';

  // ── 네비게이션 ──

  void _navigateTo(_SettingsPage page) {
    setState(() {
      _history.add(_currentPage);
      _currentPage = page;
    });
  }

  void _goBack() {
    if (_history.isEmpty) {
      _close();
      return;
    }
    setState(() {
      _currentPage = _history.removeLast();
      // 상태 리셋
      _isMoving = false;
      _isPaused = false;
    });
  }

  void _close() {
    Navigator.of(context).pop();
  }

  /// 관리자 메뉴로 바로 이동 (브레드크럼 탭)
  void _goToAdminMenu() {
    setState(() {
      _history.removeWhere((p) => _isAdminSubPage(p));
      if (_history.isEmpty || _history.last != _SettingsPage.adminMenu) {
        // adminMenu가 히스토리에 있으면 거기까지 pop
        while (_history.isNotEmpty && _history.last != _SettingsPage.adminMenu) {
          _history.removeLast();
        }
      }
      _currentPage = _SettingsPage.adminMenu;
      _selectedJoint = null;
      _isMoving = false;
      _isPaused = false;
    });
  }

  bool _isAdminSubPage(_SettingsPage page) {
    return page == _SettingsPage.userManagement ||
        page == _SettingsPage.romTestJoint ||
        page == _SettingsPage.romTestMoving ||
        page == _SettingsPage.romTestReady ||
        page == _SettingsPage.romTestRunning ||
        page == _SettingsPage.velTestJoint ||
        page == _SettingsPage.velTestVel ||
        page == _SettingsPage.velTestMoving ||
        page == _SettingsPage.velTestRunning ||
        page == _SettingsPage.velTestDone;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_currentPage) {
      _SettingsPage.menu => _buildMenu(),
      _SettingsPage.resetConfirm => _buildResetConfirm(),
      _SettingsPage.resetDetach => _buildResetDetach(),
      _SettingsPage.resetMoving => _buildResetMoving(),
      _SettingsPage.resetDone => _buildResetDone(),
      _SettingsPage.systemInfo => _buildSystemInfo(),
      _SettingsPage.adminAccess => _buildAdminAccess(),
      _SettingsPage.adminMenu => _buildAdminMenu(),
      _SettingsPage.userManagement => _buildUserManagement(),
      _SettingsPage.romTestJoint => _buildRomTestJoint(),
      _SettingsPage.romTestMoving => _buildRomTestMoving(),
      _SettingsPage.romTestReady => _buildRomTestReady(),
      _SettingsPage.romTestRunning => _buildRomTestRunning(),
      _SettingsPage.velTestJoint => _buildVelTestJoint(),
      _SettingsPage.velTestVel => _buildVelTestVel(),
      _SettingsPage.velTestMoving => _buildVelTestMoving(),
      _SettingsPage.velTestRunning => _buildVelTestRunning(),
      _SettingsPage.velTestDone => _buildVelTestDone(),
    };
  }

  // ═══════════════════════════════════════════════════
  // Step 4: 설정 메인 메뉴
  // ═══════════════════════════════════════════════════

  Widget _buildMenu() {
    return SettingsModalBase(
      title: '설정',
      showBack: false,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _settingsMenuItem(
            icon: Icons.restart_alt,
            label: '장비 초기화',
            buttonLabel: 'RESET',
            onPressed: () => _navigateTo(_SettingsPage.resetConfirm),
          ),
          const SizedBox(height: 16),
          _settingsMenuItem(
            icon: Icons.lock_outline,
            label: '관리자 모드',
            buttonLabel: '관리자 모드',
            onPressed: () => _navigateTo(_SettingsPage.adminAccess),
          ),
          const SizedBox(height: 16),
          _settingsMenuItem(
            icon: Icons.info_outline,
            label: '시스템 정보',
            buttonLabel: '시스템 정보',
            onPressed: () => _navigateTo(_SettingsPage.systemInfo),
          ),
        ],
      ),
    );
  }

  Widget _settingsMenuItem({
    required IconData icon,
    required String label,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: AppDimensions.settingsRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textBlack, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textBlack,
              ),
            ),
          ),
          AppButton(
            label: buttonLabel,
            variant: ButtonVariant.blue,
            size: ButtonSize.small,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Step 5: 장비 초기화 플로우
  // ═══════════════════════════════════════════════════

  /// resetConfirm — "장비를 초기화하시겠습니까?"
  Widget _buildResetConfirm() {
    return SettingsModalBase(
      title: '설정',
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '장비를 초기화하시겠습니까?',
            style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '장비를 초기화하면 장비의 암이 홈 위치로 이동합니다.',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _whiteRoundButton('아니오', onPressed: _goBack),
              const SizedBox(width: 24),
              _whiteRoundButton('예', onPressed: () => _navigateTo(_SettingsPage.resetDetach)),
            ],
          ),
        ],
      ),
    );
  }

  /// 흰색 라운드 버튼 (resetConfirm의 아니오/예)
  Widget _whiteRoundButton(String label, {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 218,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(35),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  /// resetDetach — "구동장착부를 탈착한 후 '확인' 버튼을 눌러주세요."
  Widget _buildResetDetach() {
    return SettingsModalBase(
      title: '장비 초기화',
      showBack: false,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "구동장착부를 탈착한 후 '확인' 버튼을 눌러주세요.",
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppButton(
            label: '확인',
            variant: ButtonVariant.green,
            size: ButtonSize.medium,
            onPressed: () => _navigateTo(_SettingsPage.resetMoving),
          ),
        ],
      ),
    );
  }

  /// resetMoving — 롱프레스 이동
  Widget _buildResetMoving() {
    return SettingsModalBase(
      title: '장비 초기화',
      showBack: false,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '버튼을 누른 상태를 유지하여 암을\n홈 위치로 이동시켜 주세요.',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const WarningBox(boxed: true),
          const SizedBox(height: 20),
          LongPressMoveButton(
            isMoving: _isMoving,
            onLongPress: () {
              setState(() => _isMoving = true);
              _simulateResetMovement();
            },
          ),
        ],
      ),
    );
  }

  void _simulateResetMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _navigateTo(_SettingsPage.resetDone);
      setState(() => _isMoving = false);
    });
  }

  /// resetDone — 이동 완료
  Widget _buildResetDone() {
    return SettingsModalBase(
      title: '장비 초기화',
      showBack: false,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.green,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            '장비의 암 이동 완료',
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '장비의 암이 홈 위치로 이동했습니다.\n정상적으로 사용을 재개할 수 있습니다.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          AppButton(
            label: '확인',
            variant: ButtonVariant.green,
            size: ButtonSize.medium,
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Step 6: 시스템 정보
  // ═══════════════════════════════════════════════════

  Widget _buildSystemInfo() {
    return SettingsModalBase(
      title: '시스템 정보',
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _infoRow('제품명', 'MDB-RA1D'),
          _divider(),
          _infoRow('시리얼 번호', '1234567890'),
          _divider(),
          _infoRow('소프트웨어 버전', 'v1.0.0'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge,
          ),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: AppColors.settingsCardBorder,
      height: 1,
      thickness: 1,
    );
  }

  // ═══════════════════════════════════════════════════
  // Step 7: 관리자 인증
  // ═══════════════════════════════════════════════════

  Widget _buildAdminAccess() {
    const correctPassword = '12345';

    return SettingsModalBase(
      title: '관리자 인증',
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // 안내 텍스트 or 오류 텍스트
          if (_passwordError)
            Text(
              '비밀번호 오류',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.red,
              ),
            )
          else
            Text(
              '관리자 비밀번호를 입력하세요',
              style: AppTextStyles.titleMedium,
            ),
          const SizedBox(height: 16),
          // 비밀번호 dot 표시
          Container(
            width: 400,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              List.generate(
                _passwordInput.length,
                (_) => '\u25CF',
              ).join('  '),
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textBlack,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 숫자 키패드
          _buildNumpad(() {
            if (_passwordInput == correctPassword) {
              setState(() {
                _passwordError = false;
                _passwordInput = '';
              });
              _navigateTo(_SettingsPage.adminMenu);
            } else {
              setState(() {
                _passwordError = true;
                _passwordInput = '';
              });
            }
          }),
        ],
      ),
    );
  }

  Widget _buildNumpad(VoidCallback onConfirm) {
    Widget numButton(String label, {Color? bgColor, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.cardWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: label == '⌫'
              ? Icon(Icons.backspace_outlined, color: AppColors.textBlack, size: 24)
              : Text(
                  label,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: bgColor == AppColors.orange
                        ? AppColors.textWhite
                        : AppColors.textBlack,
                  ),
                ),
        ),
      );
    }

    return Column(
      children: [
        // Row 1: 1 2 3
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            numButton('1', onTap: () => _onNumpadTap('1')),
            const SizedBox(width: 10),
            numButton('2', onTap: () => _onNumpadTap('2')),
            const SizedBox(width: 10),
            numButton('3', onTap: () => _onNumpadTap('3')),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: 4 5 6
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            numButton('4', onTap: () => _onNumpadTap('4')),
            const SizedBox(width: 10),
            numButton('5', onTap: () => _onNumpadTap('5')),
            const SizedBox(width: 10),
            numButton('6', onTap: () => _onNumpadTap('6')),
          ],
        ),
        const SizedBox(height: 10),
        // Row 3: 7 8 9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            numButton('7', onTap: () => _onNumpadTap('7')),
            const SizedBox(width: 10),
            numButton('8', onTap: () => _onNumpadTap('8')),
            const SizedBox(width: 10),
            numButton('9', onTap: () => _onNumpadTap('9')),
          ],
        ),
        const SizedBox(height: 10),
        // Row 4: ⌫ 0 확인
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            numButton('⌫', onTap: _onNumpadBackspace),
            const SizedBox(width: 10),
            numButton('0', onTap: () => _onNumpadTap('0')),
            const SizedBox(width: 10),
            numButton('확인', bgColor: AppColors.orange, onTap: onConfirm),
          ],
        ),
      ],
    );
  }

  void _onNumpadTap(String digit) {
    if (_passwordInput.length >= 5) return;
    setState(() {
      _passwordInput += digit;
      _passwordError = false;
    });
  }

  void _onNumpadBackspace() {
    if (_passwordInput.isEmpty) return;
    setState(() {
      _passwordInput = _passwordInput.substring(0, _passwordInput.length - 1);
      _passwordError = false;
    });
  }

  // ═══════════════════════════════════════════════════
  // Step 8: 관리자 모드 메인
  // ═══════════════════════════════════════════════════

  Widget _buildAdminMenu() {
    return SettingsModalBase(
      title: '관리자 모드',
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _adminMenuButton('사용자 관리', () => _navigateTo(_SettingsPage.userManagement)),
          const SizedBox(height: 16),
          _adminMenuButton('가동범위 테스트', () => _navigateTo(_SettingsPage.romTestJoint)),
          const SizedBox(height: 16),
          _adminMenuButton('속도 테스트', () => _navigateTo(_SettingsPage.velTestJoint)),
        ],
      ),
    );
  }

  Widget _adminMenuButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 320,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Step 10: ROM 테스트 플로우
  // ═══════════════════════════════════════════════════

  List<BreadcrumbItem> _romBreadcrumb() => [
        BreadcrumbItem(label: '관리자 모드', onTap: _goToAdminMenu),
        BreadcrumbItem(label: '가동범위 테스트', isCurrent: true),
      ];

  Widget _buildRomTestJoint() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _romBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: JointSelector(
        selectedJoint: _selectedJoint,
        onJointSelected: (j) => setState(() => _selectedJoint = j),
        onConfirm: _selectedJoint != null
            ? () {
                setState(() {
                  _isMoving = false;
                  _isPaused = false;
                });
                _navigateTo(_SettingsPage.romTestMoving);
                _simulateTestMovement(_SettingsPage.romTestReady);
              }
            : null,
      ),
    );
  }

  Widget _buildRomTestMoving() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _romBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointLabel(),
          const SizedBox(height: 12),
          Text(
            '장비의 암이 테스트 자세로 이동중입니다',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _pauseButton(),
        ],
      ),
    );
  }

  Widget _buildRomTestReady() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _romBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointLabel(),
          const SizedBox(height: 12),
          Text(
            '관절의 위치값을 눌러 움직여주세요',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // -360° | 현재 각도 | +360°
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _angleButton('-360°', AppColors.orange, () {
                _navigateTo(_SettingsPage.romTestRunning);
              }),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    '현재 각도',
                    style: AppTextStyles.captionLight.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    '${_currentAngle.toStringAsFixed(1)}°',
                    style: AppTextStyles.headingLarge,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              _angleButton('+360°', AppColors.cardWhite, () {
                _navigateTo(_SettingsPage.romTestRunning);
              }),
            ],
          ),
          const SizedBox(height: 40),
          _bottomActionRow(
            showSelectJoint: true,
            onSelectJoint: () {
              setState(() => _selectedJoint = null);
              // Go back to joint selection
              setState(() {
                _currentPage = _SettingsPage.romTestJoint;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRomTestRunning() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _romBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointLabel(),
          const SizedBox(height: 12),
          Text(
            '관절의 위치값을 눌러 움직여주세요',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _angleButton('-360°', AppColors.orange, null),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    '현재 각도',
                    style: AppTextStyles.captionLight.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    '-125°',
                    style: AppTextStyles.headingLarge,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              _angleButton('+360°', AppColors.cardWhite, null),
            ],
          ),
          const SizedBox(height: 40),
          _bottomActionRow(
            showSelectJoint: true,
            onSelectJoint: () {
              setState(() => _selectedJoint = null);
              setState(() {
                _currentPage = _SettingsPage.romTestJoint;
              });
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Step 11: 속도 테스트 플로우
  // ═══════════════════════════════════════════════════

  List<BreadcrumbItem> _velBreadcrumb() => [
        BreadcrumbItem(label: '관리자 모드', onTap: _goToAdminMenu),
        BreadcrumbItem(label: '속도 테스트', isCurrent: true),
      ];

  Widget _buildVelTestJoint() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _velBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: JointSelector(
        selectedJoint: _selectedJoint,
        onJointSelected: (j) => setState(() => _selectedJoint = j),
        onConfirm: _selectedJoint != null
            ? () => _navigateTo(_SettingsPage.velTestVel)
            : null,
      ),
    );
  }

  Widget _buildVelTestVel() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _velBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointLabel(),
          const SizedBox(height: 12),
          Text(
            '테스트할 속도를 선택해 주세요',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // < 5 > 숫자 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _velocityArrowButton(Icons.chevron_left, () {
                if (_selectedVelocity > 1) {
                  setState(() => _selectedVelocity--);
                }
              }),
              const SizedBox(width: 16),
              Text(
                '$_selectedVelocity',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(width: 16),
              _velocityArrowButton(Icons.chevron_right, () {
                if (_selectedVelocity < 10) {
                  setState(() => _selectedVelocity++);
                }
              }),
            ],
          ),
          const SizedBox(height: 30),
          AppButton(
            label: '확인',
            variant: ButtonVariant.green,
            size: ButtonSize.medium,
            onPressed: () {
              _navigateTo(_SettingsPage.velTestMoving);
              _simulateTestMovement(_SettingsPage.velTestRunning);
            },
          ),
        ],
      ),
    );
  }

  Widget _velocityArrowButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textWhite, size: 32),
      ),
    );
  }

  Widget _buildVelTestMoving() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _velBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointVelLabel(),
          const SizedBox(height: 12),
          Text(
            '장비의 암이 테스트 자세로 이동중입니다',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _pauseButton(),
        ],
      ),
    );
  }

  Widget _buildVelTestRunning() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _velBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointVelLabel(),
          const SizedBox(height: 12),
          Text(
            "'stop' 버튼과 스톱워치의 정지 버튼을 동시에 눌러주세요",
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _dataRow(),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectJointLink(() {
                setState(() => _selectedJoint = null);
                setState(() => _currentPage = _SettingsPage.velTestJoint);
              }),
              const SizedBox(width: 40),
              AppButton(
                label: 'Stop',
                variant: ButtonVariant.red,
                size: ButtonSize.medium,
                onPressed: () => _navigateTo(_SettingsPage.velTestDone),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVelTestDone() {
    return SettingsModalBase(
      title: '',
      breadcrumb: _velBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testJointVelLabel(),
          const SizedBox(height: 12),
          Text(
            '속도 테스트가 완료되었습니다',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _dataRow(),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectJointLink(() {
                setState(() => _selectedJoint = null);
                setState(() => _currentPage = _SettingsPage.velTestJoint);
              }),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: () {
                  // 다시 측정하기 → velTestMoving으로 돌아감
                  setState(() => _currentPage = _SettingsPage.velTestMoving);
                  _simulateTestMovement(_SettingsPage.velTestRunning);
                },
                child: Container(
                  width: 218,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: AppColors.textWhite, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '다시 측정하기',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Step 12: 사용자 관리
  // ═══════════════════════════════════════════════════

  List<BreadcrumbItem> _userBreadcrumb() => [
        BreadcrumbItem(label: '관리자 모드', onTap: _goToAdminMenu),
        BreadcrumbItem(label: '사용자 관리', isCurrent: true),
      ];

  // 더미 데이터
  static const _allUsers = [
    {'name': '김철수', 'id': '20240010', 'dept': '정형외과', 'date': '2024-01-15'},
    {'name': '이영희', 'id': '20240015', 'dept': '재활의학과', 'date': '2024-01-20'},
    {'name': '정수진', 'id': '20240022', 'dept': '정형외과', 'date': '2024-02-01'},
  ];
  static const _pendingUsers = [
    {'name': '최동욱', 'id': '20260011', 'dept': '정형외과', 'datetime': '2026-01-28 10:30'},
  ];

  Widget _buildUserManagement() {
    final filteredAll = _searchQuery.isEmpty
        ? _allUsers
        : _allUsers.where((u) {
            final q = _searchQuery.toLowerCase();
            return u['name']!.toLowerCase().contains(q) ||
                u['id']!.contains(q) ||
                u['dept']!.toLowerCase().contains(q);
          }).toList();

    return SettingsModalBase(
      title: '',
      breadcrumb: _userBreadcrumb(),
      showBack: true,
      onBack: _goBack,
      onClose: _close,
      child: Column(
        children: [
          // 카운터 (우상단에 배치하기 위해 Row 사용)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.people_outline, color: AppColors.textWhite, size: 20),
              const SizedBox(width: 4),
              Text(
                '전체 ${_allUsers.length}명',
                style: AppTextStyles.captionLight.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person_add_outlined, color: AppColors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                '대기 ${_pendingUsers.length}명',
                style: AppTextStyles.captionLight.copyWith(
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 검색바
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.textGray, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: AppTextStyles.captionLight.copyWith(
                      color: AppColors.textBlack,
                    ),
                    decoration: InputDecoration(
                      hintText: '이름, id 또는 소속으로 검색',
                      hintStyle: AppTextStyles.captionLight.copyWith(
                        color: AppColors.grayHighlight,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 탭 바
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _userTabIndex = 0),
                  child: Column(
                    children: [
                      Text(
                        '전체 사용자',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _userTabIndex == 0
                              ? AppColors.blue
                              : AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 2,
                        color: _userTabIndex == 0
                            ? AppColors.blue
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _userTabIndex = 1),
                  child: Column(
                    children: [
                      Text(
                        '등록 요청',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _userTabIndex == 1
                              ? AppColors.blue
                              : AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 2,
                        color: _userTabIndex == 1
                            ? AppColors.blue
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.settingsCardBorder, height: 1),
          const SizedBox(height: 8),
          // 사용자 목록
          Expanded(
            child: _userTabIndex == 0
                ? _buildAllUsersList(filteredAll)
                : _buildPendingUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersList(List<Map<String, String>> users) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = users[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.settingsCardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u['name']!,
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '등록일: ${u['date']}',
                      style: AppTextStyles.captionLight.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'ID: ${u['id']}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '소속: ${u['dept']}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingUsersList() {
    return ListView.separated(
      itemCount: _pendingUsers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = _pendingUsers[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.settingsCardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(u['name']!, style: AppTextStyles.bodyLarge),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '승인 대기',
                      style: AppTextStyles.captionLight.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('ID: ${u['id']}', style: AppTextStyles.captionLight.copyWith(color: AppColors.textWhite)),
                  const SizedBox(width: 24),
                  Text('소속: ${u['dept']}', style: AppTextStyles.captionLight.copyWith(color: AppColors.textWhite)),
                  const SizedBox(width: 24),
                  Text('요청일시: ${u['datetime']}', style: AppTextStyles.captionLight.copyWith(color: AppColors.textWhite)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 승인 처리
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '승인',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 거부 처리
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '거부',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════
  // 공통 헬퍼 위젯
  // ═══════════════════════════════════════════════════

  /// "테스트 관절: J1" 라벨
  Widget _testJointLabel() {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.titleLarge,
        children: [
          const TextSpan(text: '테스트 관절: '),
          TextSpan(
            text: 'J$_selectedJoint',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// "테스트 관절: J1  테스트 속도: 5" 라벨
  Widget _testJointVelLabel() {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.titleLarge,
        children: [
          const TextSpan(text: '테스트 관절: '),
          TextSpan(
            text: 'J$_selectedJoint',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.orange),
          ),
          const TextSpan(text: '  테스트 속도: '),
          TextSpan(
            text: '$_selectedVelocity',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.orange),
          ),
        ],
      ),
    );
  }

  /// 일시정지 다크 버튼
  Widget _pauseButton() {
    return GestureDetector(
      onTap: () => setState(() => _isPaused = !_isPaused),
      child: Container(
        width: 218,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.textWhite, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          _isPaused ? '재개' : '일시정지',
          style: AppTextStyles.headingMedium,
        ),
      ),
    );
  }

  /// 각도 버튼 (-360° / +360°)
  Widget _angleButton(String label, Color bgColor, VoidCallback? onPressed) {
    final isOrange = bgColor == AppColors.orange;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.headingMedium.copyWith(
            color: isOrange ? AppColors.textWhite : AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  /// "다른 관절 선택하기" 초록 링크
  Widget _selectJointLink(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        '다른 관절 선택하기',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.green,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.green,
        ),
      ),
    );
  }

  /// 하단 액션 Row (다른 관절 선택 + 일시정지)
  Widget _bottomActionRow({
    bool showSelectJoint = false,
    VoidCallback? onSelectJoint,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showSelectJoint) ...[
          _selectJointLink(onSelectJoint ?? () {}),
          const SizedBox(width: 40),
        ],
        _pauseButton(),
      ],
    );
  }

  /// 데이터 행 (현재 각도 / 각도 변위 / 목표 각속도)
  Widget _dataRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _dataColumn('현재 각도', '12.2°'),
        _dataColumn('각도 변위', '+7.2°'),
        _dataColumn('목표 각속도', '10 deg/s'),
      ],
    );
  }

  Widget _dataColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.captionLight.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headingLarge,
        ),
      ],
    );
  }

  /// 테스트 이동 시뮬레이션
  void _simulateTestMovement(_SettingsPage nextPage) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _navigateTo(nextPage);
    });
  }
}
