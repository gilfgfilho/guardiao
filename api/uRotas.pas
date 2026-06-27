unit uRotas;

interface

procedure RegistrarRotas;

implementation

uses
  System.JSON,
  System.SysUtils,
  Horse,
  uBatchExecutor;

procedure ExecutarBat(const ANomeBat: string; Res: THorseResponse);
var
  Erro: string;
  Bat: string;
  Json: TJSONObject;
  Resposta: string;
begin
  Bat := TBatchExecutor.GetCaminhoBat(ANomeBat);

  Json := TJSONObject.Create;
  try
    if TBatchExecutor.Executar(Bat, Erro) then
    begin
      Json.AddPair('sucesso', TJSONTrue.Create);
      Json.AddPair('mensagem', Format('%s iniciado com sucesso', [ANomeBat]));
      Json.AddPair('arquivo', Bat);
      Resposta := Json.ToJSON;
      Res.Send(Resposta).Status(202);
    end
    else
    begin
      Json.AddPair('sucesso', TJSONFalse.Create);
      Json.AddPair('erro', Erro);
      Resposta := Json.ToJSON;
      Res.Send(Resposta).Status(500);
    end;
  finally
    Json.Free;
  end;
end;

procedure RegistrarRotas;
begin
  THorse.Post('/reiniciaservicos',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      ExecutarBat('reiniciaservicos.bat', Res);
    end);

  THorse.Post('/executabackup',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      ExecutarBat('executabackup.bat', Res);
    end);

end;

end.
