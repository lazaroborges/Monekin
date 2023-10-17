import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:monekin/app/home/home.page.dart';
import 'package:monekin/app/transactions/form/transaction_form.page.dart';
import 'package:monekin/app/transactions/transaction_list.dart';
import 'package:monekin/core/database/services/transaction/transaction_service.dart';
import 'package:monekin/core/presentation/widgets/empty_indicator.dart';
import 'package:monekin/core/presentation/widgets/filter_row_indicator.dart';
import 'package:monekin/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:monekin/core/presentation/widgets/skeleton.dart';
import 'package:monekin/core/presentation/widgets/transaction_filter/filter_sheet_modal.dart';
import 'package:monekin/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:monekin/i18n/translations.g.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key, this.filters}) : super(key: key);

  final TransactionFilters? filters;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late TransactionFilters filters;

  bool searchActive = false;

  FocusNode searchFocusNode = FocusNode();
  String? searchValue;

  ScrollController listController = ScrollController();

  final int pageSize = 40;
  late int currentPage = 1;

  @override
  void initState() {
    super.initState();

    filters = widget.filters ?? const TransactionFilters();

    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus) {
        setState(() {
          searchActive = false;
        });
      }
    });

    listController.addListener(() {
      if (listController.offset >= listController.position.maxScrollExtent &&
          !listController.position.outOfRange) {
        setState(() {
          currentPage += 1;
        });
      }
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (searchFocusNode.hasFocus) {
          searchFocusNode.unfocus();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            leading: searchActive
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchActive = false;
                        searchValue = null;
                      });
                    },
                    icon: const Icon(Icons.close))
                : null,
            title: searchActive
                ? TextField(
                    focusNode: searchFocusNode,
                    decoration: InputDecoration(
                        hintText: t.transaction.list.searcher_placeholder,
                        border: const UnderlineInputBorder()),
                    onChanged: (value) {
                      setState(() {
                        searchValue = value;
                      });
                    },
                  )
                : Text(t.transaction.display(n: 10)),
            actions: [
              if (!searchActive)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchActive = true;
                    });

                    searchFocusNode.requestFocus();
                  },
                ),
              IconButton(
                  onPressed: () async {
                    final modalRes = await openFilterSheetModal(
                      context,
                      FilterSheetModal(preselectedFilter: filters),
                    );

                    if (modalRes != null) {
                      setState(() {
                        filters = modalRes;
                      });
                    }
                  },
                  icon: const Icon(Icons.filter_alt_outlined)),
            ]),
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_rounded),
            label: Text(t.transaction.create),
            onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransactionFormPage()))
                }),
        body: Column(
          children: [
            if (filters.hasFilter) ...[
              FilterRowIndicator(
                filters: filters,
                onChange: (newFilters) {
                  setState(() {
                    filters = newFilters;
                  });
                },
              ),
              const Divider(indent: 12, endIndent: 12)
            ],
            StreamBuilder(
              stream: TransactionService.instance
                  .countTransactions(predicate: filters),
              builder: (context, snapshot) {
                final res = snapshot.data;

                return Card(
                  elevation: 3,
                  //color: appColorScheme(context).primary,
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleMedium!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (res != null) ...[
                            Text(
                                '${res.numberOfRes} ${t.transaction.display(n: res.numberOfRes).toLowerCase()}'),
                            CurrencyDisplayer(amountToConvert: res.valueSum)
                          ],
                          if (res == null) ...[
                            const Skeleton(width: 38, height: 18),
                            const Skeleton(width: 28, height: 18),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: StreamBuilder(
                stream: TransactionService.instance.getTransactions(
                  filters: filters,
                  limit: currentPage * pageSize,
                  orderBy: (p0, p1, p2, p3, p4, p5, p6) => drift.OrderBy([
                    drift.OrderingTerm(
                        expression: p0.date, mode: drift.OrderingMode.desc)
                  ]),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [LinearProgressIndicator()],
                    );
                  }

                  final transactions = snapshot.data!;

                  if (transactions.isEmpty) {
                    return Column(
                      children: [
                        Expanded(
                            child: EmptyIndicator(
                                title: t.general.empty_warn,
                                description: t.transaction.list.empty)),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    controller: listController,
                    padding: const EdgeInsets.only(bottom: 80, top: 8),
                    child: Column(
                      children: [
                        TransactionListComponent(
                          transactions: transactions,
                          prevPage: const HomePage(),
                        ),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) ...[
                          const SizedBox(height: 10),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          const Text('Loading data')
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
