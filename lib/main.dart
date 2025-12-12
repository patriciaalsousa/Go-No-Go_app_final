import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/firebase_options.dart';
import 'package:gonogo/core/inject/inject.dart';
import 'package:gonogo/models/child.dart';
import 'views/tela_inicial.dart';
import 'views/tela_criancas_avaliadas.dart';
import 'package:gonogo/views/tela_principal.dart';
import 'views/tela_editar_perfil.dart';
import 'views/tela_recuperar_senha.dart';
import 'views/tela_sobre.dart';
import 'views/tela_criancas_cadastradas.dart';
import 'views/tela_login.dart';
import 'models/utils/rotas-app.dart';
import 'views/tela_cadastro_usuario.dart';
import 'views/tela_cadastro_etapa2.dart';
import 'views/tela_cadastro_etapa3.dart';
import 'views/tela_add_crianca.dart';
import 'views/tela_add_crianca_etapa2.dart';
import 'views/tela_add_crianca_etapa3.dart';
import 'views/tela_add_crianca_perg.dart';
import 'views/tela_editar_dados_crianca.dart';
import 'views/tela_editar_financeiro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initInject();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark),
    );

    const Color corPrimaria = Color(0xFF2962C0);
    const Color corFundo = Color(0xFFF5F5F5);
    const Color corTexto = Color(0xFF292A2E);

    return MaterialApp(
      title: 'GoNoGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: corPrimaria,
        scaffoldBackgroundColor: corFundo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrimaria,
          primary: corPrimaria,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: corTexto,
          displayColor: corTexto,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: corTexto),
          titleTextStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: corTexto,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
          hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: corPrimaria, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
      initialRoute: RotasApp.login,
      routes: {
        RotasApp.inicial: (context) => const TelaInicial(),
        RotasApp.login: (context) => const TelaLogin(),
        RotasApp.recuperarSenha: (context) => const TelaRecuperarSenha(),
        RotasApp.principal: (ctx) => const TelaPrincipal(),
        RotasApp.menu: (ctx) => const TelaPrincipal(),
        RotasApp.cadastro: (context) => const TelaCadastroUsuario(),
        RotasApp.cadastroEtapa2: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TelaCadastroEtapa2(dadosEtapa1: args);
        },
        RotasApp.cadastroEtapa3: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TelaCadastroEtapa3(dadosCompletos: args);
        },
        RotasApp.addCrianca: (context) => const TelaAddCrianca1(),
        RotasApp.addCriancaEtapa2: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TelaAddCriancaEtapa2(dadosEtapa1: args);
        },
        RotasApp.addCriancaEtapa3: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TelaAddCriancaEtapa3(dadosAcumulados: args);
        },
        RotasApp.addCriancaPerg: (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return TelaAddCriancaPerg1(id: id);
        },
        RotasApp.criancasCadastradas: ((context) =>
            const TelaCriancasCadastradas()),
        RotasApp.criancasAvaliadas: (context) => const TelaCriancasAvaliadas(),
        RotasApp.editarPerfil: (context) => const TelaEditarPerfil(),
        RotasApp.sobre: (context) => const TelaSobre(),
        RotasApp.editarDadosCrianca: (context) {
          final child = ModalRoute.of(context)!.settings.arguments as Child;
          return TelaEditarDadosCrianca(child: child);
        },
        RotasApp.editarFinanceiro: (context) {
          final child = ModalRoute.of(context)!.settings.arguments as Child;
          return TelaEditarFinanceiro(child: child);
        },
      },
    );
  }
}
