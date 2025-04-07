import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const RestaurantRadarApp());
}

class RestaurantRadarApp extends StatelessWidget {
  const RestaurantRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Radar',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPopupVisible = true;

  // Function to display the popup dialog
  Future<void> _showRoleSelectionPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select your role:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPopupVisible = false; // Close popup
                    });
                    Navigator.of(context).pop(); // Close the dialog
                    // Handle selection of Provider/NGO
                  },
                  child: Text('Provider / NGO'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPopupVisible = false; // Close popup
                    });
                    Navigator.of(context).pop(); // Close the dialog
                    // Handle selection of Receiver
                  },
                  child: Text('Receiver'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Show the popup when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRoleSelectionPopup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MapScreen content
          const MapScreen(), // Reuse the existing MapScreen here

          // If the popup is visible, darken the background
          if (_isPopupVisible)
            Container(
              color: Colors.black.withOpacity(0.5), // Darken the background
            ),
        ],
      ),
    );
  }
}
