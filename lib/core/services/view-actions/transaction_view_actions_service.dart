import 'package:flutter/material.dart';
import 'package:parsa/app/transactions/form/transaction_form.page.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/presentation/widgets/confirm_dialog.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/utils/list_tile_action_item.dart';
import 'package:parsa/core/utils/uuid.dart';

import '../../../i18n/translations.g.dart';

class TransactionViewActionService {
  final TransactionService transactionService = TransactionService.instance;

  TransactionViewActionService();

  List<ListTileActionItem> transactionDetailsActions(
    BuildContext context, {
    required MoneyTransaction transaction,
    bool navigateBackOnDelete = false,
  }) {
    final isRecurrent = transaction.recurrentInfo.isRecurrent;

    return [
      ListTileActionItem(
        label: t.general.edit,
        icon: Icons.edit,
        onClick: () => RouteUtils.pushRoute(
            context,
            TransactionFormPage(
              transactionToEdit: transaction,
              mode: transaction.type,
            )),
      ),
      if (transaction.recurrentInfo.isNoRecurrent)
        ListTileActionItem(
          label: t.transaction.duplicate_short,
          icon: Icons.control_point_duplicate_rounded,
          onClick: () => TransactionViewActionService()
              .cloneTransactionWithAlertAndSnackBar(context,
                  transaction: transaction),
        ),
      ListTileActionItem(
          label: t.general.delete,
          icon: Icons.delete,
          role: ListTileActionRole.delete,
          onClick: () => TransactionViewActionService()
                  .deleteTransactionWithAlertAndSnackBar(
                context,
                transactionId: transaction.id,
                isRecurrent: isRecurrent,
                navigateBack: navigateBackOnDelete,
              ))
    ];
  }

  deleteTransactionWithAlertAndSnackBar(
    BuildContext context, {
    required String transactionId,
    bool isRecurrent = false,
    required bool navigateBack,
  }) {
    final t = Translations.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    confirmDialog(
      context,
      icon: Icons.delete,
      dialogTitle: !isRecurrent
          ? t.transaction.delete
          : t.recurrent_transactions.details.delete_header,
      contentParagraphs: [
        Text(!isRecurrent
            ? t.transaction.delete_warning_message
            : t.recurrent_transactions.details.delete_message),
      ],
      confirmationText: t.general.continue_text,
    ).then((isConfirmed) {
      if (isConfirmed != true) return;

      transactionService.deleteTransaction(transactionId).then((value) {
        if (value == 0) {
          scaffold.showSnackBar(
            const SnackBar(content: Text('Error removing the transaction')),
          );

          return;
        }

        if (navigateBack) {
          Navigator.pop(context);
        }

        scaffold.showSnackBar(SnackBar(
          content: Text(t.transaction.delete_success),
        ));
      }).catchError((err) {
        scaffold.showSnackBar(SnackBar(content: Text('$err')));
      });
    });
  }

  cloneTransactionWithAlertAndSnackBar(
    BuildContext context, {
    required MoneyTransaction transaction,
  }) {
    final t = Translations.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    confirmDialog(
      context,
      icon: Icons.control_point_duplicate_rounded,
      dialogTitle: t.transaction.duplicate,
      contentParagraphs: [Text(t.transaction.duplicate_warning_message)],
      confirmationText: t.general.continue_text,
    ).then((isConfirmed) {
      if (isConfirmed != true) return;

      transactionService
          .insertTransaction(
        TransactionInDB(
          id: generateUUID(),
          accountID: transaction.accountID,
          date: transaction.date,
          value: transaction.value,
          type: transaction.type,
          isHidden: transaction.isHidden,
          categoryID: transaction.categoryID,
          notes: transaction.notes,
          title: transaction.title,
          receivingAccountID: transaction.receivingAccountID,
          status: transaction.status,
          valueInDestiny: transaction.valueInDestiny,
        ),
      )
          .then((value) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(t.transaction.duplicate_success),
          ),
        );
      }).catchError((err) {
        scaffold.showSnackBar(SnackBar(content: Text('$err')));
      });
    });
  }
}
