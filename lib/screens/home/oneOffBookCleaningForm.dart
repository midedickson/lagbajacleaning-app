import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:lagbaja_cleaning/models/pricing.dart';
import 'package:lagbaja_cleaning/models/sessions.dart';
import 'package:lagbaja_cleaning/models/user.dart';
import 'package:lagbaja_cleaning/services/database.dart';
import 'package:lagbaja_cleaning/shared.dart';
// import 'package:paystack_manager/paystack_pay_manager.dart';
import 'package:provider/provider.dart';

class OneOffBookCleaningForm extends StatefulWidget {
  final userInfo;
  OneOffBookCleaningForm({this.userInfo});
  @override
  _OneOffBookCleaningFormState createState() => _OneOffBookCleaningFormState();
}

class _OneOffBookCleaningFormState extends State<OneOffBookCleaningForm> {
  static final _bookCleaningFormKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  bool loading = false;
  bool successful = false;
  bool failed = false;
  bool _switchValue = false;
  String radioValue = 'Mild';
  String selectedApartmentValue;
  String selectedLocation;
  DateTime selectedDate = DateTime.now();
  dynamic dateFormat = DateFormat.yMMMEd();
  DateTime orderDate = DateTime.now();
  String stringDate;
  double levelCost = 0.0;
  double apartmentCost = 0.0;
  double totalCost = 0.0;
  double sliderValue = 0;
  dynamic result;
  final plugin = PaystackPlugin();

  @override
  void initState() {
    plugin.initialize(
        publicKey: 'sk_test_a26e37713f79c65a969e45e23a6ee76cc92c7122');
    super.initState();
  }

  void displayDatePicker() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        stringDate = dateFormat.format(selectedDate);
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }

  List<Widget> buildApartmentDropdown() {
    return apartmentTypes.map((apartment) {
      return DropdownMenuItem(
        value: apartment,
        child: Text(
          apartment,
          style: SmallTextStyle.copyWith(color: Colors.blue),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final secretKey = Provider.of<SecretKey>(context);

    // void _onPaymentSuccessful(Transaction transaction) {
    //   print("Transaction was successful");
    //   print("Transaction Message ===> ${transaction.message}");
    //   print("Transaction Refrence ===> ${transaction.refrenceNumber}");

    //   CleaningSession initial = CleaningSession.initialData();
    //   result = DatabaseService(uid: user.uid).updateCleaningSession(
    //       location: selectedLocation,
    //       apartmentType: selectedApartmentValue,
    //       subscription: initial.subscription,
    //       userUid: user.uid,
    //       totalCost: totalCost,
    //       isRated: initial.isRated,
    //       isPaid: true,
    //       cleaningDay: initial.cleaningDay,
    //       isCompleted: initial.isCompleted,
    //       dateOrdered: initial.orderDate,
    //       cleaningDate: selectedDate);
    //   print("RESULT ----> ${result.toString()}");
    //   setState(() {
    //     successful = true;
    //     failed = false;
    //   });
    // }

    // void _onPaymentPending(Transaction transaction) {
    //   print("Transaction is pending");
    //   print("Transaction Refrence ===> ${transaction.refrenceNumber}");
    // }

    // void _onPaymentFailed(Transaction transaction) {
    //   setState(() {
    //     failed = true;
    //   });
    //   print("Transaction failed");
    //   print("Transaction Message ===> ${transaction.message}");
    // }

    // void _onPaymentCancelled(Transaction transaction) {
    //   print("Transaction was cancelled");
    // }

    void processPayment(
        {BuildContext context,
        double amountPayable,
        String userEmail,
        String firstName,
        String lastName,
        String subscriptionType,
        String secretKey,
        String userUid}) async {
      try {
        Charge charge = Charge()
          ..amount = 10000
          ..reference =
              "$userUid-$subscriptionType-${DateTime.now().microsecondsSinceEpoch.toString()}"
          // or ..accessCode = _getAccessCodeFrmInitialization()
          ..email = 'customer@email.com';
        CheckoutResponse response = await plugin.checkout(
          context,
          method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
          charge: charge,
        );

        // PaystackPayManager(context: context)

        //   // Don't store your secret key on users device.
        //   // Make sure this is retrive from your server at run time
        //   ..setSecretKey(secretKey)
        //   //accepts widget
        //   ..setCompanyAssetImage(Image(
        //     height: 50,
        //     image: AssetImage("assets/images/lagbaja.png"),
        //   ))
        //   ..setAmount(amountPayable.toInt() * 100)
        //   // ..setReference("your-unique-transaction-reference")
        //   ..setReference(
        //       "$userUid-$subscriptionType-${DateTime.now().microsecondsSinceEpoch.toString()}")
        //   ..setCurrency("NGN")
        //   ..setEmail(userEmail)
        //   ..setFirstName(firstName)
        //   ..setLastName(lastName)
        //   ..setMetadata(
        //     {
        //       "custom_fields": [
        //         {
        //           "value": "snapTask",
        //           "display_name": "Payment to",
        //           "variable_name": "payment_to"
        //         }
        //       ]
        //     },
        //   )
        //   ..onSuccesful(_onPaymentSuccessful)
        //   ..onPending(_onPaymentPending)
        //   ..onFailed(_onPaymentFailed)
        //   ..onCancel(_onPaymentCancelled)
        //   ..initialize();
        print('object');
      } catch (error) {
        print("Payment Error ==> $error");
      }
    }

    print(user.uid);
    return successful
        ? successImage()
        : failed
            ? Text('failed')
            : loading
                ? SpinKitChasingDots(
                    size: 50.0,
                    color: Colors.blue,
                  )
                : Form(
                    key: _bookCleaningFormKey,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            'NGN ${totalCost.toString()}',
                            style: BoldTitleTextStyle.copyWith(
                                fontSize: 18, color: Colors.blue),
                          ),
                        ),
                        SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.text,
                                enabled: !_switchValue,
                                controller: myController,
                                validator: (val) => val.isEmpty
                                    ? 'Please fill in location'
                                    : null,
                                decoration:
                                    inputDecoration('Enter Cleaning Location'),
                                onChanged: (val) {
                                  setState(() {
                                    selectedLocation = myController.text;
                                  });
                                  print(selectedLocation);
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Switch.adaptive(
                                    value: _switchValue,
                                    onChanged: (T) {
                                      setState(() {
                                        _switchValue = !_switchValue;
                                      });
                                      if (_switchValue) {
                                        myController.text =
                                            widget.userInfo.address;
                                        selectedLocation = myController.text;
                                      }
                                    },
                                    activeColor: Colors.blue[900],
                                  ),
                                  Text(
                                    'Use Home Address',
                                    style: SmallTextStyle.copyWith(
                                        color: Colors.blue),
                                  )
                                ],
                              ),
                              DropdownButtonFormField(
                                items: buildApartmentDropdown(),
                                validator: (val) => val == null
                                    ? 'Please select house type'
                                    : null,
                                onChanged: (value) {
                                  setState(() {
                                    selectedApartmentValue = value;
                                    switch (selectedApartmentValue) {
                                      case 'Single Room':
                                        apartmentCost =
                                            PricingList().singleRoom;
                                        break;
                                      case 'Self-Contain Room':
                                        apartmentCost =
                                            PricingList().singleSelfContainRoom;
                                        break;
                                      case 'Self-Contain Room and Parlour':
                                        apartmentCost = PricingList()
                                            .roomAndParlourSelfContain;
                                        break;
                                      case '2-Bedroom Apartment':
                                        apartmentCost =
                                            PricingList().twoBedroom;
                                        break;
                                      case '3-Bedroom Apartment':
                                        apartmentCost =
                                            PricingList().threeBedroom;
                                        break;
                                      case '4-Bedroom Apartment':
                                        apartmentCost =
                                            PricingList().fourBedroom;
                                        break;
                                      case 'Duplex':
                                        apartmentCost = PricingList().duplex;
                                        break;
                                    }
                                    totalCost = levelCost + apartmentCost;
                                  });
                                },
                                icon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.blue),
                                decoration:
                                    inputDecoration('Select House Type...'),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: 'Mild',
                                    groupValue: radioValue,
                                    onChanged: (value) {
                                      setState(() {
                                        radioValue = value;
                                        levelCost = CleaningLevels().mild;
                                        totalCost = levelCost + apartmentCost;
                                      });
                                    },
                                    title: Text(
                                      'Mild Cleaning',
                                      style: BodyTextStyle,
                                    ),
                                  ),
                                  RadioListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: 'Standard',
                                    groupValue: radioValue,
                                    onChanged: (value) {
                                      setState(() {
                                        radioValue = value;
                                        levelCost = CleaningLevels().standard;
                                        totalCost = levelCost + apartmentCost;
                                      });
                                    },
                                    title: Text(
                                      'Standard Cleaning',
                                      style: BodyTextStyle,
                                    ),
                                  ),
                                  RadioListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: 'Deep',
                                    groupValue: radioValue,
                                    onChanged: (value) {
                                      setState(() {
                                        radioValue = value;
                                        levelCost = CleaningLevels().deep;
                                        totalCost = levelCost + apartmentCost;
                                      });
                                    },
                                    title: Text(
                                      'Deep Cleaning',
                                      style: BodyTextStyle,
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    stringDate != null
                                        ? stringDate
                                        : 'When do you want us to come clean?',
                                    style: BoldTitleTextStyle.copyWith(
                                        fontSize: 15, color: Colors.blue),
                                  )),
                              PopupMenuButton(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'Today':
                                      setState(() {
                                        selectedDate = DateTime.now();
                                        stringDate =
                                            dateFormat.format(selectedDate);
                                      });
                                      break;
                                    case 'Tommorrow':
                                      setState(() {
                                        selectedDate = DateTime.now()
                                            .add(Duration(days: 1));
                                        stringDate =
                                            dateFormat.format(selectedDate);
                                      });
                                      break;
                                    case 'Schedule':
                                      displayDatePicker();
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'Today',
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text(
                                        'Today',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'Tommorrow',
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text('Tomorrow',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'Schedule',
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text('Schedule Your Date',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  )
                                ],
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blue,
                                              blurRadius: 10.0)
                                        ]),
                                    child: Icon(
                                      Icons.date_range_outlined,
                                      size: 30.0,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                child: Container(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text('Book Lagbaja!',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15)),
                                      Icon(Icons.add_location_alt_rounded,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  padding: EdgeInsets.all(5),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ).copyWith(
                                  side: MaterialStateProperty.resolveWith<
                                      BorderSide>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed))
                                        return BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1,
                                        );
                                      return null; // Defer to the widget's default.
                                    },
                                  ),
                                ),
                                onPressed: () async {
                                  if (_bookCleaningFormKey.currentState
                                      .validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    print(selectedDate);
                                    print(selectedApartmentValue);
                                    print(selectedLocation);
                                    print(totalCost);

                                    CleaningSession initial =
                                        CleaningSession.initialData();
                                    processPayment(
                                        context: context,
                                        secretKey: secretKey.key,
                                        amountPayable: totalCost,
                                        userEmail: user.email,
                                        firstName: widget.userInfo.firstName,
                                        lastName: widget.userInfo.lastName,
                                        subscriptionType: initial.subscription,
                                        userUid: user.uid);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
  }
}
