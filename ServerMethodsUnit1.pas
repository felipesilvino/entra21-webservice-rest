
unit ServerMethodsUnit1;

interface

uses SysUtils, Classes, DBXJSON,
     Dialogs, ServerUtils, SysTypes;

type
{$METHODINFO ON}
  TServerMethods1 = class(TComponent)
  private
    { Private declarations }
    Function ReturnErro : String;

    // http://localhost:8080/InsereAluno/fulano
    function InsereAluno (NomeAluno : String) : String;

    // http://localhost:8080/ConsultaAluno/fulano
    function ConsultaAluno (NomeAluno : String) : String;

    // http://localhost:8080/GetListaAlunos
    function GetListaAlunos : String;

    // http://localhost:8080/AtualizaAluno/Fulano/cicrano
    function AtualizaAluno (OldNomeAluno, NewNome : String) : String;

    // http://localhost:8080/ExcluiAluno/NomeAluno
    function ExcluiAluno (NomeAluno : String) : String;

  public
    { Public declarations }
    Constructor Create (aOwner : TComponent); Override;
    Destructor Destroy; Overload;
    function CallGETServerMethod (Argumentos : TArguments) : String;
    function CallPUTServerMethod (Argumentos : TArguments) : string;
    function CallDELETEServerMethod (Argumentos : TArguments) : string;
    function CallPOSTServerMethod (Argumentos : TArguments) : string;
  end;
{$METHODINFO OFF}

implementation


uses StrUtils;


Constructor TServerMethods1.Create (aOwner : TComponent);
Begin
     inherited Create (aOwner);
End;

Destructor TServerMethods1.Destroy;
begin
     inherited;
End;

Function TServerMethods1.ReturnErro : String;
Var
     WSResult : TResultErro;
begin
     WSResult.STATUS   := -1;
     WSResult.MENSAGEM := 'Total de argumentos incorretos';
     Result := TServerUtils.Result2JSON(WSResult);
end;

function TServerMethods1.CallGETServerMethod (Argumentos : TArguments) : string;
begin
     if UpperCase(Argumentos[0]) = UpperCase('ConsultaAluno') then begin
        if Length (Argumentos) = 2 then
           Result := ConsultaAluno (Argumentos[1])
        Else
           Result := ReturnErro;
     end;

     if UpperCase(Argumentos[0]) = UpperCase('GetListaAlunos') then begin
        if Length (Argumentos) = 1 then
           Result := GetListaAlunos
        Else
           Result := ReturnErro;
     end;
end;

function TServerMethods1.CallPOSTServerMethod (Argumentos : TArguments) : string;
begin
     if UpperCase(Argumentos[0]) = UpperCase('AtualizaAluno') then begin
        if Length (Argumentos) = 3 then
           Result := AtualizaAluno (Argumentos[1], Argumentos[2])
        Else
           Result := ReturnErro;
     end;
end;

function TServerMethods1.CallPUTServerMethod (Argumentos : TArguments) : string;
begin
     if UpperCase(Argumentos[0]) = UpperCase('InsereAluno') then begin
        if Length (Argumentos) = 2 then
           Result := InsereAluno (Argumentos[1])
        Else
           Result := ReturnErro;
     end;
end;

function TServerMethods1.CallDELETEServerMethod (Argumentos : TArguments) : string;
begin
     if UpperCase(Argumentos[0]) = UpperCase('ExcluiAluno') then begin
        if Length (Argumentos) = 2 then
           Result := ExcluiAluno (Argumentos[1])
        Else
           Result := ReturnErro;
     end;
end;

// Aqui voce vai
// 1 - Conectar com o Banco
// 2 - Executar a query
// 3 - Fechar conex�o com o banco
// 4 - Retornar o resultado em JSON

// Foi usado um Arquivo Texto para armazenar dados e um StringList
// o objetivo aqui � apenas mostrar como � um WebService REST + JSON
// e suas opera��es, o codigo de banco fica por sua conta.

function TServerMethods1.InsereAluno (NomeAluno : String) : String;
Var
     List : TStringList;
     JSONObject : TJSONObject;
Begin
     List       := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         if Not FileExists (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt') then
            FileClose(FileCreate (ExtractFilePath(ParamStr(0)) + '\Alunos.Txt'));

         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         List.Add (NomeAluno);
         List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');

         JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
         JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Inserido com sucesso'));
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
End;

function TServerMethods1.ConsultaAluno (NomeAluno : String) : String;
Var
     List : TStringList;
     JSONObject : TJSONObject;
     ID : Integer;
Begin
     List := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         ID := List.IndexOf(NomeAluno);
         if ID > -1 then Begin
            JSONObject.AddPair(TJSONPair.Create('ID', IntToStr (ID)));
         end else begin
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'N�o encontrado'));
            Result := JSONObject.ToString;
         end;
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
end;

function TServerMethods1.GetListaAlunos : String;
Var
     List        : TStringList;
     ID          : Integer;
     LJson       : TJSONObject;
     LJsonObject : TJSONObject;
     LArr        : TJSONArray;
Begin
     List        := TStringList.Create;
     LJsonObject := TJSONObject.Create;
     LArr        := TJSONArray.Create;
     try
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         for Id := 0 to List.Count - 1 do Begin
             LJson := TJSONObject.Create;
             LJson.AddPair(TJSONPair.Create('NomeAluno', List [ID]));
             LArr.Add(LJson);
         End;
         LJsonObject.AddPair(TJSONPair.Create('Alunos', LArr));
         Result := LJsonObject.ToString;
     Finally
         List.Free;
         LJsonObject.Free;
     end;
end;

function TServerMethods1.AtualizaAluno (OldNomeAluno, NewNome : String) : String;
Var
     List       : TStringList;
     JSONObject : TJSONObject;
     ID         : Integer;
Begin
     List := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         ID := List.IndexOf(OldNomeAluno);
         if ID > -1 then Begin
            List[ID] := NewNome;
            List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Atualizado com sucesso'));
         End else begin
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Aluno n�o encontrado'));
         end;
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
end;

function TServerMethods1.ExcluiAluno (NomeAluno : String) : String;
Var
     List       : TStringList;
     JSONObject : TJSONObject;
     ID         : Integer;
Begin
     List := TStringList.Create;
     JSONObject := TJSONObject.Create;
     try
         List.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
         ID := List.IndexOf(NomeAluno);
         if ID > -1 then Begin
            List.Delete(ID);
            List.SaveToFile(ExtractFilePath(ParamStr(0)) + '\Alunos.Txt');
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Deletado com sucesso'));
         End else begin
            JSONObject.AddPair(TJSONPair.Create('STATUS', 'OK'));
            JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Aluno n�o encontrado'));
         end;
         Result := JSONObject.ToString;
     Finally
         List.Free;
         JSONObject.Free;
     end;
end;


end.



