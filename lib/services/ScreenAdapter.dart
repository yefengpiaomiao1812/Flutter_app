
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 封装屏幕适配类
class ScreenAdapter{

  static init(context){
    ScreenUtil.init(context, width: 750, height: 1334);
  }
  static height(double value){
     return ScreenUtil().setHeight(value);
  }
  static width(double value){
      return ScreenUtil().setWidth(value);
  }
  static getScreenHeight(){
    return ScreenUtil.screenHeightDp;
  }
  static getScreenWidth(){
    return ScreenUtil.screenWidthDp;
  }

  // 文字大小
  static size(double value){
    return ScreenUtil().setSp(value);
  }

  // ScreenUtil.screenHeight 
}

// ScreenAdaper