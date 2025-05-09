import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../../widgets/forms/app_checkbox.dart';
import '../../../theme/color_theme.dart';
import '../controllers/agreement_controller.dart';

class AgreementView extends GetView<AgreementController> {
  const AgreementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        '"记录"用户协议',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '欢迎使用"记录"应用。在使用我们的服务之前，请您仔细阅读以下全部内容。',
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '1. 引言',
                      '本应用"记录"（以下简称"本应用"）是一款为用户提供性同意记录的工具。本应用旨在通过技术手段帮助用户创建和保存双方同意的记录，但不能替代法律建议或保证法律效力。',
                    ),
                    _buildSection(
                      '2. 服务内容',
                      '本应用提供以下服务：\n'
                      '• 通过配对功能连接双方用户\n'
                      '• 通过面部识别验证用户身份\n'
                      '• 记录双方的同意状态\n'
                      '• 生成同意记录的证据\n'
                      '• 存储历史记录以供查询',
                    ),
                    _buildSection(
                      '3. 用户资格',
                      '使用本应用的用户必须：\n'
                      '• 年满18周岁\n'
                      '• 具有完全民事行为能力\n'
                      '• 能够理解并同意本协议的全部内容',
                    ),
                    _buildSection(
                      '4. 用户责任',
                      '用户在使用本应用时应当：\n'
                      '• 提供真实、准确的个人信息\n'
                      '• 保管好个人账号和密码，不得将账号借给他人使用\n'
                      '• 对自己在本应用上的行为和产生的内容负责\n'
                      '• 遵守相关法律法规和社会公德',
                    ),
                    _buildSection(
                      '5. 隐私保护',
                      '我们重视用户的隐私保护。本应用将按照《隐私政策》收集、使用、存储和保护用户信息。使用本应用即表示您同意我们的隐私政策。',
                    ),
                    _buildSection(
                      '6. 免责声明',
                      '• 本应用不能替代正式的法律建议或法律程序\n'
                      '• 我们不保证本应用生成的记录在法律上的有效性\n'
                      '• 用户应对使用本应用的决定和后果自行负责\n'
                      '• 我们不对因网络故障、系统维护等导致的服务中断负责',
                    ),
                    _buildSection(
                      '7. 知识产权',
                      '本应用的所有内容、设计、代码等均受知识产权法律保护。未经许可，不得复制、修改、传播或用于商业目的。',
                    ),
                    _buildSection(
                      '8. 协议修改',
                      '我们保留随时修改本协议的权利。修改后的协议将在本应用内公布，继续使用本应用即表示您接受修改后的协议。',
                    ),
                    _buildSection(
                      '9. 终止服务',
                      '如用户违反本协议或相关法律法规，我们有权终止对该用户的服务。用户也可以随时停止使用本应用。',
                    ),
                    _buildSection(
                      '10. 联系方式',
                      '如您对本协议或本应用有任何问题，请通过应用内的"联系我们"功能与我们联系。',
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        '最后更新日期：2023年5月1日',
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: ColorTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => AppCheckbox(
              value: controller.isAgreed.value,
              onChanged: controller.toggleAgreement,
              label: '我已阅读并同意《用户协议》',
              enabled: controller.hasReachedBottom.value,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => PrimaryButton(
              text: '同意并继续',
              onPressed: controller.isAgreed.value ? controller.agreeToTerms : null,
            ),
          ),
        ],
      ),
    );
  }
}