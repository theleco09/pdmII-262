import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class Aluno {
  final int id;
  final String nome;
  final String disciplina;
  final double media;
  final int faltas;

  const Aluno({
    required this.id,
    required this.nome,
    required this.disciplina,
    required this.media,
    required this.faltas,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'disciplina': disciplina,
    'media': media,
    'faltas': faltas,
  };
}

final List<Aluno> alunos = [
  const Aluno(
    id: 1,
    nome: 'Ana Souza',
    disciplina: 'Matemática',
    media: 8.5,
    faltas: 10,
  ),
  const Aluno(
    id: 2,
    nome: 'Bruno Lima',
    disciplina: 'Português',
    media: 5.5,
    faltas: 8,
  ),
  const Aluno(
    id: 3,
    nome: 'Carla Mendes',
    disciplina: 'História',
    media: 7.2,
    faltas: 25,
  ),
  const Aluno(
    id: 4,
    nome: 'Diego Alves',
    disciplina: 'Geografia',
    media: 4.5,
    faltas: 30,
  ),
];

Response jsonResponse(Object body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Response _listarAlunos(Request request) {
  return jsonResponse({
    'total': alunos.length,
    'dados': alunos.map((aluno) => aluno.toJson()).toList(),
  });
}

Response _buscarAluno(Request request, String id) {
  final idNumerico = int.tryParse(id);

  if (idNumerico == null) {
    return jsonResponse({
      'erro': 'O id deve ser um número inteiro.',
    }, status: 400);
  }

  final aluno = alunos.where((item) => item.id == idNumerico).firstOrNull;

  if (aluno == null) {
    return jsonResponse({'erro': 'Aluno não encontrado.'}, status: 404);
  }

  return jsonResponse(aluno.toJson());
}

Response _health(Request request) {
  return jsonResponse({
    'status': 'ok',
    'servico': 'api-alunos',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });
}

Router createRouter() {
  final router = Router()
    ..get('/health', _health)
    ..get('/api/alunos', _listarAlunos)
    ..get('/api/alunos/<id>', _buscarAluno);

  return router;
}

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final address = InternetAddress.anyIPv4;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createRouter().call);

  final server = await shelf_io.serve(handler, address, port);

  server.autoCompress = true;

  print('Servidor iniciado em http://${server.address.host}:${server.port}');
}
