unit uBatchExecutor;

interface

uses
  System.SysUtils,
  System.IOUtils;

type
  TBatchExecutor = class
  public
    class function GetCaminhoBat(const ANomeArquivo: string): string;
    class function Executar(const ABatFile: string; out AErro: string): Boolean;
  end;

implementation

uses
  Winapi.Windows,
  Winapi.ShellAPI;

class function TBatchExecutor.GetCaminhoBat(const ANomeArquivo: string): string;
var
  BasePath: string;
begin
  BasePath := ExtractFilePath(ParamStr(0));

  Result := TPath.Combine(BasePath, ANomeArquivo);
  if TFile.Exists(Result) then
    Exit;

  Result := TPath.Combine(TPath.GetDirectoryName(BasePath), ANomeArquivo);
end;

class function TBatchExecutor.Executar(const ABatFile: string; out AErro: string): Boolean;
var
  SEInfo: TShellExecuteInfo;
  WorkingDir: string;
  Params: string;
begin
  Result := False;
  AErro := EmptyStr;

  if not TFile.Exists(ABatFile) then
  begin
    AErro := Format('Arquivo nao encontrado: %s', [ABatFile]);
    Exit;
  end;

  WorkingDir := TPath.GetDirectoryName(ABatFile);
  Params := Format('/C "echo.| call ""%s"""', [ABatFile]);

  ZeroMemory(@SEInfo, SizeOf(SEInfo));
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI;
  SEInfo.lpVerb := 'open';
  SEInfo.lpFile := PChar('cmd.exe');
  SEInfo.lpParameters := PChar(Params);
  SEInfo.lpDirectory := PChar(WorkingDir);
  SEInfo.nShow := SW_HIDE;

  if ShellExecuteEx(@SEInfo) then
  begin
    if SEInfo.hProcess <> 0 then
      CloseHandle(SEInfo.hProcess);
    Result := True;
  end
  else
    AErro := SysErrorMessage(GetLastError);
end;

end.
