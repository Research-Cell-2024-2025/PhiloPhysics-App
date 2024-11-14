import 'dart:async';
import 'package:ephysicsapp/globals/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_screenshot/no_screenshot.dart';

class PDFScreen extends StatefulWidget {
  final String path, title;

  PDFScreen({Key? key, required this.path, required this.title}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NoScreenshot.instance.screenshotOff();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NoScreenshot.instance.screenshotOn(); // Allow screenshots when disposing.
    super.dispose();
  }

  // Function to go to the previous page
  void goToPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      _controller.future.then((pdfViewController) {
        pdfViewController.setPage(currentPage);
      });
    }
  }

  // Function to go to the next page
  void goToNextPage() {
    if (currentPage < pages - 1) {
      setState(() {
        currentPage++;
      });
      _controller.future.then((pdfViewController) {
        pdfViewController.setPage(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Row for positioning the arrows
          Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,  // Align buttons to the right
              children: [
                // Left arrow button (previous page)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,  // Arrow for page back
                    color: currentPage == 0 ? Colors.grey : Colors.black,  // Disable when on the first page
                  ),
                  onPressed: currentPage == 0 ? null : goToPreviousPage,  // Disable action when on the first page
                ),

                // Add some spacing between the arrows
                SizedBox(width: MediaQuery.of(context).size.width / 300),  // You can adjust the width to control the gap
                // Right arrow button (next page)
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_rounded,  // Arrow for page forward
                    color: currentPage == pages - 1 || pages == 1 ? Colors.grey : Colors.black,  // Disable when on the last page
                  ),
                  onPressed: currentPage == pages - 1 || pages == 1 ? null : goToNextPage,  // Disable action when on the last page
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: false,
            pageSnap: true,
            fitEachPage: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (_pages) {
              setState(() {
                pages = _pages!;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) async {
              _controller.complete(pdfViewController);

              // Add a slight delay and refresh the page to solve the blank screen issue
              await Future.delayed(Duration(milliseconds: 100));
              pdfViewController.setPage(currentPage);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page!;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container()
              : Center(
            child: Text(errorMessage),
          )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              backgroundColor: color5,
              label: Text(
                "Page ${currentPage + 1}/$pages",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // Optional: Uncomment if you want to navigate to the middle of the PDF.
                // await snapshot.data.setPage(pages ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
