import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow only portrait orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

//SPLASHSCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
//SET STATE
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CalculatorDesign()),
      );
    });
  }

  //STRUCTURE
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        color:Colors.white,
        alignment: Alignment.center,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Image.asset("assets/logo.png",height: 100,width: 100,),
            SizedBox(height:10),
            Text(
              "Calculator",style:TextStyle(fontSize: 20,fontWeight: FontWeight.w600)
            )
          ]
        )
      )
    );
  }
}

//CALC
class CalculatorDesign extends StatefulWidget {
  const CalculatorDesign({super.key});

  @override
  State<CalculatorDesign> createState() => _CalculatorDesignState();
}
class _CalculatorDesignState extends State<CalculatorDesign> {
  String displayText = "0";
  double? firstNumber;
  String operator = "";
  bool shouldResetDisplay = false;
  late TextEditingController displayController;

  final List<List<String>> buttons = const [
    ["AC", "C", "%", "÷"],
    ["7", "8", "9", "×"],
    ["4", "5", "6", "-"],
    ["1", "2", "3", "+"],
    ["0", ".", "="],
  ];

  @override
  void initState() {
    super.initState();
    displayController = TextEditingController(text: displayText);
  }

  @override
  void dispose() {
    displayController.dispose();
    super.dispose();
  }

  //ON-PRESS FUNCTIONS
  void onButtonPressed(String text) {
    setState(() {
      if (text == "C") {
        if (displayText.length > 1) {
          displayText = displayText.substring(0, displayText.length - 1);
        } else {
          displayText = "0";
        }
      } else if (text == "AC") {
        displayText = "0";
        firstNumber = null;
        operator = "";
        shouldResetDisplay = false;
      } else if (text == "=") {
        try {
          String expression = displayText;

          expression = expression.replaceAll("×", "*");
          expression = expression.replaceAll("÷", "/");

          final parser = ShuntingYardParser();
          final exp = parser.parse(expression);
          final cm = ContextModel();

          double result = exp.evaluate(EvaluationType.REAL, cm);

          displayText = _formatResult(result);
          shouldResetDisplay = false;
        } catch (e) {
          displayText = "Error";
          shouldResetDisplay = true;
        }
      } else if (["÷", "×", "-", "+"].contains(text)) {
        if (displayText.isNotEmpty) {
          // If last character is an operator, replace it
          if (["÷", "×", "-", "+"].contains(displayText.characters.last)) {
            displayText =
                displayText.substring(0, displayText.length - 1) + text;
          } else {
            displayText += text;
          }
          operator = text; // store last operator
        }
      } else if (text == "%") {
        double number = double.tryParse(displayText) ?? 0;
        displayText = _formatResult(number / 100);
        shouldResetDisplay = true;
      } else {
        if (displayText == "0" || shouldResetDisplay) {
          displayText = text;
          shouldResetDisplay = false;
        } else {
          displayText += text;
        }
      }

      displayController.text = displayText;
    });
  }

  // //OPERATIONS-FUNCTIONALITIES
  // double _calculate(double first, double second, String op) {
  //   switch (op) {
  //     case "+":
  //       return first + second;
  //     case "-":
  //       return first - second;
  //     case "×":
  //       return first * second;
  //     case "÷":
  //       return second != 0 ? first / second : 0;
  //     default:
  //       return second;
  //   }
  // }

  //RESULT DISPLAY
  String _formatResult(double result) {
    return result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(3);
  }

  //WIDGET-BUTTON
  Widget buildButton(
    String text, {
    int flex = 1,
    Color color = const Color(0xFFEBEAE8),
  }) {
    final isOperator = ["÷", "×", "-", "+", "="].contains(text);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth / 4.9;

    // ZERO BUTTON
    if (text == "0") {
      return Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.all(6),
          height: buttonSize,
          child: ElevatedButton(
            onPressed: () => onButtonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonSize / 2),
              ),
              padding: const EdgeInsets.only(left: 30),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "0",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    //BUTTONS
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(5),
        height: buttonSize,
        width: buttonSize,
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isOperator ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  //STRUCTURE
  @override
  Widget build(BuildContext context) {
    const operatorColor = Color(0xFFFF9500);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // DISPLAY
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(20),
                child: TextField(
                  readOnly: true,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 70,
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                  controller: displayController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),

            // BUTTONS
            Column(
              children: buttons.map((row) {
                return Row(
                  children: row.map((btn) {
                    if (btn == "0") {
                      return buildButton(btn, flex: 2);
                    } else if (["÷", "×", "-", "+", "="].contains(btn)) {
                      return buildButton(btn, color: operatorColor);
                    } else {
                      return buildButton(btn);
                    }
                  }).toList(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
