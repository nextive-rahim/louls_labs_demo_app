import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jouls_labs_demo_app/sec/feature/home/controller/home_view_controller.dart';
import 'package:jouls_labs_demo_app/sec/feature/utils/colors.dart';
import 'package:jouls_labs_demo_app/sec/feature/utils/text_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.put(HomeViewController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TextConstants.homeAppBar),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: () {
                  controller.pickDocument();
                },
                child: const Text(TextConstants.uploadFile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}