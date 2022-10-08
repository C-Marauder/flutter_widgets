import 'package:flutter/material.dart';

class Selector extends StatefulWidget {
  final Widget? leading;
  final Widget? trailing;
  // final Widget text;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<String> data;
  final double? itemHeight;
  final String initValue;
  final TextStyle? textStyle;
  final Color? itemBackgroundColor;
  final double? elevation;
  final double? radius;
  final Color? itemSelectedColor;
  final Function(String newValue) onValueChanged;
  final Widget Function(
    BuildContext context,
    String value,
  ) itemBuilder;
  const Selector(
      {super.key,
      this.leading,
      this.trailing,
      this.padding,
      this.margin,
      required this.itemBuilder,
      required this.data,
      this.itemHeight,
      required this.initValue,
      this.textStyle,
      this.itemBackgroundColor,
      this.elevation,
      this.radius,
      this.itemSelectedColor,
      required this.onValueChanged});
  @override
  State<StatefulWidget> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  late final List<Widget> children = [];
  late final EdgeInsets padding = widget.padding ??
      const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 12);
  late final GlobalKey globalKey = GlobalKey();
  late final RelativeRect relativeRect;
  late final ValueNotifier<String> valueNotifier =
      ValueNotifier(widget.initValue);
  late final double itemHeight = (widget.itemHeight ?? 48) * widget.data.length;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final container =
          globalKey.currentContext!.findRenderObject()! as RenderBox;
      final overlay = Overlay.of(globalKey.currentContext!)!
          .context
          .findRenderObject() as RenderBox;

      relativeRect = RelativeRect.fromRect(
          Rect.fromPoints(
              container.localToGlobal(Offset(0.0, container.size.height),
                  ancestor: overlay),
              container.localToGlobal(container.size.bottomRight(Offset.zero),
                  ancestor: overlay)),
          Offset.zero & overlay.size);
      debugPrint('${relativeRect.left}${relativeRect.right}');
    });

    if (widget.leading != null) {
      children.add(widget.leading!);
    }
    Duration duration = const Duration(milliseconds: 250);
    final TextStyle textStyle =
        widget.textStyle ?? const TextStyle(color: Colors.black, fontSize: 16);
    children.add(Expanded(
        child: ValueListenableBuilder<String>(
            valueListenable: valueNotifier,
            builder: (context, value, child) {
              return AnimatedSwitcher(
                  duration: duration,
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: textStyle,
                    textAlign: TextAlign.start,
                  ),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  });
            })));

    if (widget.trailing != null) {
      children.add(widget.trailing!);
    } else {
      children.add(const Icon(Icons.arrow_drop_down, size: 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    // showMenu(context: context, position: position, items: items)
    return InkWell(
        onTap: () {
          Navigator.of(context)
              .push(_SelectorRoute(
                  height: itemHeight,
                  child: Material(
                      elevation: widget.elevation ?? 4,
                      borderRadius:
                          BorderRadiusDirectional.circular(widget.radius ?? 8),
                      color: widget.itemBackgroundColor ?? Colors.white,
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            final value = widget.data[index];
                            return InkWell(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: value == valueNotifier.value
                                          ? (widget.itemSelectedColor ??
                                              Colors.grey.shade300)
                                          : null),
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  alignment: AlignmentDirectional.centerStart,
                                  height: widget.itemHeight ?? 48,
                                  child: widget.itemBuilder(
                                      context, widget.data[index])),
                              onTap: () {
                                Navigator.of(context).pop([widget.data[index]]);
                              },
                            );
                          },
                          itemCount: widget.data.length)),
                  rect: relativeRect))
              .then((value) {
            if (value != null) {
              final String newValue = value[0];
              valueNotifier.value = newValue;
              widget.onValueChanged(newValue);
            }
          });
        },
        child: Container(
            key: globalKey,
            padding: padding,
            margin: widget.margin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            )));
  }
}

class _SelectorRoute extends PopupRoute {
  final Widget child;
  final RelativeRect rect;
  final double height;
  late final Duration duration = const Duration(milliseconds: 250);
  _SelectorRoute(
      {required this.child, required this.rect, required this.height});
  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final rectAnimation = RelativeRectTween(
            begin: RelativeRect.fromLTRB(
                rect.left, rect.top, rect.right, rect.bottom),
            end: RelativeRect.fromLTRB(rect.left, rect.top, rect.right, 0))
        .animate(animation);
    return SafeArea(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            removeTop: true,
            child: Stack(children: [
              PositionedTransition(rect: rectAnimation, child: child)
            ])));
  }

  @override
  Duration get transitionDuration => duration;
}
