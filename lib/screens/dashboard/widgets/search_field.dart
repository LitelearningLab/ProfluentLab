import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/screens/word_screen/search_result_screen.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class SearchField extends StatelessWidget {
  SearchField({Key? key, this.validator,required this.labType}) : super(key: key);

  final FormFieldValidator<String>? validator;
  String labType;
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Container(
      height: 30,
      color: Color(0XFF324265),
      margin: EdgeInsets.only(right: 22),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        cursorColor: Colors.white,
        style: TextStyle(
          fontFamily: Keys.fontFamily,
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          letterSpacing: 0.3334423928571427,
        ),
        validator: validator,
        onFieldSubmitted: (val) {
          FocusScope.of(context).requestFocus(new FocusNode());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchResultScreen(
                        searchTerm: val,
                    labType: labType,
                      ))).then((value) => controller.clear());
        },
        decoration: new InputDecoration(
          isDense: true,
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)

          ),
          errorBorder: UnderlineInputBorder(
          ),
          disabledBorder: UnderlineInputBorder(
          ),
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            onPressed: (){
              FocusScope.of(context).requestFocus(new FocusNode());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchResultScreen(
                        searchTerm: controller.text,
                        labType: labType,
                      ))).then((value) => controller.clear());
          },
            icon: Icon(Icons.search_rounded,color: Colors.white,),
          ),
          hintText: "Search",
          hintStyle: TextStyle(
            fontFamily: Keys.fontFamily,
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.zero,

          filled: true,
          fillColor: Color(0xFF324265),
        ),
      ),
    );
  }
}
