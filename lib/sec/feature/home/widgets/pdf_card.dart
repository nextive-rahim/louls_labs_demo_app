import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:jouls_labs_demo_app/sec/feature/home/controller/home_view_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:image_to_byte/image_to_byte.dart';

class PdfViewer extends StatefulWidget {
  PdfViewer({this.file});

  final File? file;

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final controller = Get.find<HomeViewController>();

  bool isFixed = false;
  File? imageFile = File('');
  late File file;

  int currentPage = 0;
  createFile() async {
    var dir = await getApplicationDocumentsDirectory();
    file = File('${dir.path}/doc.pdf');
    file.writeAsBytes(file.readAsBytesSync());
    setState(() {});
  }

  @override
  void initState() {
    //createFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PdfWidget(
            file: widget.file!,
            offset: controller.offset ?? Offset(0.0, 0.0),
            isFixed: isFixed,
            onDragEnd: (offset) {
              controller.offset = offset;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class PdfWidget extends StatefulWidget {
  PdfWidget({
    Key? key,
    this.signatureBytes,
    required this.file,
    required this.offset,
    required this.onDragEnd,
    required this.isFixed,
  }) : super(key: key);

  Uint8List? signatureBytes;
  final File file;
  final Offset offset;
  final Function(Offset) onDragEnd;
  bool isFixed = false;

  @override
  State<PdfWidget> createState() => _PdfWidgetState();
}

class _PdfWidgetState extends State<PdfWidget> {
  int currentPage = 0;

  /// Image convert into a Uint8List file.
  void _imageToByte() async {
    Uint8List iByte = await imageToByte(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSl7Cadho1YF1TCFZRfanGSwIxnklacJPtiycrPEgtw&s');
    setState(() => widget.signatureBytes = iByte);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeViewController>();
    _imageToByte();
    return Stack(
      children: [
        Container(
          height: 700,
          child: SfPdfViewer.file(
            widget.file,
            onPageChanged: (page) {
              currentPage = page.newPageNumber;
              setState(() {});
            },
          ),
        ),
        Visibility(
          visible: widget.signatureBytes != null && !widget.isFixed,
          child: Positioned(
            top: widget.offset.dy,
            left: widget.offset.dx,
            child: Draggable(
              childWhenDragging: Container(),
              onDragUpdate: (details) {
                setState(() {
                  controller.xPosition.value = details.delta.dx;
                  controller.yPosition.value = details.delta.dy;
                });
              },
              feedback: Material(
                child: Image.network(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSl7Cadho1YF1TCFZRfanGSwIxnklacJPtiycrPEgtw&s',
                  height: 100,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              onDragEnd: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                var offset = renderBox.globalToLocal(details.offset);
                widget.onDragEnd(offset);
                print("Before Save file x =${offset.dx}");
                print("Before Save file y =${offset.dy}");
                setState(() {});
              },
              child: Column(
                children: [
                  Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSl7Cadho1YF1TCFZRfanGSwIxnklacJPtiycrPEgtw&s',
                    height: 100,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  Visibility(
                    visible: !widget.isFixed,
                    child: InkWell(
                      onTap: () async {
                        final PdfDocument document = PdfDocument(
                            inputBytes: widget.file.readAsBytesSync());
                        final PdfBitmap image =
                            PdfBitmap(widget.signatureBytes!);
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        var offset = renderBox.localToGlobal(
                            Offset(widget.offset.dx, widget.offset.dy));
                        document.pages[currentPage].graphics.drawImage(
                          image,
                          Rect.fromLTWH(offset.dx, offset.dy, 250, 150),
                        );

                        await widget.file.writeAsBytes(await document.save());
                        print("After Save file x =${offset.dx}");
                        print("After Save file y =${offset.dy}");

                        document.dispose();
                        widget.isFixed = true;
                        setState(() {});
                      },
                      child: Icon(Icons.done),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// class PDFViewerWidget extends StatefulWidget {
//   const PDFViewerWidget({
//     super.key,
//     required this.pdfLink,
//   });

//   final String pdfLink;

//   @override
//   _PDFViewerWidgetState createState() => _PDFViewerWidgetState();
// }

// class _PDFViewerWidgetState extends State<PDFViewerWidget> {
//   String urlPDFPath = "";
//   String title = "";
//   bool exists = true;
//   int _totalPages = 0;
//   int _currentPage = 0;
//   bool pdfReady = false;
//   PDFViewController? _pdfViewController;
//   bool loaded = false;
//   final homeController = Get.find<HomeViewController>();
//   void requestPermission() async {
//     await Permission.storage.request();
//   }

//   @override
//   void initState() {
//     requestPermission();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() {
//         if (homeController.pdfUploadProgressIndicator.value == true) {
//           return Center(
//             child: Text(
//               TextConstants.loading,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         }
//         return PDFView(
//           filePath: widget.pdfLink,
//           enableSwipe: true,
//           swipeHorizontal: false,
//           autoSpacing: false,
//           pageFling: true,
//           pageSnap: true,
//           fitPolicy: FitPolicy.BOTH,
//           onRender: (pages) {
//             setState(() {
//               _totalPages = pages!.toInt();
//               pdfReady = true;
//             });
//           },
//           onViewCreated: (PDFViewController vc) {
//             setState(() {
//               _pdfViewController = vc;
//             });
//           },
//           onPageChanged: (int? page, int? total) {
//             setState(() {
//               _currentPage = page!.toInt();
//             });
//           },
//         );
//       }),
//     );
//   }

//   Container _buildPageNavigation() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(00),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           SizedBox(
//             height: 41,
//             width: 130,
//             child: TextFormField(
//               textAlign: TextAlign.left,
//               textAlignVertical: TextAlignVertical.center,
//               keyboardType: TextInputType.number,
//               style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w300,
//                 fontSize: 14,
//               ),
//               onChanged: (page) {
//                 if (int.parse(page) > 0) {
//                   _pdfViewController!.setPage(
//                     int.parse(page),
//                   );
//                 }
//               },
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.only(
//                   top: 10,
//                   right: 20,
//                   bottom: 10,
//                   left: 20,
//                 ),
//                 isDense: true,
//                 hintText: 'Page Number',
//                 hintStyle: const TextStyle(
//                   fontWeight: FontWeight.w300,
//                   fontSize: 14,
//                   color: Colors.black38,
//                 ),
//                 fillColor: Colors.transparent,
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   borderSide: const BorderSide(
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   borderSide: const BorderSide(
//                     color: AppColors.primary,
//                     width: 0.5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left),
//                 iconSize: 50,
//                 color: AppColors.primary,
//                 onPressed: () {
//                   setState(
//                     () {
//                       if (_currentPage > 0) {
//                         _currentPage--;
//                         _pdfViewController!.setPage(_currentPage);
//                       }
//                     },
//                   );
//                 },
//               ),
//               Text(
//                 "${_currentPage + 1} / $_totalPages",
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 20,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.chevron_right),
//                 iconSize: 50,
//                 color: AppColors.primary,
//                 onPressed: () {
//                   setState(
//                     () {
//                       if (_currentPage < _totalPages - 1) {
//                         _currentPage++;
//                         _pdfViewController!.setPage(_currentPage);
//                       }
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
