import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class DropDownMenu extends StatefulWidget {
  DropDownMenu(
      {Key? key,
      required this.children,
      required this.icon,
      required this.title,
      required this.isExpand,
      required this.onExpansionChanged})
      : super(key: key);
  final List<Widget> children;
  final String title;
  final String icon;
  final bool isExpand;
  final ValueChanged<bool> onExpansionChanged;

  @override
  _DropDownMenuState createState() {
    return _DropDownMenuState();
  }
}

class _DropDownMenuState extends State<DropDownMenu> {
  final GlobalKey<AppExpansionTileState> expansionTileKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.white);
    return Theme(
      data: theme,
      child: AppExpansionTile(
        onExpansionChanged: widget.onExpansionChanged,
        key: expansionTileKey,
        initiallyExpanded: widget.isExpand,
        title: Container(
          decoration: BoxDecoration(color: Color(0xff333a40)
              // image: DecorationImage(
              //   image: AssetImage(AllAssets.yellowbc),
              //   fit: BoxFit.fill,
              // ),
              ),
          height: 75,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: displayWidth(context) * 0.15,
                height: 80,
                decoration: BoxDecoration(color: Colors.white
                    // image: DecorationImage(
                    //   image: AssetImage(AllAssets.whitebc),
                    //   fit: BoxFit.fill,
                    // ),
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      widget.icon,
                      width: displayWidth(context) * 0.1,
                      color: Color(0xff333a40),
                      height: 40,
                    ),
                  ],
                ),
              ),
              SPW(20),
              Flexible(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: Keys.fontFamily,
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.377901378571428,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: widget.children,
      ),
    );
  }
}

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTile extends StatefulWidget {
  const AppExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.backgroundColor,
    required this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
  }) : super(key: key);

  final Widget? leading;
  final Widget title;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool initiallyExpanded;

  @override
  AppExpansionTileState createState() => new AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _easeOutAnimation;
  late CurvedAnimation _easeInAnimation;
  late ColorTween _borderColor;
  late ColorTween _headerColor;
  late ColorTween _iconColor;
  late ColorTween _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _easeInAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _borderColor = new ColorTween();
    _headerColor = new ColorTween();
    _iconColor = new ColorTween();

    _backgroundColor = new ColorTween();

    _isExpanded =
        PageStorage.of(context)!.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded)
          _controller.forward();
        else
          _controller.reverse().then((value) {
            setState(() {});
          });
        PageStorage.of(context)!.writeState(context, _isExpanded);
      });
      widget.onExpansionChanged(_isExpanded);
    }
  }

  Widget _buildChildren(BuildContext? context, Widget? child) {
    final Color? titleColor = _headerColor.evaluate(_easeInAnimation);

    return new Container(
      decoration: new BoxDecoration(
        color:
            _backgroundColor.evaluate(_easeOutAnimation) ?? Colors.transparent,
//          border: new Border(
//            top: new BorderSide(color: borderSideColor),
//            bottom: new BorderSide(color: borderSideColor),
//          )
      ),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme.merge(
            data:
                new IconThemeData(color: _iconColor.evaluate(_easeInAnimation)),
            child: GestureDetector(
              onTap: toggle,
              child: DefaultTextStyle(
                style: Theme.of(context!)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: titleColor),
                child: widget.title,
              ),
            ),
          ),
          new ClipRect(
            child: new Align(
              heightFactor: _easeInAnimation.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor.end = theme.dividerColor;
    _headerColor
      ..begin = theme.textTheme.headlineMedium?.color
      ..end = theme.primaryColor;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.primaryColor;
    _backgroundColor.end = widget.backgroundColor;
    if (!widget.initiallyExpanded) {
      _controller.reverse().then((value) {
        // setState(() {});
      });
    }

    final bool closed = !_isExpanded && _controller.isDismissed;
    return new AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : new Column(children: widget.children),
    );
  }
}
