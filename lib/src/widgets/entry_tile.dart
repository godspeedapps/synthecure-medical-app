
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/order.dart' show Order;
import 'package:synthecure/src/routing/app_router.dart';

class EntriesListTile extends StatelessWidget {
  const EntriesListTile({super.key, required this.model});

  final Order model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 0),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(
            AppRoute.entryView.name,
            extra: model,
          );

          //  context.pushNamed(
          //   AppRoute.editOrder.name,
          //   extra: model,
          // );
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat.yMd().format(model.date)} at ${DateFormat.jm().format(model.date)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall,
                          ),
                          const CupertinoListTileChevron()
                        ],
                      ),
                      gapH4,
                      Opacity(
                          opacity: 0.4,
                          child: Text(
                            '#${model.id}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                          )),
                      gapH12,
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    'Status',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  )),
                              gapH8,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          model.isClosed
                                              ? "Delivered"
                                              : "Pending",
                                          style: Theme.of(
                                                  context)
                                              .textTheme
                                              .bodyMedium),
                                      gapW4,
                                      CircleAvatar(
                                        backgroundColor:
                                            model.isClosed
                                                ? Colors
                                                    .green
                                                : Colors
                                                    .amber,
                                        radius: 4,
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          gapW48,
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Opacity(
                                    opacity: 0.6,
                                    child: Text(
                                      'Hospital',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    )),
                                gapH8,
                                Text(model.hospital.name,
                                overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );

    // ListTile(
    //     title: Text(
    //   model.date.toString(),
    //   //           style: const TextStyle(fontSize: fontSize)),
    // ));
    // return Container(
    //   color: Colors.indigo[100],
    //   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    //   child: Row(
    //     children: <Widget>[
    //       Text(model.date.toString(),
    //           style: const TextStyle(fontSize: fontSize)),
    //       Expanded(child: Container()),
    //       Text(
    //         model.doctor,
    //         style: TextStyle(color: Colors.green[700], fontSize: fontSize),
    //         textAlign: TextAlign.right,
    //       ),
    //       SizedBox(
    //         width: 60.0,
    //         child: Text(
    //           model.hospital,
    //           style: const TextStyle(fontSize: fontSize),
    //           textAlign: TextAlign.right,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
