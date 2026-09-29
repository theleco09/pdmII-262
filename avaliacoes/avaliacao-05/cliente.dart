import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();

  try {
    final request = await client.getUrl(
      Uri.parse('http://localhost:8080/api/alunos'),
    );

    final response = await request.close();

    if (response.statusCode == 200) {
      final resposta = await response.transform(utf8.decoder).join();

      final json = jsonDecode(resposta);

      final List<dynamic> alunos = json['dados'];

      print('ID NOME DISCIPLINA MEDIA FALTAS MENSAGEM');

      for (final aluno in alunos) {
        final id = aluno['id'];
        final nome = aluno['nome'];
        final disciplina = aluno['disciplina'];
        final media = (aluno['media'] as num).toDouble();
        final faltas = aluno['faltas'];

        String mensagem;

        if (faltas > 20) {
          mensagem = 'Reprovado por Faltas';
        } else if (media < 6.0) {
          mensagem = 'Reprovado';
        } else {
          mensagem = 'Aprovado';
        }

        print('$id $nome $disciplina $media $faltas $mensagem');
      }
    } else {
      print('Erro ao acessar o servidor.');
      print('Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao conectar com o servidor: $e');
  } finally {
    client.close();
  }
}
