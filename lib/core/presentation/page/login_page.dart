import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_art_collection/app_localization.dart';
import 'package:student_art_collection/core/presentation/widget/custom_checkbox.dart';
import 'package:student_art_collection/core/util/text_constants.dart';
import 'package:student_art_collection/core/util/theme_constants.dart';
import 'package:student_art_collection/features/buy_art/presentation/page/gallery_page.dart';
import 'package:student_art_collection/features/list_art/presentation/bloc/auth/school_auth_bloc.dart';
import 'package:student_art_collection/features/list_art/presentation/bloc/auth/school_auth_event.dart';
import 'package:student_art_collection/features/list_art/presentation/bloc/auth/school_auth_state.dart';
import 'package:student_art_collection/features/list_art/presentation/page/registration_page.dart';
import 'package:student_art_collection/features/list_art/presentation/page/school_gallery_page.dart';

import '../../../features/buy_art/presentation/page/gallery_page.dart';
import '../../../features/list_art/presentation/bloc/auth/school_auth_bloc.dart';
import '../../../features/list_art/presentation/bloc/auth/school_auth_state.dart';
import '../../../features/list_art/presentation/bloc/auth/school_auth_state.dart';
import '../../../service_locator.dart';
import '../../util/theme_constants.dart';
import '../../util/theme_constants.dart';

class LoginPage extends StatelessWidget {
  static const String ID = "/";

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SchoolAuthBloc>(
      create: (context) => sl<SchoolAuthBloc>(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: primaryColor,
        body: BlocListener<SchoolAuthBloc, SchoolAuthState>(
          listener: (context, state) {
            if (state is Authorized) {
              Navigator.pushReplacementNamed(context, SchoolGalleryPage.ID);
            } else if (state is SchoolAuthError) {
              final snackBar = SnackBar(content: Text(state.message));
              Scaffold.of(context).showSnackBar(snackBar);
            }
          },
          child: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return LoginForm(screenHeight: viewportConstraints.maxHeight);
          }),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final double screenHeight;

  const LoginForm({Key key, this.screenHeight}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState(screenHeight);
}

class _LoginFormState extends State<LoginForm> {
  final double screenHeight;
  String email, password;
  bool shouldRemember = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  _LoginFormState(this.screenHeight);

  void _onCheckboxChange() {
    setState(() {
      shouldRemember = !shouldRemember;
    });
  }

  void dispatchLogin() {
    BlocProvider.of<SchoolAuthBloc>(context).add(LoginSchoolEvent(
      email: email,
      password: password,
      shouldRemember: shouldRemember,
    ));
  }

  void dispatchLoginOnReturn() {
    BlocProvider.of<SchoolAuthBloc>(context).add(LoginOnReturnEvent());
  }

  void dispatchRegistration() {
    Navigator.pushNamed(context, SchoolRegistrationPage.ID);
  }

  void dispatchGuest() {
    Navigator.pushNamed(context, GalleryPage.ID);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setRememberedInfo();
  }

  void setRememberedInfo() {
    setState(() {
      final storedEmail = sl<SharedPreferences>().getString('email' ?? '');
      emailController.text = storedEmail;
      passwordController.text =
          sl<SharedPreferences>().getString('password' ?? '');
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double positionTopBanner = screenHeight * (.77);
    double positionTopTextField = screenHeight * (.62);
    double positionBottomTextField = screenHeight * (.50);
    double positionCheckBox = screenHeight * (.45);
    double positionMiddleButton = screenHeight * (.37);
    double positionDivider = screenHeight * (.31);
    double positionBottomButton = screenHeight * (.18);

    return Stack(
      children: <Widget>[
        topBanner(
            position: positionTopBanner,
            text:
                AppLocalizations.of(context).translate(TEXT_LOGIN_HEADER_TEXT),
            fontSize: 40),
        textFieldWidget(
            controller: emailController,
            position: positionTopTextField,
            text: AppLocalizations.of(context)
                .translate(TEXT_LOGIN_EMAIL_ADDRESS_LABEL),
            onChanged: (value) {
              email = value;
            }),
        textFieldWidget(
            controller: passwordController,
            position: positionBottomTextField,
            text: AppLocalizations.of(context)
                .translate(TEXT_LOGIN_PASSWORD_LABEL),
            onChanged: (value) {
              password = value;
            }),
        checkBoxWithLabel(
          position: positionCheckBox,
          label: AppLocalizations.of(context)
              .translate(TEXT_LOGIN_REMEMBER_ME_BOX),
          onChanged: (value) {
            _onCheckboxChange();
          },
        ),
        BlocBuilder<SchoolAuthBloc, SchoolAuthState>(
          builder: (BuildContext context, state) {
            if (state is SchoolAuthLoading) {
              return middleButton(
                  position: positionMiddleButton,
                  onTap: () {},
                  icon: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ));
            }
            return middleButton(
                position: positionMiddleButton,
                onTap: dispatchLogin,
                icon: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 45,
                ));
          },
        ),
        divider(
            position: positionDivider,
            text: AppLocalizations.of(context)
                .translate(TEXT_LOGIN_DIVIDER_TEXT)),
        bottomButton(
          position: positionBottomButton,
          label: AppLocalizations.of(context)
              .translate(TEXT_LOGIN_GUEST_LOGIN_BUTTON),
          onTap: () {
            Navigator.pushNamed(context, GalleryPage.ID);
          },
        ),
        footerWidget(
            textSpan: TextSpan(
                text: AppLocalizations.of(context)
                    .translate(TEXT_LOGIN_REGISTER_HERE_PREFIX),
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context)
                        .translate(TEXT_LOGIN_REGISTER_HERE_MAIN),
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate(TEXT_LOGIN_REGISTER_HERE_SUFFIX),
                      style: TextStyle(color: Colors.black))
                ]),
            onTap: dispatchRegistration)
      ],
    );
  }

  Widget textFieldWidgetNoBorderWhite(
      {String label,
      Function(String value) onChanged,
      TextEditingController controller}) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 5, bottom: 5),
          alignment: Alignment.bottomLeft,
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (value) => onChanged(value),
              decoration: InputDecoration.collapsed(hintText: ""),
            ),
          ),
        )
      ],
    );
  }

  Widget topBanner(
      {@required double position,
      @required String text,
      @required double fontSize}) {
    return Positioned(
      bottom: position,
      left: 24,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget textFieldWidget({
    @required double position,
    @required String text,
    @required Function(String) onChanged,
    @required TextEditingController controller,
  }) {
    return Positioned(
        bottom: position,
        left: 16,
        right: 16,
        child: textFieldWidgetNoBorderWhite(
          label: text,
          onChanged: onChanged,
          controller: controller,
        ));
  }

  Widget checkBoxWithLabel(
      {@required double position,
      @required String label,
      Function(bool) onChanged}) {
    return Positioned(
      left: 16,
      bottom: position,
      child: Container(
        padding: EdgeInsets.only(top: 16),
        child: Row(
          children: <Widget>[
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(right: 8),
              child: CustomCheckbox(
                value: shouldRemember,
                activeColor: accentColor,
                materialTapTargetSize: null,
                onChanged: (value) => onChanged(value),
                useTapTarget: false,
              ),
            ),
            Text(
              label,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget middleButton(
      {@required double position, Function onTap, Widget icon}) {
    return Positioned(
      right: 16,
      bottom: position,
      child: Container(
        child: RaisedButton(
          padding: EdgeInsets.all(8),
          onPressed: onTap,
          elevation: 10,
          color: accentColor,
          shape: CircleBorder(),
          child: icon,
        ),
      ),
    );
  }

  Widget divider({@required double position, String text}) {
    return Positioned(
      bottom: position,
      left: 0,
      right: 0,
      child: Row(children: <Widget>[
        Expanded(
            child: Divider(
          color: Colors.white,
          thickness: 1.5,
        )),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 20),
            )),
        Expanded(
            child: Divider(
          color: Colors.white,
          thickness: 1.5,
        )),
      ]),
    );
  }

  Widget bottomButton(
      {@required double position, @required String label, Function onTap}) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: position,
      child: Container(
        height: 50,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: onTap,
          color: accentColor,
          elevation: 10,
          textTheme: ButtonTextTheme.primary,
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  Widget footerWidget({TextSpan textSpan, Function onTap}) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          child: InkWell(
            child: Text.rich(textSpan),
            onTap: () {
              dispatchRegistration();
            },
          ),
        ),
      ),
    );
  }
}
