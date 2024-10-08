import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/core/database/services/user-setting/user_setting_service.dart';
import 'package:parsa/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:parsa/core/presentation/widgets/modal_container.dart';
import 'package:parsa/core/presentation/widgets/user_avatar.dart';
import 'package:parsa/core/utils/text_field_utils.dart';
import 'package:parsa/i18n/translations.g.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  String? selectedAvatar;

  final List<String> allAvatars = [
    'man',
    'woman',
    'executive_man',
    'executive_woman',
    'blonde_man',
    'blonde_woman',
    'black_man',
    'black_woman',
    'woman_with_bangs',
    'man_with_goatee'
  ];

  @override
  void initState() {
    super.initState();

    final userSettingsService = UserSettingService.instance;

    userSettingsService.getSetting(SettingKey.avatar).first.then((value) {
      setState(() {
        selectedAvatar = value;
      });
    });

    userSettingsService.getSetting(SettingKey.userName).first.then((value) {
      _nameController.value = TextEditingValue(text: value ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final t = Translations.of(context);

    return ModalContainer(
        title: t.settings.edit_profile,
        footer: BottomSheetFooter(
            onSaved: selectedAvatar == null
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final userSettingsService = UserSettingService.instance;

                      Future.wait([
                        userSettingsService.setSetting(
                            SettingKey.userName, _nameController.text),
                        userSettingsService.setSetting(
                            SettingKey.avatar, selectedAvatar!)
                      ].map((e) => Future.value(e))).then((value) {
                        Navigator.pop(context);
                      });
                    }
                  }),
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: 'User name *',
                ),
                validator: (value) => fieldValidator(value, isRequired: true),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, // gap between adjacent cards
              runSpacing: 12, // gap between lines
              alignment: WrapAlignment.center,
              children: allAvatars
                  .map((e) => InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            selectedAvatar = e;
                          });
                        },
                        child: UserAvatar(
                          avatar: e,
                          size: 52,
                          border: selectedAvatar == e
                              ? Border.all(width: 2, color: colors.primary)
                              : Border.all(width: 2, color: Colors.transparent),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ));
  }
}
