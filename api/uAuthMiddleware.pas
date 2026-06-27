unit uAuthMiddleware;

interface

uses
  System.SysUtils,
  Horse;

procedure AuthMiddleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.JSON,
  uAuthConfig;

function ExtrairToken(Req: THorseRequest): string;
var
  AuthHeader: string;
begin
  Result := Trim(Req.Headers['X-API-Token']);
  if Result <> '' then
    Exit;

  AuthHeader := Trim(Req.Headers['Authorization']);
  if AuthHeader.ToLower.StartsWith('bearer ') then
    Exit(Copy(AuthHeader, 8, MaxInt).Trim);

  Result := Trim(Req.Query['token']);
end;

procedure ResponderNaoAutorizado(Res: THorseResponse);
var
  Json: TJSONObject;
  Resposta: string;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('sucesso', TJSONFalse.Create);
    Json.AddPair('erro', 'Token invalido ou ausente');
    Resposta := Json.ToJSON;
    Res.Send(Resposta).Status(401);
  finally
    Json.Free;
  end;
end;

function IsRotaPublica(const APath: string): Boolean;
begin
  Result := APath.StartsWith('/swagger/');
end;

procedure AuthMiddleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  if IsRotaPublica(Req.PathInfo) then
  begin
    Next();
    Exit;
  end;

  if not TAuthConfig.Validar(ExtrairToken(Req)) then
  begin
    ResponderNaoAutorizado(Res);
    Exit;
  end;

  Next();
end;

end.
