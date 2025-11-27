import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/app_colors.dart';

class CustomButton extends StatefulWidget {
  CustomButton({Key? key, required this.onPressed, required this.buttonText})
      : super(key: key);
  final Function onPressed;
  final String buttonText;

  @override
  _CustomButtonState createState() {
    return _CustomButtonState();
  }
}

class _CustomButtonState extends State<CustomButton> {
  bool _isLoading = false;

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
    return GestureDetector(
      onTap: () async {
        if (!_isLoading) {
          if (mounted)
            setState(() {
              _isLoading = true;
            });
          await widget.onPressed();
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Color(0XFF1848C4), borderRadius: BorderRadius.circular(10)),
        child: TextButton(
          onPressed: () async {
            if (!_isLoading) {
              if (mounted)
                setState(() {
                  _isLoading = true;
                });
              await widget.onPressed();
              if (mounted)
                setState(() {
                  _isLoading = false;
                });
            }
          },
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              backgroundColor: MaterialStatePropertyAll(Color(0XFF1848C4)),
              overlayColor: MaterialStateProperty.all(Colors.transparent)),
          child: _isLoading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(color: Colors.white))
              : Text(
                  widget.buttonText,
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
