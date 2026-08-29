import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/dates.dart';
import '../../core/models.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/repositories.dart';
import '../../theme/stitch_theme.dart';
import '../../utils/widgets.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key, required this.partyType, this.partyId});
  final String partyType;
  final int? partyId;
  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _amount = TextEditingController();
  String? mode;
  String date = todayIso();
  bool saving = false;
  List<Invoice>? unpaidInvoices;
  final Set<int> selected = {};
  int? partyId;
  String? partyName;

  bool get isCustomer => widget.partyType == 'customer';

  Future<void> _loadParties() async {
    final businessId = context.read<Session>().businessId;
    if (businessId == null) return;
    final repo = Repository.instance;
    final id = partyId;
    if (id == null) return;
    partyId = id;
    final invoices = isCustomer
        ? await repo.invoicesForParty(businessId, 'customer', id)
        : const <Invoice>[];
    partyName = isCustomer
        ? (await repo.customer(businessId, id))?.name
        : (await repo.supplier(businessId, id))?.name;
    if (!mounted) return;
    setState(() {
      unpaidInvoices = invoices.where((i) => i.status != 'Paid' && i.status != 'Cancelled').toList();
    });
  }

  Future<void> _pickParty() async {
    final businessId = context.read<Session>().businessId;
    if (businessId == null) return;
    final repo = Repository.instance;
    final Object parties = isCustomer
        ? await repo.customers(businessId)
        : await repo.suppliers(businessId);
    if (!mounted) return;
    final all = parties is List<Customer>
        ? parties.map((c) => (id: c.id, name: c.name, phone: c.phone)).toList()
        : (parties as List<Supplier>)
            .map((s) => (id: s.id, name: s.name, phone: s.phone))
            .toList();
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          builder: (context, controller) => ListView.builder(
            controller: controller,
            itemCount: all.length,
            itemBuilder: (context, i) => ListTile(
              leading: InitialsAvatar(all[i].name, size: 36),
              title: Text(all[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(all[i].phone ?? ''),
              onTap: () => Navigator.pop(context, all[i].id),
            ),
          ),
        );
      },
    );
    if (picked == null) return;
    final name = all.firstWhere((e) => e.id == picked).name;
    setState(() {
      partyId = picked;
      partyName = name;
    });
    _loadParties();
  }

  @override
  void initState() {
    super.initState();
    mode = 'Cash';
    if (widget.partyId != null) {
      partyId = widget.partyId;
      _loadParties();
    }
  }

  Future<void> _save() async {
    if (partyId == null) {
      showAppMessage(context, 'Select a party', error: true);
      return;
    }
    final amount = _toPaise(_amount.text);
    if (amount <= 0) {
      showAppMessage(context, 'Enter a valid amount', error: true);
      return;
    }
    setState(() => saving = true);
    try {
      await Repository.instance.recordPayment(
        businessId: context.read<Session>().businessId!,
        partyType: widget.partyType,
        amount: amount,
        date: date,
        mode: mode ?? 'Cash',
        invoiceIds: selected.isEmpty ? null : selected.toList(),
        partyId: partyId,
        partyName: partyName,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showAppMessage(context, 'Could not save: $e', error: true);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  static int _toPaise(String s) {
    final v = double.tryParse(s.trim());
    return v == null ? 0 : (v * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final amount = _toPaise(_amount.text);
    final unpaid = unpaidInvoices ?? const <Invoice>[];
    final unallocated = amount - unpaid.where((i) => selected.contains(i.id)).fold<int>(0, (s, i) => s + i.outstanding.paise);
    return Scaffold(
      appBar: AppBar(
        title: Text(isCustomer ? 'Payment in' : 'Payment out'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Party', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: StitchColors.textSecondary)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickParty,
              borderRadius: BorderRadius.circular(10),
              child: Row(children: [
                Expanded(
                  child: Text(
                    partyName ?? (partyId == null ? (isCustomer ? 'Select customer' : 'Select supplier') : '$partyId'),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: partyId == null ? StitchColors.textSecondary : StitchColors.textPrimary),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ]),
            ),
            const Divider(height: 24),
            AppAmountField(controller: _amount, label: 'Amount (₹)'),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: mode,
              decoration: inputDecoration('Payment mode'),
              items: paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => mode = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final dt = dateTimeFor(date);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dt,
                  firstDate: DateTime(dt.year - 2),
                  lastDate: DateTime(dt.year + 2),
                );
                if (picked != null) setState(() => date = isoDate(picked));
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(date),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ]),
        if (unpaid.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Allocate to invoices', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Tap to select which outstanding invoices this payment settles.',
              style: TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: unpaid.take(8).map((i) => CheckboxListTile(
                    value: selected.contains(i.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selected.add(i.id!);
                      } else {
                        selected.remove(i.id);
                      }
                    }),
                    title: Text(i.number, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${displayDate(i.date)} • outstanding ${formatPaise(i.outstanding.paise)}',
                        style: const TextStyle(fontSize: 11.5)),
                    secondary: Text(formatPaise(i.outstanding.paise), style: moneyStyle(fontSize: 12)),
                  )).toList(),
            ),
          ),
          if (unallocated > 0) ...[
            const SizedBox(height: 8),
            Text('${formatPaise(unallocated)} will be kept as advance',
                style: const TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
          ],
        ] else if (unpaidInvoices != null) ...[
          const SizedBox(height: 16),
          const Text('No outstanding invoices — payment will be recorded as advance.',
              style: TextStyle(fontSize: 12, color: StitchColors.textSecondary)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AsyncButton(loading: saving, label: '${isCustomer ? 'Receive' : 'Pay'} ${amount > 0 ? formatPaise(amount) : 'amount'}', onPressed: _save),
        ),
      ]),
    );
  }
}