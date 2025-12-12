import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/models/utils/rotas-app.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.25),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.2),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 149,
                  height: 34,
                  child: Text(
                    'GONOGO',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: const Color(0xFF4285F4),
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                SizedBox(
                  width: 304,
                  child: Text(
                    'Lorem ipsum dolor sit amet consectetur. Nibh praesent fames et ultricies sodales eu in tincidunt morbi. Placerat sit malesuada nullam nam et elit viverra.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: const Color(0xFF636363),
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.08),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RotasApp.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Começar',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
