import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_button.dart';
import 'widgets/intro_section.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            SizedBox(height: 1.sh * 0.25, child: const IntroSection()),
            SizedBox(height: 1.sh * 0.05),
            Text(
              'We sent a reset password link to your mailbox!',
              textAlign: TextAlign.center,
              style: textTheme.headline6!.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Check your mailbox and set up a new password to log into your '
              'Pure account',
              textAlign: TextAlign.center,
              style: textTheme.subtitle1!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 80),
            CustomButton(
              title: 'GO BACK TO LOGIN',
              width: 1.sw * 0.5,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
