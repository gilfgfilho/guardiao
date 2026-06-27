unit uAuthConfig;

interface

type
  TAuthConfig = class
  private
    class var FToken: string;
  public
    class procedure Carregar;
    class function TokenConfigurado: Boolean;
    class function Validar(const AToken: string): Boolean;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.IniFiles;

class procedure TAuthConfig.Carregar;
var
  IniPath: string;
  TokenCmd, TokenEnv: string;
begin
  FToken := EmptyStr;

  if FindCmdLineSwitch('token', TokenCmd, True) then
  begin
    FToken := TokenCmd;
    Exit;
  end;

  TokenEnv := GetEnvironmentVariable('GUARDIAO_API_TOKEN');
  if TokenEnv <> '' then
  begin
    FToken := TokenEnv;
    Exit;
  end;

  IniPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'config.ini');
  if TFile.Exists(IniPath) then
  begin
    with TIniFile.Create(IniPath) do
    try
      FToken := Trim(ReadString('auth', 'token', ''));
    finally
      Free;
    end;
  end;
end;

class function TAuthConfig.TokenConfigurado: Boolean;
begin
  Result := FToken <> '';
end;

class function TAuthConfig.Validar(const AToken: string): Boolean;
begin
  Result := TokenConfigurado and SameText(FToken, Trim(AToken));
end;

end.
