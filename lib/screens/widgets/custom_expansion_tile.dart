import 'package:flutter/material.dart';

/// This class is a fork from the main Flutter [ExpansionTile] class
/// To read more about some properties in this class, please check the main
/// [ExpansionTile] class in the flutter documentation. Also, all comments are
/// removed here and you can read about this in the [ExpansionTile]
/// documentation.
/// The only adjustment this class made is to remove the border line when the
/// expansion is active.

const Duration _kExpand = Duration(milliseconds: 300);

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.showDropDownIcon = true,
    this.onTap,
  })  : assert(
          expandedCrossAxisAlignment != CrossAxisAlignment.baseline,
          'CrossAxisAlignment.baseline is not supported since '
          'the expanded children '
          'are aligned in a column, not a row. Try to use another constant.',
        ),
        super(key: key);

  final Widget? leading;

  final Widget title;

  final Widget? subtitle;

  final ValueChanged<bool>? onExpansionChanged;

  final List<Widget> children;

  final Color? backgroundColor;

  final Color? collapsedBackgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  final bool initiallyExpanded;

  final bool maintainState;

  final EdgeInsetsGeometry? tilePadding;

  final Alignment? expandedAlignment;

  final CrossAxisAlignment? expandedCrossAxisAlignment;

  final EdgeInsetsGeometry? childrenPadding;

  final Color? iconColor;

  final Color? collapsedIconColor;

  final Color? textColor;

  final Color? collapsedTextColor;

  final bool showDropDownIcon;

  final Function()? onTap;

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor =
        _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  void didChangeDependencies() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    _borderColorTween.end = theme.dividerColor;
    _headerColorTween
      ..begin = widget.collapsedTextColor ?? theme.textTheme.subtitle1!.color
      ..end = widget.textColor ?? colorScheme.primary;
    _iconColorTween
      ..begin = widget.collapsedIconColor ?? theme.unselectedWidgetColor
      ..end = widget.iconColor ?? colorScheme.primary;
    _backgroundColorTween
      ..begin = widget.collapsedBackgroundColor
      ..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final closed = !_isExpanded && _controller.isDismissed;
    final shouldRemoveChildren = closed && !widget.maintainState;

    final result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Padding(
          padding: widget.childrenPadding ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment:
                widget.expandedCrossAxisAlignment ?? CrossAxisAlignment.center,
            children: widget.children,
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _backgroundColor.value ?? Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 43.0,
                  child: ListTileTheme.merge(
                    iconColor: _iconColor.value,
                    textColor: _headerColor.value,
                    dense: true,
                    child: ListTile(
                      onTap: widget.onTap ?? _handleTap,
                      contentPadding: widget.tilePadding,
                      leading: widget.leading,
                      title: Row(
                        children: [
                          if (widget.showDropDownIcon)
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: RotationTransition(
                                turns: _iconTurns,
                                child: const Icon(Icons.expand_more),
                              ),
                            ),
                          widget.title,
                        ],
                      ),
                      subtitle: widget.subtitle,
                      trailing: widget.trailing,
                    ),
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  alignment: widget.expandedAlignment ?? Alignment.center,
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
      child: shouldRemoveChildren ? null : result,
    );
  }
}
