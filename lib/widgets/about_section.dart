import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      // margin: EdgeInsets.symmetric(horizontal: 0),
      //padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4),
            child: Text(
              "Sri Lanka, you can tune into The Buddhist Radio on FM radio waves at 101.3 MHz or 101.5 MHz",
              style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            child: Text(
              "ඔබ ශ්‍රී ලංකාවේ සිටින්නේ නම්, ඔබට 101.3 MHz හෝ 101.5 MHz වලදී FM රේඩියෝ තරංග ඔස්සේ The Buddhist Radio සුසර කළ හැකිය",
              style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
