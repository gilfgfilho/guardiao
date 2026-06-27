unit uGuardiaoSwagger;

interface

procedure RegistrarGuardiaoSwagger;

implementation

uses
  Horse.GBSwagger,
  GBSwagger.Model.Interfaces;

const
  TAG_SERVICOS = 'Servicos';

type
  TGuardiaoResposta = class
  private
    Fsucesso: Boolean;
    Fmensagem: string;
    Farquivo: string;
    Ferro: string;
  public
    property sucesso: Boolean read Fsucesso write Fsucesso;
    property mensagem: string read Fmensagem write Fmensagem;
    property arquivo: string read Farquivo write Farquivo;
    property erro: string read Ferro write Ferro;
  end;

procedure RegistrarPathBat(const APath, ATitulo, ADescricao: string);
begin
  Swagger.Path(APath)
    .Tag(TAG_SERVICOS)
    .POST(ATitulo, ADescricao)
      .AddSecurity('Bearer')
      .AddParamHeader('X-API-Token', 'Token alternativo de autenticacao')
        .Required(False)
        .Schema(SWAG_STRING)
      .&End
      .AddResponse(202, 'Script iniciado em background')
        .Schema(TGuardiaoResposta)
      .&End
      .AddResponse(401, 'Token invalido ou ausente')
        .Schema(TGuardiaoResposta)
      .&End
      .AddResponse(500, 'Erro ao executar script')
        .Schema(TGuardiaoResposta)
      .&End
    .&End
  .&End;
end;

procedure RegistrarGuardiaoSwagger;
begin
  Swagger
    .Info
      .Title('Guardiao API')
      .Description('API para executar scripts de backup e reinicio de servicos')
      .Version('1.0.0')
    .&End
    .AddBearerSecurity
    .&End
    .Register
      .Response(401).Description('Token invalido ou ausente').Schema(TGuardiaoResposta).&End
    .&End
    .AddModel(TGuardiaoResposta);

  RegistrarPathBat('/reiniciaservicos', 'Reiniciar servicos', 'Executa o script reiniciaservicos.bat');
  RegistrarPathBat('/executabackup', 'Executar backup', 'Executa o script executabackup.bat');
end;

end.
