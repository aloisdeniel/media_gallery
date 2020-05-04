import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Selectable extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const Selectable({
    Key key,
    @required this.isSelected,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const minScale = 0.75;
    const duration = Duration(milliseconds: 100);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final translate =
            isSelected ? constraints.maxWidth * (1.0 - minScale) * 0.5 : 0.0;
        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOutCubic,
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(translate, translate)
            ..scale(isSelected ? minScale : 1.0),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: child,
              ),
              Positioned.fill(
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeInOut,
                  color: theme.accentColor.withOpacity(isSelected ? 0.4 : 0),
                ),
              ),
              AnimatedOpacity(
                duration: duration,
                opacity: isSelected ? 1.0 : 0.0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.check,
                      key: Key("checkmark"),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
