import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_colors.dart';

/// One "label ....... value" line inside a details card.
///
/// SRP: layout of a single row. Copy behaviour is opt-in via [copyable].
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final bool emphasised;
  final Color? valueColor;
  final Widget? valueWidget;

  const InfoRow({
    super.key,
    required this.label,
    this.value = '',
    this.copyable = false,
    this.emphasised = false,
    this.valueColor,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: valueWidget ??
                      Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: emphasised ? 15 : 13,
                          fontWeight: emphasised ? FontWeight.w800 : FontWeight.w600,
                          color: valueColor ?? theme.textTheme.titleMedium?.color,
                          height: 1.4,
                        ),
                      ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('$label copied')));
                    },
                    child: const Icon(Icons.copy_outlined, size: 15, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card wrapper that draws a titled block of [InfoRow]s with dividers.
class InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> rows;
  final EdgeInsetsGeometry padding;

  const InfoCard({
    super.key,
    this.title,
    required this.rows,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divided = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      divided.add(rows[i]);
      if (i < rows.length - 1) {
        divided.add(Divider(
          height: 1,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
        ],
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(children: divided),
        ),
      ],
    );
  }
}
