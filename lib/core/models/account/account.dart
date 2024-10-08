import 'package:flutter/material.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/models/supported-icon/icon_displayer.dart';
import 'package:parsa/core/models/supported-icon/supported_icon.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/theme.dart';
import 'package:parsa/core/services/supported_icon/supported_icon_service.dart';
import 'package:parsa/i18n/translations.g.dart';

enum AccountType {
  /// A normal type of account The default type
  normal,

  /// This type of accounts can not have transactions. You only can add and withdraw money from it from other accounts
  saving;

  IconData get icon {
    if (this == normal) {
      return Icons.wallet;
    } else if (this == saving) {
      return Icons.savings;
    }

    return Icons.question_mark;
  }

  String title(BuildContext context) {
    final t = Translations.of(context);

    if (this == normal) {
      return t.account.types.normal;
    } else if (this == saving) {
      return t.account.types.saving;
    }

    return '';
  }

  String description(BuildContext context) {
    final t = Translations.of(context);

    if (this == normal) {
      return t.account.types.normal_descr;
    } else if (this == saving) {
      return t.account.types.saving_descr;
    }

    return '';
  }
}

class Account extends AccountInDB {
  Account({
    required super.id,
    required super.name,
    required super.iniValue,
    required super.date,
    required super.type,
    required super.displayOrder,
    required super.iconId,
    required this.currency,
    super.closingDate,
    super.description,
    super.iban,
    super.swift,
    super.color,
  }) : super(currencyId: currency.code);

  /// Currency of all the transactions of this account. When you change this currency all transactions in this account
  /// will have the new currency but their amount/value will remain the same.
  CurrencyInDB currency;

  SupportedIcon get icon => SupportedIconService.instance.getIconByID(iconId);

  bool get isClosed => closingDate != null;

  Color getComputedColor(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    return color != null
        ? ColorHex.get(color!)
        : isLightMode
            ? AppColors.of(context).primary
            : AppColors.of(context).primaryContainer;
  }

  IconDisplayer displayIcon(
    BuildContext context, {
    double size = 24,
    double? padding,
    double outlineWidth = 4,
    bool isOutline = false,
    void Function()? onTap,
  }) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;

    return IconDisplayer(
      supportedIcon: icon,
      mainColor: getComputedColor(context).lighten(isLightMode ? 0 : 0.82),
      secondaryColor: getComputedColor(context).lighten(isLightMode ? 0.82 : 0),
      displayMode: IconDisplayMode.polygon,
      size: size,
      borderRadius: 20,
      outlineWidth: outlineWidth,
      isOutline: isOutline,
      padding: padding,
      onTap: onTap,
    );
  }

  static Account fromDB(AccountInDB account, CurrencyInDB currency) => Account(
      id: account.id,
      currency: currency,
      iniValue: account.iniValue,
      date: account.date,
      displayOrder: account.displayOrder,
      description: account.description,
      iban: account.iban,
      swift: account.swift,
      name: account.name,
      iconId: account.iconId,
      closingDate: account.closingDate,
      type: account.type,
      color: account.color);
}
