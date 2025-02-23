// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:cart_stepper/cart_stepper.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:signature/signature.dart';
// import 'package:synthecure/src/widgets/primary_button.dart';
// import 'package:synthecure/src/constants/app_sizes.dart';
// import 'package:synthecure/src/features/orders/domain/hospital.dart';
// import 'package:synthecure/src/features/orders/domain/part.dart';
// import 'package:synthecure/src/localization/part_numbers.dart';
// import 'package:synthecure/src/localization/string_hardcoded.dart';
// import 'package:synthecure/src/utils/async_value_ui.dart';

// import '../../../../widgets/ios_style_pop_up.dart';
// import '../../../../utils/alert_dialogs.dart';
// import '../../../authentication/data/firebase_auth_repository.dart';
// import '../../data/orders_repository.dart';
// import '../../domain/order.dart';
// import '../edit_order_screen/edit_order_screen_controller.dart';
// import 'orders_screen_controller.dart';
// import 'package:http/http.dart' as http;

// class CreateOrder extends ConsumerStatefulWidget {
//   const CreateOrder({super.key, this.order, this.orderID});

//   final Order? order;
//   final OrderID? orderID;

//   @override
//   ConsumerState<CreateOrder> createState() =>
//       _CreateOrderState();
// }

// class _CreateOrderState extends ConsumerState<CreateOrder> {
//   bool autoValidate = true;
//   bool readOnly = false;
//   bool showSegmentedControl = true;
//   final _formKey = GlobalKey<FormBuilderState>();
//   final ScreenshotController screenshotController =
//       ScreenshotController();

//   String? doctorEdit;
//   Hospital? hospitalEdit;
//   DateTime? dateEdit;
//   Map<String, dynamic>? partEdit;
//   String? patientEdit;
//   Hospital? selectedHospital;
//   String? notes;
//   List<Part> products = [];
//   List<int> quantity = [];

//   final SignatureController _controller =
//       SignatureController(
//     penStrokeWidth: 1,
//     penColor: Colors.black,
//     exportBackgroundColor: Colors.white,
//     exportPenColor: Colors.black,
//     onDrawStart: () => log('onDrawStart called!'),
//     onDrawEnd: () => log('onDrawEnd called!'),
//   );

//   @override
//   void initState() {
//     super.initState();
//     if (widget.order != null) {
//       doctorEdit = widget.order!.doctor;
//       hospitalEdit = widget.order!.hospital;
//       dateEdit = widget.order!.date;
//       products = widget.order!.part;
//       quantity = List.from(
//           widget.order!.part.map((e) => e.quantity));
//       selectedHospital = widget.order!.hospital;
//       // partEdit = widget.order!.part as Map<String, dynamic>;
//       patientEdit = widget.order!.patient;
//       notes = widget.order!.notes;
//     }

//     _controller.addListener(() => log('Value changed'));
//   }

//   @override
//   void dispose() {
//     // IMPORTANT to dispose of the controller
//     _controller.dispose();
//     super.dispose();
//   }

//   bool _validateAndSaveForm() {
//     final form = _formKey.currentState!;
//     if (form.validate()) {
//       form.save();
//       return true;
//     }
//     return false;
//   }

//   Future<void> _submit(bool closeOrder) async {
//     if (_validateAndSaveForm() && (products.isNotEmpty)) {
//       final success = await ref
//           .read(editJobScreenControllerProvider.notifier)
//           .submit(
//               orderId: widget.orderID,
//               oldOrder: widget.order,
//               data: _formKey.currentState!.value,
//               products: products,
//               quantity: quantity,
//               isClosed: closeOrder);
//       if (success && mounted) {
//         context.pop();
//         if (context.canPop()) {
//           context.pop();
//         }
//       }
//     } else {
//       await showAlertDialog(
//         context: context,
//         title: 'Please fill out all of the required fields'
//             .hardcoded,
//         defaultActionText: 'Ok'.hardcoded,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state =
//         ref.watch(editJobScreenControllerProvider);
//     final user =
//         ref.watch(authRepositoryProvider).currentUser;

//     return Consumer(builder: (context, ref, child) {
//       return Scaffold(
 
//         appBar: CupertinoNavigationBar(
//           leading: IconButton(
//             icon: const Icon(CupertinoIcons.xmark),
//             onPressed: () => context.pop(),
//           ),

//           // trailing: 



            
//           //   if (widget.order != null)
//           //     IconButton(
//           //         icon: const Icon(CupertinoIcons.trash),
//           //         onPressed: () async {
//           //           final logout = await showAlertDialog(
//           //             context: context,
//           //             title:
//           //                 'Are you sure you want to delete this order?'
//           //                     .hardcoded,
//           //             cancelActionText: 'Cancel'.hardcoded,
//           //             defaultActionText: 'Delete'.hardcoded,
//           //           );
//           //           if (logout == true) {
//           //             final success = await ref
//           //                 .read(
//           //                     orderScreenControllerProvider
//           //                         .notifier)
//           //                 .deleteOrder(widget.order!);
//           //             if (success && mounted) {
//           //               // ignore: use_build_context_synchronously
//           //               context.pop();
//           //             }
//           //             // ignore: use_build_context_synchronously
//           //             context.pop();
//           //           }
//           //         }),
        
//           backgroundColor: CupertinoColors.black,
//           middle: Text(widget.order == null
//               ? 'New Order'
//               : 'Finalize Order'),
//           // actions: <Widget>[
//           //   IconButton(
//           //     icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
//           //     onPressed: () => Navigator.of(context).pop()
//           //   ),
//           // ],
//         ),
//         body: Stack(
//           alignment: Alignment.topRight,
//           children: [
//             Consumer(
//               builder: (context, ref, child) {
//                 ref.listen<AsyncValue>(
//                   orderScreenControllerProvider,
//                   (_, state) =>
//                       state.showAlertDialogOnError(context),
//                 );

//                 return Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: <Widget>[
//                           FormBuilder(
//                             key: _formKey,
//                             // enabled: false,
//                             onChanged: () {
//                               _formKey.currentState!.save();
//                               debugPrint(_formKey
//                                   .currentState!.value
//                                   .toString());
//                             },
//                             autovalidateMode:
//                                 AutovalidateMode.disabled,
//                             skipDisabled: true,
//                             child: Column(
//                               children: <Widget>[
//                                 const SizedBox(height: 15),
//                                 Container(
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                                   20)),
//                                   child: Padding(
//                                     padding:
//                                         const EdgeInsets
//                                             .all(8.0),
//                                     child:
//                                         FormBuilderDateTimePicker(
//                                       validator:
//                                           FormBuilderValidators
//                                               .compose([
//                                         FormBuilderValidators
//                                             .required(),
//                                       ]),
//                                       name: 'date',
//                                       initialEntryMode:
//                                           DatePickerEntryMode
//                                               .calendar,
//                                       initialValue:
//                                           dateEdit ??
//                                               DateTime
//                                                   .now(),
//                                       inputType:
//                                           InputType.both,
//                                       decoration:
//                                           const InputDecoration(
//                                         disabledBorder:
//                                             InputBorder
//                                                 .none,
//                                         enabledBorder:
//                                             InputBorder
//                                                 .none,
//                                         labelStyle: TextStyle(
//                                             fontWeight:
//                                                 FontWeight
//                                                     .w600,
//                                             fontSize: 16,
//                                             color: Colors
//                                                 .black),
//                                         labelText: 'Date',
//                                       ),
//                                       initialTime:
//                                           const TimeOfDay(
//                                               hour: 8,
//                                               minute: 0),
//                                       format: DateFormat(
//                                         'h:mm a MMM d, yyyy',
//                                       ),
//                                       // locale: const Locale.fromSubtags(languageCode: 'fr'),
//                                     ),
//                                   ),
//                                 ),
//                                 // Row(
//                                 //   mainAxisAlignment: MainAxisAlignment.start,
//                                 //   children: [
//                                 //     const Text('Select Hospital',
//                                 //         style: TextStyle(fontSize: 16)),
//                                 //     const Spacer(),
//                                 //     Padding(
//                                 //         padding: const EdgeInsets.symmetric(
//                                 //             horizontal: 16.0),
//                                 //       child:
//                                 gapH20,
//                                 Container(
//                                   width: double.infinity,
//                                   height: 110,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                                   20)),
//                                   child: Padding(
//                                     padding:
//                                         const EdgeInsets
//                                             .all(8.0),
//                                     child: Column(
//                                       children: [
//                                         Padding(
//                                           padding:
//                                               const EdgeInsets
//                                                   .all(8.0),
//                                           child: FormBuilderField<
//                                                   Hospital>(
//                                               name:
//                                                   'hospital',
//                                               initialValue:
//                                                   hospitalEdit,
//                                               onChanged:
//                                                   (val) {
//                                                 setState(
//                                                     () {
//                                                   hospitalEdit =
//                                                       val;
//                                                 });
//                                               },
//                                               validator:
//                                                   FormBuilderValidators
//                                                       .compose([
//                                                 FormBuilderValidators
//                                                     .required(),
//                                               ]),
//                                               builder:
//                                                   (FormFieldState
//                                                       field) {
//                                                 return Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .start,
//                                                   children: [
//                                                     Text(
//                                                         hospitalEdit?.name ??
//                                                             'Select Hospital',
//                                                         style: const TextStyle(
//                                                             fontWeight: FontWeight.w600,
//                                                             fontSize: 16,
//                                                             color: Colors.black)),
//                                                     const Spacer(),
//                                                     Padding(
//                                                       padding: const EdgeInsets
//                                                           .only(
//                                                           right: 15.0),
//                                                       child: StreamBuilder(
//                                                           stream: ref.read(hospitalQueryProvider),
//                                                           builder: (context, snapshot) {
//                                                             if (snapshot.hasError) {
//                                                               return Text('Error! ${snapshot.error}');
//                                                             } else if (snapshot.hasData) {
//                                                               final hospitals = snapshot.data!;

//                                                               return EventPopupMenuButton(
//                                                                   selectedText: '',
//                                                                   itemBuilder: (_) {
//                                                                     return hospitals
//                                                                         .map(
//                                                                           (e) => EventPopUpItem(
//                                                                               isSelected: false,
//                                                                               lableText: e.name,
//                                                                               onTap: () {
//                                                                                 _formKey.currentState!.fields['hospital']?.didChange(e);

//                                                                                 setState(() {
//                                                                                   selectedHospital = e;

//                                                                                   products = products.map((e) => e = Part(gtin: e.gtin, part: e.part, description: e.description, quantity: e.quantity, lot: e.lot, price: selectedHospital?.price[e.part] ?? 'unknown')).toList();

//                                                                                   if (products.isNotEmpty) {
//                                                                                     showSnackbar('*Prices updated');
//                                                                                   }
//                                                                                 });
//                                                                               },
//                                                                               textColor: Colors.black,
//                                                                               iconColor: Colors.black,
//                                                                               value: e.name),
//                                                                         )
//                                                                         .toList();
//                                                                   });
//                                                             } else {
//                                                               return Container();
//                                                             }
//                                                           }),
//                                                     )
//                                                   ],
//                                                 );
//                                               }),
//                                         ),
//                                         Padding(
//                                           padding:
//                                               const EdgeInsets
//                                                   .symmetric(
//                                                   horizontal:
//                                                       8.0),
//                                           child: Divider(
//                                             thickness: 0.5,
//                                             color: Colors
//                                                 .grey
//                                                 .shade400,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding:
//                                               const EdgeInsets
//                                                   .all(8.0),
//                                           child: FormBuilderField<
//                                                   String>(
//                                               name:
//                                                   'doctor',
//                                               initialValue:
//                                                   doctorEdit,
//                                               onChanged:
//                                                   (val) {
//                                                 setState(
//                                                     () {
//                                                   doctorEdit =
//                                                       val;
//                                                 });
//                                               },
//                                               validator:
//                                                   FormBuilderValidators
//                                                       .compose([
//                                                 FormBuilderValidators
//                                                     .required(),
//                                               ]),
//                                               builder:
//                                                   (FormFieldState
//                                                       field) {
//                                                 return Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .start,
//                                                   children: [
//                                                     Text(
//                                                         doctorEdit ??
//                                                             'Choose Doctor',
//                                                         style: const TextStyle(
//                                                             fontWeight: FontWeight.w600,
//                                                             fontSize: 16,
//                                                             color: Colors.black)),
//                                                     const Spacer(),
//                                                     Padding(
//                                                       padding: const EdgeInsets
//                                                           .only(
//                                                           right: 15.0),
//                                                       child: selectedHospital != null
//                                                           ? StreamBuilder(
//                                                               stream: ref.read(doctorsQueryProvider(selectedHospital!.id)),
//                                                               builder: (context, snapshot) {
//                                                                 if (snapshot.hasError) {
//                                                                   return Text('Error! ${snapshot.error}');
//                                                                 } else if (snapshot.hasData) {
//                                                                   final doctors = snapshot.data!;

//                                                                   return EventPopupMenuButton(
//                                                                       selectedText: '',
//                                                                       itemBuilder: (_) {
//                                                                         return doctors
//                                                                             .map(
//                                                                               (e) => EventPopUpItem(isSelected: false, lableText: e.name, onTap: () => _formKey.currentState!.fields['doctor']?.didChange(e.name), textColor: Colors.black, iconColor: Colors.black, value: e.name),
//                                                                             )
//                                                                             .toList();
//                                                                       });
//                                                                 } else {
//                                                                   return Container();
//                                                                 }
//                                                               })
//                                                           : const Text('select'),
//                                                     )
//                                                   ],
//                                                 );
//                                               }),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 gapH12,

//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.all(
//                                           8.0),
//                                   child: Row(
//                                     children: [
//                                       const Text(
//                                         "Add Products",
//                                         style: TextStyle(
//                                             fontWeight:
//                                                 FontWeight
//                                                     .w600,
//                                             fontSize: 16),
//                                       ),
//                                       const Spacer(),
//                                       GestureDetector(
//                                           child: const Icon(
//                                             CupertinoIcons
//                                                 .barcode_viewfinder,
//                                             color: Colors
//                                                 .black,
//                                             size: 40,
//                                           ),
//                                           onTap: () async {
//                                             if (selectedHospital !=
//                                                     null ||
//                                                 widget.order !=
//                                                     null) {
//                                               String
//                                                   barcodeScanRes =
//                                                   await FlutterBarcodeScanner.scanBarcode(
//                                                       '#87CEEB',
//                                                       'cancel',
//                                                       true,
//                                                       ScanMode
//                                                           .BARCODE);

//                                               String
//                                                   lotNumber =
//                                                   barcodeScanRes.substring(
//                                                       barcodeScanRes.length -
//                                                           8);
//                                               String gTin =
//                                                   barcodeScanRes
//                                                       .substring(
//                                                           2,
//                                                           16);

//                                               if (lotNumber
//                                                       .isNotEmpty &&
//                                                   gTin.isNotEmpty) {
//                                                 setState(
//                                                     () {
//                                                   quantity
//                                                       .add(
//                                                           1);

//                                                   products.add(Part(
//                                                       gtin:
//                                                           gTin,
//                                                       part: productChart[gTin]!
//                                                           .part,
//                                                       description: productChart[gTin]!
//                                                           .description,
//                                                       lot:
//                                                           lotNumber,
//                                                       quantity:
//                                                           1,
//                                                       price:
//                                                           selectedHospital!.price[productChart[gTin]!.part] ?? "unknown"));
//                                                 });
//                                               }
//                                             } else {
//                                               showAlertDialog(
//                                                   context:
//                                                       context,
//                                                   title:
//                                                       'Select a Hospital',
//                                                   defaultActionText:
//                                                       'close');
//                                             }
//                                           }),
//                                       gapW12,
//                                       GestureDetector(
//                                         onTap: () async {
//                                           if (selectedHospital !=
//                                                   null ||
//                                               widget.order !=
//                                                   null) {
//                                             await addProductDialog();
//                                           } else {
//                                             showAlertDialog(
//                                                 context:
//                                                     context,
//                                                 title:
//                                                     'Select a Hospital',
//                                                 defaultActionText:
//                                                     'close');
//                                           }
//                                         },
//                                         child: CircleAvatar(
//                                           backgroundColor:
//                                               Colors.grey[
//                                                   300],
//                                           radius: 18,
//                                           child: const Icon(
//                                             CupertinoIcons
//                                                 .add,
//                                             size: 20,
//                                             color: Colors
//                                                 .black,
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),

//                                 Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(25),
//                                       color: Colors.white),
//                                   child: ListView.builder(
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       shrinkWrap: true,
//                                       itemBuilder:
//                                           (context, index) {
//                                         return Slidable(
//                                             key: ValueKey(
//                                                 index),
//                                             endActionPane:
//                                                 ActionPane(
//                                               motion:
//                                                   const ScrollMotion(),
//                                               children: [
//                                                 SlidableAction(
//                                                   // An action can be bigger than the others.
//                                                   flex: 2,
//                                                   onPressed:
//                                                       (context) {
//                                                     setState(
//                                                         () {
//                                                       products
//                                                           .removeAt(index);
//                                                       quantity
//                                                           .removeAt(index);
//                                                     });
//                                                   },
//                                                   backgroundColor:
//                                                       Colors
//                                                           .red,
//                                                   foregroundColor:
//                                                       Colors
//                                                           .white,
//                                                   icon: CupertinoIcons
//                                                       .trash,
//                                                   label:
//                                                       'Remove',
//                                                 ),
//                                               ],
//                                             ),
//                                             child: ListTile(
//                                               title:

//                                                   // Text(
//                                                   //   "#${products[index]["part"]!}",
//                                                   //   style: const TextStyle(
//                                                   //       fontWeight:
//                                                   //           FontWeight.w500),
//                                                   (products[index].gtin !=
//                                                           "unknown")
//                                                       ? Text(
//                                                           products[index].description,
//                                                           style: const TextStyle(fontWeight: FontWeight.w500),
//                                                         )
//                                                       : const Text(
//                                                           "Unknown Product",
//                                                           style: TextStyle(fontWeight: FontWeight.w500)),
//                                               subtitle:
//                                                   Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment
//                                                         .start,
//                                                 children: [
//                                                   gapH4,
//                                                   Text(
//                                                       "# ${products[index].part}",
//                                                       style: const TextStyle(
//                                                           fontSize: 14,
//                                                           fontWeight: FontWeight.w500)),
//                                                   Text(
//                                                     "# ${products[index].lot}",
//                                                     style: const TextStyle(
//                                                         fontSize:
//                                                             14,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                   Text(
//                                                     "\$ ${products[index].price}",
//                                                     style: const TextStyle(
//                                                         fontSize:
//                                                             14,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                 ],
//                                               ),
//                                               trailing:
//                                                   SizedBox(
//                                                 height: 40,
//                                                 child: CartStepper(
//                                                     size: 35,
//                                                     numberSize: 0.7,
//                                                     style: const CartStepperStyle(
//                                                       foregroundColor:
//                                                           Colors.black87,
//                                                       activeForegroundColor:
//                                                           Colors.black,
//                                                       activeBackgroundColor:
//                                                           Colors.transparent,
//                                                       iconMinus:
//                                                           CupertinoIcons.minus_circle_fill,
//                                                       iconPlus:
//                                                           CupertinoIcons.add_circled_solid,
//                                                       elevation:
//                                                           0,
//                                                       buttonAspectRatio:
//                                                           1.5,
//                                                     ),
//                                                     stepper: 1,
//                                                     value: quantity[index],
//                                                     didChangeCount: (value) {
//                                                       setState(
//                                                           () {
//                                                         products =
//                                                             products.map((e) => e = Part(gtin: e.gtin, part: e.part, description: e.description, quantity: (products.indexOf(e) == index) ? value : e.quantity, lot: e.lot, price: e.price)).toList();

//                                                         quantity[index] =
//                                                             value;
//                                                         if (value ==
//                                                             0) {
//                                                           products.removeAt(index);

//                                                           quantity.removeAt(index);
//                                                         }
//                                                       });
//                                                     }),
//                                               ),
//                                             ));
//                                       },
//                                       itemCount:
//                                           products.length),
//                                 ),

//                                 gapH12,
//                                 Container(
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                                   20)),
//                                   child: Padding(
//                                     padding:
//                                         const EdgeInsets
//                                             .symmetric(
//                                             horizontal:
//                                                 8.0),
//                                     child:
//                                         FormBuilderTextField(
//                                       validator:
//                                           FormBuilderValidators
//                                               .compose([
//                                         FormBuilderValidators
//                                             .required(),
//                                       ]),
//                                       name: 'patient',
//                                       initialValue:
//                                           patientEdit,
//                                       decoration:
//                                           const InputDecoration(
//                                         border: InputBorder
//                                             .none,
//                                         labelStyle: TextStyle(
//                                             fontWeight:
//                                                 FontWeight
//                                                     .w600,
//                                             fontSize: 16,
//                                             color: Colors
//                                                 .black),
//                                         labelText:
//                                             'Patient ID',
//                                       ),
//                                       onChanged: (val) {
//                                         setState(() {});
//                                       },
//                                       // valueTransformer: (text) => num.tryParse(text),

//                                       // initialValue: '12',

//                                       textInputAction:
//                                           TextInputAction
//                                               .done,
//                                     ),
//                                   ),
//                                 ),
//                                 gapH20,

//                                 Center(
//                                   child: Container(
//                                     padding:
//                                         const EdgeInsets
//                                             .symmetric(
//                                             horizontal:
//                                                 8.0),
//                                     height: 120,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                         borderRadius:
//                                             BorderRadius
//                                                 .circular(
//                                                     20),
//                                         color:
//                                             Colors.white),
//                                     child:
//                                         FormBuilderTextField(
//                                       inputFormatters: const [
//                                         // MaxLinesTextInputFormatter(5, null)
//                                       ],

//                                       maxLengthEnforcement:
//                                           MaxLengthEnforcement
//                                               .enforced,
//                                       maxLines:
//                                           5, // allow user to enter 5 line in textfield
//                                       keyboardType:
//                                           TextInputType
//                                               .multiline,
//                                       name: 'notes',
//                                       initialValue: notes,
//                                       style:
//                                           const TextStyle(
//                                               fontWeight:
//                                                   FontWeight
//                                                       .w500,
//                                               fontSize: 16),
//                                       decoration:
//                                           const InputDecoration(
//                                         hintText: 'Notes',
//                                         hintStyle: TextStyle(
//                                             color: Colors
//                                                 .black,
//                                             fontWeight:
//                                                 FontWeight
//                                                     .w500),
//                                         border: InputBorder
//                                             .none,
//                                         focusedBorder:
//                                             InputBorder
//                                                 .none,
//                                         enabledBorder:
//                                             InputBorder
//                                                 .none,
//                                         errorBorder:
//                                             InputBorder
//                                                 .none,
//                                         disabledBorder:
//                                             InputBorder
//                                                 .none,
//                                       ),
//                                       onChanged: (val) {
//                                         setState(() {});
//                                       },
//                                       // valueTransformer: (text) => num.tryParse(text),
//                                       validator:
//                                           FormBuilderValidators
//                                               .compose([
//                                         FormBuilderValidators
//                                             .maxLength(100),
//                                       ]),
//                                       // initialValue: '12',
//                                       textInputAction:
//                                           TextInputAction
//                                               .done,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           if (widget.order != null)
//                             Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 const Padding(
//                                   padding:
//                                       EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'Signature box',
//                                     style: TextStyle(
//                                         color: Colors.black,
//                                         fontWeight:
//                                             FontWeight.w500,
//                                         fontSize: 16),
//                                   ),
//                                 ),
//                                 Container(
//                                   height: 70,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                                   20)),
//                                   child: Signature(
//                                     key: const Key(
//                                         'signature'),
//                                     controller: _controller,
//                                     height: 60,
//                                     backgroundColor:
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                               ],
//                             ),

//                           Row(
//                             children: <Widget>[
//                               Expanded(
//                                 child: Padding(
//                                     padding:
//                                         const EdgeInsets
//                                             .all(16.0),
//                                     child: PrimaryButton(
//                                       isLoading:
//                                           state.isLoading,
//                                       onPressed: () {
//                                         _submit(false);
//                                       },
//                                       text: widget.order ==
//                                               null
//                                           ? 'Submit'
//                                           : 'Update',
//                                     )),
//                               ),
//                             ],
//                           ),
//                           // if (widget.order != null)
//                           //   Row(
//                           //     children: <Widget>[
//                           //       Expanded(
//                           //         child: Padding(
//                           //           padding: const EdgeInsets.symmetric(
//                           //               horizontal: 16.0),
//                           //           child: PrimaryButton(
//                           //             isLoading: state.isLoading,
//                           //             onPressed: () {
//                           //               print('hit close order');

//                           //               _submit(true);
//                           //             },
//                           //             text: 'Close Order',
//                           //           ),
//                           //         ),
//                           //       ),
//                           //     ],
//                           //   ),
//                         ],
//                       ),
//                     ));
//               },
//             ),
//             if (widget.order != null)
//               Positioned(
//                   child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                     height: 50,
//                     width: 50,
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(
//                           Radius.circular(15)),
//                       color: Colors.greenAccent,
//                     ),
//                     child: IconButton(
//                         onPressed: () async {
//                           if (_controller.isNotEmpty) {
//                             if (_validateAndSaveForm()) {
//                               showCapturedWidget(
//                                   context,
//                                   _formKey
//                                       .currentState!.value,
//                                   user);
//                             }
//                           } else {
//                             await showAlertDialog(
//                               context: context,
//                               title:
//                                   'Please add your Signature'
//                                       .hardcoded,
//                               defaultActionText:
//                                   'Ok'.hardcoded,
//                             );
//                           }
//                         },
//                         icon: const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 30,
//                         ))),
//               )),
//           ],
//         ),
//       );
//     });
//   }

//   Future addProductDialog() {
//     final TextEditingController partController =
//         TextEditingController();
//     final TextEditingController lotController =
//         TextEditingController();

//     return showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               title: const Text("Add Product"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CupertinoTextField(
//                     autofocus: true,
//                     controller: partController,
//                     decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(20)),
//                     placeholder: "Part Number#",
//                   ),
//                   gapH12,
//                   CupertinoTextField(
//                     controller: lotController,
//                     decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(20)),
//                     placeholder: "Lot Number#",
//                   ),
//                   gapH16,
//                   CupertinoButton(
//                       color: Colors.lightBlueAccent,
//                       child: const Text(
//                         'Submit',
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       onPressed: () {
//                         if (partController
//                                 .text.isNotEmpty &&
//                             lotController.text.isNotEmpty) {
//                           setState(() {
//                             quantity.add(1);

//                             products.add(Part(
//                                 gtin: partToGtin[
//                                             partController
//                                                 .text] !=
//                                         null
//                                     ? partToGtin[partController.text]!
//                                         .gtin
//                                     : "unknown",
//                                 part: partController.text,
//                                 description: partToGtin[
//                                             partController
//                                                 .text] !=
//                                         null
//                                     ? partToGtin[partController.text]!
//                                         .description
//                                     : "unknown",
//                                 quantity: 1,
//                                 lot: lotController.text,
//                                 price: selectedHospital!.price[
//                                         partController.text] ??
//                                     'unknown'));
//                           });
//                           context.pop();
//                         }
//                       })
//                 ],
//               ),
//             ));
//   }

//   Future<dynamic> showCapturedWidget(BuildContext context,
//       Map<String, dynamic> data, User? user) {
//     final Order model = Order.fromFormMap(
//         data, widget.orderID!, true, products);

//     return showDialog(
//       useSafeArea: false,
//       context: context,
//       builder: (context) => Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: AppBar(
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.send_sharp),
//                 onPressed: () {
//                   //_submit(true);
//                   EasyLoading.show(
//                       status: 'Processing order',
//                       maskType: EasyLoadingMaskType.black);

//                   screenshotController
//                       .capture(
//                           delay: const Duration(
//                               milliseconds: 10))
//                       .then((capturedImage) async {


//                     final image = await createTemporaryImageFile(
//                         capturedImage!);

//                     await launchEmail(
//                         toEmail: 'orders@synthecure.com',
//                         cc: model.hospital.email ?? "",
//                         subject: 'Purchase Order Request',
//                         order: model,
//                         image: image

//                         );

//                     // await sendEmail(
//                     //     name: user!.email!,
//                     //     email: 'synthecure@gmail.com',
//                     //     subject: 'Submitted Order',
//                     //     order: model);

//                     //_submit(true);

//                     EasyLoading.dismiss();
//                   }).catchError((onError) {});
//                 },
//               ),
//             ],
//             backgroundColor: Colors.black,
//             title: const Text("Review your Order"),
//           ),
//           body: Column(
//             children: [
//               gapH16,
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Screenshot(
//                   controller: screenshotController,
//                   child: Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(12),
//                       ),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         width: double.infinity,
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             RichText(
//                               text: TextSpan(
//                                 text: 'Order: ',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                   fontWeight:
//                                       FontWeight.bold,
//                                 ),
//                                 children: <TextSpan>[
//                                   TextSpan(
//                                       text: '#${model.id}',
//                                       style:
//                                           const TextStyle(
//                                               fontWeight:
//                                                   FontWeight
//                                                       .w500,
//                                               fontSize:
//                                                   12)),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(
//                                       left: 8.0),
//                               child: Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment
//                                           .start,
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment
//                                           .start,
//                                   children: [
//                                     RichText(
//                                       text: TextSpan(
//                                         text: 'Date: ',
//                                         style:
//                                             const TextStyle(
//                                           fontSize: 12,
//                                           color:
//                                               Colors.black,
//                                           fontWeight:
//                                               FontWeight
//                                                   .bold,
//                                         ),
//                                         children: <TextSpan>[
//                                           TextSpan(
//                                               text:
//                                                   '${DateFormat.yMd().format(model.date)} at ${DateFormat.jm().format(model.date)}',
//                                               style: const TextStyle(
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .w500,
//                                                   fontSize:
//                                                       12)),
//                                         ],
//                                       ),
//                                     ),
//                                     gapH4,
//                                     RichText(
//                                       text: TextSpan(
//                                         text: 'Hospital: ',
//                                         style:
//                                             const TextStyle(
//                                           fontSize: 12,
//                                           color:
//                                               Colors.black,
//                                           fontWeight:
//                                               FontWeight
//                                                   .bold,
//                                         ),
//                                         children: <TextSpan>[
//                                           TextSpan(
//                                               text: model
//                                                   .hospital
//                                                   .name,
//                                               style: const TextStyle(
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .w500,
//                                                   fontSize:
//                                                       12)),
//                                         ],
//                                       ),
//                                     ),
//                                     gapH4,
//                                     RichText(
//                                       text: TextSpan(
//                                         text: 'Doctor: ',
//                                         style:
//                                             const TextStyle(
//                                           fontSize: 12,
//                                           color:
//                                               Colors.black,
//                                           fontWeight:
//                                               FontWeight
//                                                   .bold,
//                                         ),
//                                         children: <TextSpan>[
//                                           TextSpan(
//                                               text: model
//                                                   .doctor,
//                                               style: const TextStyle(
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .w500,
//                                                   fontSize:
//                                                       12)),
//                                         ],
//                                       ),
//                                     ),
//                                     gapH4,
//                                     RichText(
//                                       text: TextSpan(
//                                         text:
//                                             'Patient ID: ',
//                                         style:
//                                             const TextStyle(
//                                           fontSize: 12,
//                                           color:
//                                               Colors.black,
//                                           fontWeight:
//                                               FontWeight
//                                                   .bold,
//                                         ),
//                                         children: <TextSpan>[
//                                           TextSpan(
//                                               text: model
//                                                   .patient,
//                                               style: const TextStyle(
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .w500,
//                                                   fontSize:
//                                                       12)),
//                                         ],
//                                       ),
//                                     ),
//                                     gapH4,
//                                     ListView.builder(
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       shrinkWrap: true,
//                                       itemBuilder:
//                                           (context, index) {
//                                         return ListTile(
//                                           minLeadingWidth:
//                                               1,
//                                           leading: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .center,
//                                             children: [
//                                               Text(model
//                                                   .part[
//                                                       index]
//                                                   .quantity
//                                                   .toString())
//                                             ],
//                                           ),
//                                           title: Text(model
//                                               .part[index]
//                                               .description),
//                                           subtitle: Text(
//                                               model
//                                                   .part[
//                                                       index]
//                                                   .part),
//                                           trailing: Text(
//                                               "\$ ${model.part[index].price}"),
//                                         );
//                                       },
//                                       itemCount:
//                                           model.part.length,
//                                     ),
//                                   ]),
//                             )
//                           ],
//                         ),
//                       )),
//                 ),
//               ),
//             ],
//           )),
//     );
//   }

//   Future<void> launchEmail({
//     required String toEmail,
//     required String cc,
//     required String subject,
//     required Order order,
//     required File image,
//   }) async {
//     final Email email = Email(
//       subject: subject,
//       recipients: [toEmail],
//       cc: [cc],
//       bcc: ['bcc@example.com'],
//       attachmentPaths: [image.path],
//       isHTML: false,
//     );

//     await FlutterEmailSender.send(email);

//     // final url = Uri.parse(
//     //     'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull("Order ID : ${order.id}\n Date : ${order.date}\n Hospital: ${order.hospital.name}\n Doctor : ${order.doctor}\n Patient ID : ${order.patient}\n\n Products: ${order.part}\n Notes : ${order.notes}")}');

//     // if (await canLaunchUrl(url)) {
//     //   await launchUrl(url);
//     // }
//   }

//   // String convertUint8ListToDataUri(Uint8List imageBytes) {
//   //   final base64Image = base64Encode(imageBytes);
//   //   const mimeType =
//   //       'image/png'; // Adjust the MIME type according to your image format

//   //   return 'data:$mimeType;base64,$base64Image';
//   // }

//   // String createEmailBodyWithImage(String imageDataUri) {
//   //   return '''
//   //   <html>
//   //     <body>
//   //       <p>Email Body with an Image</p>
//   //       <img src="$imageDataUri" alt="Image" />
//   //     </body>
//   //   </html>
//   // ''';
//   // }

//   Future<File> createTemporaryImageFile(
//       Uint8List imageBytes) async {
//     final tempDir = await getTemporaryDirectory();
//     final tempImagePath = '${tempDir.path}/temp_image.png';

//     final tempImageFile = File(tempImagePath);
//     await tempImageFile.writeAsBytes(imageBytes);


//     return tempImageFile;
//   }

//   // Future sendEmail() async {
//   //   const email = 'parkersherrill24@yahoo.com';

//   //   final smtpServer = gmailSaslXoauth2(email, token);

//   //   final message = Message()
//   //     ..from = (Address(email, 'Parker'))
//   //     ..subject = 'Testing send email'
//   //     ..text = 'Email context';
//   //   try {
//   //     await send(message, smtpServer);

//   //     showSnackbar('Sent email successfully');
//   //   } on MailerException catch (e) {
//   //     showExceptionAlertDialog(
//   //         context: context, title: 'Error sending email', exception: e);
//   //   }
//   // }

//   void showSnackbar(String text) {
//     final snackBar = SnackBar(
//         backgroundColor: CupertinoColors.black,
//         behavior: SnackBarBehavior.floating,
//         content: Text(
//           text,
//           style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.white),
//         ));

//     ScaffoldMessenger.of(context)
//       ..removeCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }

// //   Future sendEmail({
// //     required String toEmail,
// //     required String subject,
// //     required String message,
// //     required Uint8List image,
// //   }) async {
// //     // final imageDataUri = convertUint8ListToDataUri(image);
// //     //final body = createEmailBodyWithImage(imageDataUri);

// //     final Uri uri = Uri(
// //       scheme: 'mailto',
// //       path: toEmail,
// //       queryParameters: {
// //         'subject': Uri.encodeQueryComponent('Email Subject'),
// //         'body': Uri.encodeQueryComponent('Email Body'),
// //       },
// //     );

// //     // final Uri fileUri = Uri.file(imagePath);
// //     // final String encodedFileUri = Uri.encodeQueryComponent(fileUri.toString());

// //     // final String urlString = uri.replace(queryParameters: {
// //     //   ...uri.queryParameters,
// //     //   'attachment': encodedFileUri,
// //     // }).toString();

// //     final url = uri.toString();

// //     // final url =
// //     //     'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.dataFromString(imageDataUri, mimeType: 'image/png', base64:true, encoding: Encoding.getByName(name))}';

// //     if (await canLaunchUrlString(url)) {
// //       await launchUrlString(url);
// //     }
// //   }
// // }

//   Future sendEmail({
//     required String name,
//     required String email,
//     required String subject,
//     required Order order,
//   }) async {
//     try {
//       const serviceId = 'service_y2ffkys';
//       const templateId = 'template_01zddb3';
//       const userId = 'Y8wl3FDLfU2_5788d';

//       final message =
//           "Order ID : ${order.id}\n Date : ${order.date}\n Hospital: ${order.hospital.name}\n Doctor : ${order.doctor}\n Patient ID : ${order.patient}\n\n Products: ${order.part}\n Notes : ${order.notes}";

//       final url = Uri.parse(
//           'https://api.emailjs.com/api/v1.0/email/send');

//       // ignore: unused_local_variable
//       final response = await http.post(url,
//           headers: {
//             'origin': 'http://localhost',
//             'Content-Type': 'application/json'
//           },
//           body: json.encode({
//             'service_id': serviceId,
//             'template_id': templateId,
//             'user_id': userId,
//             'template_params': {
//               'user_name': name,
//               'user_email': email,
//               'user_subject': subject,
//               'user_message': message
//             }
//           }));

//       //showSnackbar('Sent email successfully');
//     } on HttpException catch (e) {
//       showExceptionAlertDialog(
//           // ignore: use_build_context_synchronously
//           context: context,
//           title: 'Error sending email',
//           exception: e);
//     }
//   }
// }

// class JobListTile extends StatelessWidget {
//   const JobListTile(
//       {super.key, required this.job, this.onTap});
//   final Order job;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(job.doctor),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap,
//     );
//   }


  
// }


