import 'package:flutter/material.dart';
import '../../model/ProductContentModel.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';


class ProductContentSecond extends StatefulWidget {

  final ProductContentModel productContentModel;

  ProductContentSecond(this.productContentModel, {Key key}) : super(key: key);

  _ProductContentSecondState createState() => _ProductContentSecondState();
}

class _ProductContentSecondState extends State<ProductContentSecond> with AutomaticKeepAliveClientMixin{


  // 商品ID
  var _id;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._id = widget.productContentModel.result.sId;
    print("this._id = " +this._id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(
         children: <Widget>[
           Expanded(
             child: InAppWebView(
               initialUrl: "http://jd.itying.com/pcontent?id=${ this._id}",

               onProgressChanged: (InAppWebViewController controller, int progress) {

               },
             ),
           )
         ],
       ),
    );
  }


}