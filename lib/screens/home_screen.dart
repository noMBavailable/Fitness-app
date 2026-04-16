import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomHeader(title: "Home"),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children : const [
                  Text(
                "Next workout",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 30),
              Text(
                "24 minutes",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
    ),
              
              
              const SizedBox(height: 30),
            ],
          ),
        )
      ],
    );
  }  
}