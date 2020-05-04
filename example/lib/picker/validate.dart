import 'package:flutter/material.dart';

import 'selection.dart';

class PickerValidateButton extends StatelessWidget {
  final ValueChanged<MediaPickerSelection> onValidate;

  const PickerValidateButton({
    @required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    final selection = MediaPickerSelection.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AnimatedBuilder(
        animation: selection,
        builder: (context, _) {
          return Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: selection.selectedMedias.isNotEmpty ? 1.0 : 0.3,
              child: Material(
                color: (theme.appBarTheme.iconTheme ?? IconTheme.of(context))
                    .color,
                borderRadius: BorderRadius.circular(100),
                child: InkWell(
                  focusColor: theme.accentColor.withOpacity(0.2),
                  hoverColor: theme.accentColor.withOpacity(0.1),
                  highlightColor: theme.accentColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                  splashColor: theme.accentColor.withOpacity(0.5),
                  onTap: selection.selectedMedias.isNotEmpty
                      ? () => onValidate(selection)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: <Widget>[
                        if (selection.selectedMedias.isNotEmpty) ...[
                          Text(
                            selection.selectedMedias.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.accentColor,
                            ),
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                        ],
                        Icon(
                          Icons.check,
                          color: theme.accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
