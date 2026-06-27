program GuardiaoAPI;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.GBSwagger,
  uAuthConfig in 'uAuthConfig.pas',
  uAuthMiddleware in 'uAuthMiddleware.pas',
  uBatchExecutor in 'uBatchExecutor.pas',
  uGuardiaoSwagger in 'uGuardiaoSwagger.pas',
  uRotas in 'uRotas.pas';

const
  PORTA_PADRAO = 9000;

function ObterPorta: Integer;
var
  PortaStr: string;
begin
  Result := PORTA_PADRAO;

  if FindCmdLineSwitch('porta', PortaStr, True) then
    Result := StrToIntDef(PortaStr, PORTA_PADRAO);
end;

begin
  TAuthConfig.Carregar;

  if not TAuthConfig.TokenConfigurado then
  begin
    Writeln('ERRO: Token nao configurado.');
    Writeln('Defina em config.ini, variavel GUARDIAO_API_TOKEN ou parametro -token:');
    Halt(1);
  end;

  THorse.Use(Jhonson);
  THorse.Use(HorseSwagger);
  THorse.Use(AuthMiddleware);
  RegistrarGuardiaoSwagger;
  RegistrarRotas;

  THorse.Listen(ObterPorta,
    procedure
    begin
      Writeln(Format('Guardiao API ativa em http://localhost:%d', [THorse.Port]));
      Writeln(Format('Swagger em http://localhost:%d/swagger/doc/html', [THorse.Port]));
      Writeln('Endpoints (autenticados): POST /reiniciaservicos | POST /executabackup');
      Writeln('Auth: Authorization Bearer <token> | X-API-Token | ?token=');
    end);
end.
