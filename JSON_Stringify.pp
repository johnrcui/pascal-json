unit JSON_Stringify;

{$mode ObjFPC}{$H+}

interface

  uses
    JSON, SysUtils, StrUtils;

  function StringifyJsonValue(Value: TJsonValue): String;

implementation

  const CR_LF: PChar = #13#10;
  const SOFT_TAB: PChar = '  ';

  function EscapeQuotes(S: String): String;
  begin
    Result := StringReplace(S, '\', '\\', [ rfReplaceAll ]);
    Result := StringReplace(Result, '"', '\"', [ rfReplaceAll ]);
  end;

  function StringifyValueWithPadding(Value: TJsonValue; Padding: String): String;
  var
    I: Integer;
  begin
    case Value.DataType of
      jsNull:
        Result := 'null';
      jsString: begin;
        if Assigned(Value.StringValue) then
        begin
          Result := Value.StringValue;
          Result := '"' + EscapeQuotes(Result) + '"';
        end;
      end;
      jsInteger:
        Result := Format('%D', [ Value.IntegerValue ]);
      jsNumber:
        Result := Format('%G', [ Value.NumberValue ]);
      jsBoolean:
      begin
        if Value.BooleanValue then
          Result := 'true'
        else
          Result := 'false';
      end;
      jsObject:
      begin
        if Length(Value.ObjectValue^) = 0 then
          Result := '{}'
        else
        begin
          Result := '{' + CR_LF;

          for I := Low(TJsonEntries(Value.ObjectValue)) to High(TJsonEntries(Value.ObjectValue)) do
          begin
            Result := Result + Padding + SOFT_TAB
                    + '"' + TJsonEntries(Value.ObjectValue)[I].Key + '": '
                    + StringifyValueWithPadding(TJsonEntries(Value.ObjectValue)[I].Value, Padding + SOFT_TAB);

            if I = High(TJsonEntries(Value.ObjectValue)) then
              Result := Result + CR_LF
            else
              Result := Result + ',' + CR_LF
          end;

          Result := Result + Padding + '}';
        end;
      end;
      jsArray:
      begin
        if Length(TJsonValues(Value.Items)) = 0 then
          Result := '[]'
        else
        begin
          Result := '[' + CR_LF;

          for I := Low(TJsonValues(Value.Items)) to High(TJsonValues(Value.Items)) do
          begin
            Result := Result + Padding + SOFT_TAB
                    + StringifyValueWithPadding(TJsonValues(Value.Items)[I], Padding + SOFT_TAB);

            if I = High(TJsonValues(Value.Items)) then
              Result := Result + CR_LF
            else
              Result := Result + ',' + CR_LF;
          end;

          Result := Result + Padding + ']';
        end;  
      end;
    end;
  end;

  function StringifyJsonValue(Value: TJsonValue): String;
  begin
    Result := StringifyValueWithPadding(Value, '');
  end;
end.