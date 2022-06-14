import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:httpdemo/product.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home:  MyApp(),
  ));
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {

  List<product> listproduct=[];
  Razorpay? razorpay;



  get() async {
    //get-1 ,post-2
    var url = Uri.parse('https://fakestoreapi.com/products?limit=5');
    var response = await http.get(url);
    //string to json
    dynamic result=jsonDecode(response.body);

    result.forEach((element) {
      print(element);
      setState(() {
        listproduct.add(product.fromJson(element));
      });
    });
   print('Response body: ${response.body}');
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
    razorpay = Razorpay();
    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: listproduct.length==0?CircularProgressIndicator():
      ListView.builder(
        itemCount: listproduct.length,
        itemBuilder: (context, index) {
          return ListTile(
            title:Text("${listproduct[index].title}") ,
            subtitle:Text("${listproduct[index].price}") ,
            leading: Image.network("${listproduct[index].image}"),
            trailing: TextButton(onPressed: () {
                      openCheckout();
            }, child: Text("buy")),
          );
        },
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    razorpay!.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_bM3vb2FguXeRad',
      'amount': 100,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Success Response: $response');
    /*Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }
}

