import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonogo/controller/controller_evaluator.dart';
import 'package:gonogo/models/child.dart';
import 'package:gonogo/models/sequencia.dart';
import 'package:intl/intl.dart';

class ControllerChildren {
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> loadChildren() async {
    String identificacao = await ControllerEvaluator().identificacao();
    FirebaseFirestore db = FirebaseFirestore.instance;
    final stream = db
        .collection("Criancas")
        .doc(identificacao)
        .collection("dados")
        .orderBy("nome", descending: false)
        .snapshots();
    return stream;
  }

  Future<String> registerChild(Map<String, dynamic> child) async {
    String identificacao = await ControllerEvaluator().identificacao();

    final crianca = Child(
      "",
      child["name"],
      child["date_birth"],
      child["color"],
      child["sex"] ?? "Indefinido",
      child["income"],
      child["time_gadgets"],
      child["time_play"],
      child["time_out"],
      0,
      child["photo_url"] ?? "",
    );

    DocumentReference ref = await FirebaseFirestore.instance
        .collection("Criancas")
        .doc(identificacao)
        .collection("dados")
        .add(
      {
        "nome": crianca.completeName,
        "data_de_nascimento": crianca.date,
        "data_avaliacao": child["date_evaluation"] ?? "",
        "cor": crianca.color,
        "sexo": crianca.sex,
        "renda": crianca.income,
        "tempo_aparelhos": crianca.timeGadgets,
        "tempo_em_casa": crianca.timePlay,
        "tempo_fora": crianca.timeOut,
        "foto_perfil": crianca.photoUrl,
        "perguntas": {},
        "boolTestes": crianca.boolTests,
      },
    );
    return ref.id;
  }

  addPerguntas(String id, List<int> valores) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String identificacao = await ControllerEvaluator().identificacao();
    db
        .collection("Criancas")
        .doc(identificacao)
        .collection("dados")
        .doc(id)
        .update({
      "perguntas": {
        "Tem dificuldade de manter a atenção em tarefas ou atividades de lazer.":
            valores[0],
        "Não segue instruções até o fim e não termina deveres de escola, tarefas ou obrigações.":
            valores[1],
        "Tem dificuldade em se envolver tarefas que exigem esforço mental prolongado.":
            valores[2],
        "Responde as perguntas de forma precipitada antes delas terem sido terminadas.":
            valores[3],
      }
    });
  }

  salvarTeste(String id, List<int> indices, String tipo, int boolTeste) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String dataFormatada = formatter.format(now);

    final numeros = indices.toSet().toList();
    int errou = 0;
    int acertou = 0;
    int omitiu = 0;
    String identificacao = await ControllerEvaluator().identificacao();
    for (int i = 0; i < sequenciaLista.length; i++) {
      for (int j = 0; j < numeros.length; j++) {
        if (sequenciaLista[i] == 6 && numeros[j] == i) {
          errou++;
        } else if (sequenciaLista[i] != 6 && numeros[j] == i) {
          acertou++;
        }
      }
    }
    omitiu = 45 - acertou;
    FirebaseFirestore db = FirebaseFirestore.instance;

    db.collection("Avaliacoes").doc(id).collection("resultados").add({
      "data_avaliacao": dataFormatada,
      "tipo": tipo,
      "acertos": acertou,
      "omissoes": omitiu,
      "erros": errou,
      "qtde_cliques": indices.length,
    });
    if (boolTeste == 0) {
      db
          .collection("Criancas")
          .doc(identificacao)
          .collection("dados")
          .doc(id)
          .update({"boolTestes": 1});
    }
  }

  Future<List<Child>> childrenEvaluated() async {
    List<Child> criancas = [];

    final stream = await loadChildren();
    stream.listen((event) {
      for (int i = 0; i < event.docs.length; i++) {
        if (event.docs[i]["boolTestes"] == 1) {
          criancas.add(
            Child(
              event.docs[i].id,
              event.docs[i]["nome"],
              event.docs[i]["data_de_nascimento"],
              event.docs[i]["cor"],
              event.docs[i]["sexo"],
              event.docs[i]["renda"],
              event.docs[i]["tempo_aparelhos"],
              event.docs[i]["tempo_em_casa"],
              event.docs[i]["tempo_fora"],
              event.docs[i]["boolTestes"],
              event.docs[i].data().containsKey("foto_perfil")
                  ? event.docs[i]["foto_perfil"]
                  : "",
            ),
          );
        }
      }
    });
    return criancas;
  }

  Future loadReviews(String id) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final stream = db
        .collection("Avaliacoes")
        .doc(id)
        .collection("resultados")
        .snapshots();

    return stream;
  }

  Future<void> updateChild(Child child) async {
    String identificacao = await ControllerEvaluator().identificacao();

    await FirebaseFirestore.instance
        .collection("Criancas")
        .doc(identificacao)
        .collection("dados")
        .doc(child.id)
        .update({
      "nome": child.completeName,
      "data_de_nascimento": child.date,
      "cor": child.color,
      "sexo": child.sex,
      "renda": child.income,
      "foto_perfil": child.photoUrl,
    });
  }

  Future<void> deleteChild(String childId) async {
    try {
      String identificacao = await ControllerEvaluator().identificacao();
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db
          .collection("Criancas")
          .doc(identificacao)
          .collection("dados")
          .doc(childId)
          .delete();

      await db.collection("Avaliacoes").doc(childId).delete();

      print("Criança excluída com sucesso.");
    } catch (e) {
      print("Erro ao excluir criança: $e");
      throw Exception("Não foi possível excluir a criança.");
    }
  }
}
