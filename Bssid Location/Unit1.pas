unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, sStatusBar, Vcl.Buttons,
  sSpeedButton, Vcl.StdCtrls, sEdit, sGroupBox, sRadioButton, sLabel,
  Vcl.ExtCtrls, sPanel, sSkinManager,Vcl.Clipbrd;

type
  TForm1 = class(TForm)
    sStatusBar1: TsStatusBar;
    sPanel1: TsPanel;
    sGroupBox2: TsGroupBox;
    sSpeedButton1: TsSpeedButton;
    sEdit1: TsEdit;
    sGroupBox1: TsGroupBox;
    sSpeedButton2: TsSpeedButton;
    sEdit2: TsEdit;
    sEdit3: TsEdit;
    sEdit4: TsEdit;
    sRadioButton1: TsRadioButton;
    sRadioButton2: TsRadioButton;
    sRadioButton3: TsRadioButton;
    sGroupBox3: TsGroupBox;
    sLabel55: TsLabel;
    sSkinManager1: TsSkinManager;
    procedure sSpeedButton1Click(Sender: TObject);
    procedure sSpeedButton2Click(Sender: TObject);
    procedure sLabel55MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sLabel55MouseLeave(Sender: TObject);
    procedure sLabel55MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R geomac.RES}
{$R libcrypto.RES}
{$R libssl.RES}

const
shell32 = 'shell32.dll';
kernel32 = 'kernel32.dll';

Function Wow64DisableWow64FsRedirection(Var Wow64FsEnableRedirection: LongBool): LongBool; stdcall;
External kernel32 name 'Wow64DisableWow64FsRedirection';

function ShellExecuteW(hWnd: THandle; Operation, FileName, Parameters,
Directory: WideString; ShowCmd: Integer): HINST; stdcall;
external shell32 name 'ShellExecuteW';

procedure ShellExecute(hWnd: THandle; Operation, FileName, Parameters, Directory: WideString; ShowCmd: Integer);
var
WFER: LongBool;
begin
if Wow64DisableWow64FsRedirection(WFER) then
ShellExecuteW(hWnd, Operation, FileName, Parameters, Directory, ShowCmd)
else ShellExecuteW(hWnd, Operation, FileName, Parameters, Directory, ShowCmd);
end;

function StrOemToAnsi(const S: AnsiString): AnsiString;
begin
SetLength(Result, Length(S));
OemToAnsiBuff(@S[1], @Result[1], Length(S));
end;

function StrAnsiToOem(const S: AnsiString): AnsiString;
begin
SetLength(Result, Length(S));
AnsiToOemBuff(@S[1], @Result[1], Length(S));
end;

procedure ExtractRes(ResType, ResName, ResNewName: string);
var
  Res: TResourceStream;
begin
  Res := TResourceStream.Create(Hinstance, Resname, Pchar(ResType));
  Res.SavetoFile(ResNewName);
  Res.Free;
end;

function DelWord(word,srtl:string):string;
var s,s1:string;
p:integer;
begin
s:=srtl;
s1:=word;
p:=pos(s1,s);
if p<>0 then
begin
delete(s,p,length(s1));
end;
Result:=s
end;

function GetDosOutput(
CommandLine: string; Work: string = 'C:\'): string;
var
SA: TSecurityAttributes;
SI: TStartupInfo;
PI: TProcessInformation;
StdOutPipeRead, StdOutPipeWrite: THandle;
WasOK: Boolean;
Buffer: array[0..255] of AnsiChar;
BytesRead: Cardinal;
WorkDir: string;
Handle: Boolean;
begin
Result := '';
with SA do begin
nLength := SizeOf(SA);
bInheritHandle := True;
lpSecurityDescriptor := nil;
end;
CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
try
with SI do
begin
FillChar(SI, SizeOf(SI), 0);
cb := SizeOf(SI);
dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
wShowWindow := SW_HIDE;
hStdInput := GetStdHandle(
STD_INPUT_HANDLE);
hStdOutput := StdOutPipeWrite;
hStdError := StdOutPipeWrite;
end;
WorkDir := Work;
Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
nil, nil, True, 0, nil,
PChar(WorkDir), SI, PI);
CloseHandle(StdOutPipeWrite);
if Handle then
try
repeat
WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
if BytesRead > 0 then
begin
Buffer[BytesRead] := #0;
Result := Result + StrOemToAnsi(Buffer);
end;

until not WasOK or (BytesRead = 0);
WaitForSingleObject(PI.hProcess, INFINITE);
finally
CloseHandle(PI.hThread);
CloseHandle(PI.hProcess);
end;
finally
CloseHandle(StdOutPipeRead);
end;
end;

procedure TForm1.sLabel55MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
sLabel55.Font.Color := clRed;
Clipboard.SetTextBuf(PChar('netsh wlan show networks mode=bssid > C:\bssid.txt'));
sStatusBar1.SimpleText := 'copied to clipboard';
Application.ProcessMessages;
Sleep(500);
sStatusBar1.SimpleText := '';
end;

procedure TForm1.sLabel55MouseLeave(Sender: TObject);
begin
sLabel55.Font.Color := clBlack;
end;

procedure TForm1.sLabel55MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
sLabel55.Font.Color := clGray;
end;

procedure TForm1.sSpeedButton1Click(Sender: TObject);
var
  s: string;
  StringList:TStringList;
  i, ipos:Integer;
begin
   sEdit2.text := '';
   sEdit3.text := '';
   sEdit4.text := '';
  if FileExists(ExtractFilePath(ParamStr(0))+'geomac.exe') = False then
  ExtractRes('EXEFILE', 'geomac', ExtractFilePath(ParamStr(0))+'geomac.exe');
  if FileExists(ExtractFilePath(ParamStr(0))+'libssl-1_1-x64.dll') = False then
  ExtractRes('DLLFILE', 'libssl', ExtractFilePath(ParamStr(0))+'libssl-1_1-x64.dll');
  if FileExists(ExtractFilePath(ParamStr(0))+'libcrypto-1_1-x64.dll') = False then
  ExtractRes('DLLFILE', 'libcrypto', ExtractFilePath(ParamStr(0))+'libcrypto-1_1-x64.dll');
  StringList:=TStringList.Create;
  Sleep(1000);
  StringList.Text := GetDosOutput('"'+ExtractFilePath(ParamStr(0))+'geomac.exe" '+sEdit1.Text, 'C:');
  for i := 0 to StringList.Count-1 do
  begin
     if Pos('Yandex Locator  | ',StringList[i]) <> 0 then
     begin
        sEdit2.text := DelWord('Yandex Locator  | ',StringList[i])
     end;
     if Pos('Google          | ',StringList[i]) <> 0 then
     begin
        sEdit3.text := DelWord('Google          | ',StringList[i])
     end;
     if Pos('Apple           | ',StringList[i]) <> 0 then
     begin
        sEdit4.text := DelWord('Apple           | ',StringList[i])
     end;
  end;
  StringList.Free;
  if ((sEdit2.Text = '') and (sEdit3.Text = '') and (sEdit4.Text = '')) then
  ShowMessage('[Error]Wi-Fi hotspot is not registered in the database');
end;

procedure TForm1.sSpeedButton2Click(Sender: TObject);
begin
if sRadioButton1.Checked = True then
begin
if sEdit2.Text <> '' then
ShellExecute(Handle, 'open', PChar('http://www.google.ru/maps/place/' + sEdit2.Text), '', '', SW_SHOW);
end else if sRadioButton2.Checked = True then
begin
if sEdit3.Text <> '' then
ShellExecute(Handle, 'open', PChar('http://www.google.ru/maps/place/' + sEdit3.Text), '', '', SW_SHOW);
end else if sRadioButton3.Checked = True then
begin
if sEdit4.Text <> '' then
ShellExecute(Handle, 'open', PChar('http://www.google.ru/maps/place/' + sEdit4.Text), '', '', SW_SHOW);
end;
end;

end.
