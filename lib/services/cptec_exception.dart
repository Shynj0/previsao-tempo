enum CptecErrorType { connection, timeout, unavailable, invalidResponse }

class CptecException implements Exception {
  final CptecErrorType type;
  final String message;
  const CptecException(this.type, this.message);

  const CptecException.connection()
      : this(CptecErrorType.connection,
            'Falha de conexão. Verifique sua internet e tente novamente.');
  const CptecException.timeout()
      : this(CptecErrorType.timeout,
            'O serviço demorou demais para responder. Tente novamente.');
  const CptecException.unavailable([int? status])
      : this(CptecErrorType.unavailable,
            'O serviço do CPTEC/INPE está indisponível no momento. Tente mais tarde.');
  const CptecException.invalid()
      : this(CptecErrorType.invalidResponse,
            'O serviço retornou uma resposta inválida.');

  @override
  String toString() => message;
}
