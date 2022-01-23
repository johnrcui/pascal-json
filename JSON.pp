unit JSON;

{$mode ObjFPC}{$H+}

interface

  type
    TJsDataType = ( jsNull, jsString, jsInteger, jsNumber, jsBoolean, jsObject, jsArray );
    PJsonEntry = ^TJsonEntry;
    PJsonEntries = ^TJsonEntries;
    PJsonValues = ^TJsonValues;
    TJsonValue = record
      case DataType: TJsDataType of
        jsString: ( StringValue: PChar );
        jsInteger: ( IntegerValue: Integer );
        jsNumber: ( NumberValue: Double );
        jsBoolean: ( BooleanValue: Boolean );
        jsObject: ( ObjectValue: PJsonEntries );
        jsArray: ( Items: PJsonValues );
        jsNull: ();
    end;
    TJsonObject = TJsonValue;
    TJsonArray = TJsonValue;
    TJsonValues = Array of TJsonValue;
    TJsonEntry = record
      Key: PChar;
      Value: TJsonValue;
    end;
    TJsonEntries = Array of TJsonEntry;

  function JsonObject(const Entries: TJsonEntries): TJsonObject;
  function JsonArray(const Items: TJsonValues): TJsonArray;
  function JsonValue(): TJsonValue; overload;
  function JsonValue(const StringValue: PChar): TJsonValue; overload;
  function JsonValue(const StringValue: String): TJsonValue; overload;
  function JsonValue(const IntegerValue: Integer): TJsonValue; overload;
  function JsonValue(const NumberValue: Double): TJsonValue; overload;
  function JsonValue(const BooleanValue: Boolean): TJsonValue; overload;
  function Entry(const Key: PChar): TJsonEntry; overload;
  function Entry(const Key: PChar; const StringValue: PChar): TJsonEntry; overload;
  function Entry(const Key: PChar; const StringValue: String): TJsonEntry; overload;
  function Entry(const Key: PChar; const IntegerValue: Integer): TJsonEntry; overload;
  function Entry(const Key: PChar; const NumberValue: Double): TJsonEntry; overload;
  function Entry(const Key: PChar; const BooleanValue: Boolean): TJsonEntry; overload;
  function Entry(const Key: PChar; const Value: TJsonValue): TJsonEntry; overload;
  procedure FreeValue(Value: TJsonValue);

implementation

  uses
    Strings;

  {*--------------------------------------------------------------------------*}

  function JsonObject(const Entries: TJsonEntries): TJsonObject;
  begin
    JsonObject.DataType := jsObject;
    JsonObject.ObjectValue := PJsonEntries(Entries);
  end;

  function JsonArray(const Items: TJsonValues): TJsonArray;
  begin
    JsonArray.DataType := jsArray;
    JsonArray.Items := PJsonValues(Items);
  end;

  {*--------------------------------------------------------------------------*}

  function JsonValue(): TJsonValue; overload;
  begin
    JsonValue.DataType := jsNull;
  end;

  function JsonValue(const StringValue: PChar): TJsonValue; overload;
  begin
    JsonValue.DataType := jsString;
    JsonValue.StringValue := StrNew(StringValue);
  end;

  function JsonValue(const StringValue: String): TJsonValue; overload;
  begin
    JsonValue.DataType := jsString;
    JsonValue.StringValue := StrNew(PChar(StringValue));
  end;

  function JsonValue(const IntegerValue: Integer): TJsonValue; overload;
  begin
    JsonValue.DataType := jsInteger;
    JsonValue.IntegerValue := IntegerValue;
  end;

  function JsonValue(const NumberValue: Double): TJsonValue; overload;
  begin
    JsonValue.DataType := jsNumber;
    JsonValue.NumberValue := NumberValue;
  end;

  function JsonValue(const BooleanValue: Boolean): TJsonValue; overload;
  begin
    JsonValue.DataType := jsBoolean;
    JsonValue.BooleanValue := BooleanValue;
  end;

  {*--------------------------------------------------------------------------*}

  function Entry(const Key: PChar): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := JsonValue();
  end;

  function Entry(const Key: PChar; const StringValue: PChar): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := JsonValue(StringValue);
  end;

  function Entry(const Key: PChar; const StringValue: String): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := JsonValue(StringValue);
  end;

  function Entry(const Key: PChar; const IntegerValue: Integer): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := JsonValue(IntegerValue);
  end;

  function Entry(const Key: PChar; const NumberValue: Double): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := JsonValue(NumberValue);
  end;

  function Entry(const Key: PChar; const BooleanValue: Boolean): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := JsonValue(BooleanValue);
  end;

  function Entry(const Key: PChar; const Value: TJsonValue): TJsonEntry; overload;
  begin
    Entry.Key := StrNew(Key);
    Entry.Value := Value;
  end;

  {*--------------------------------------------------------------------------*}

  procedure FreeValue(Value: TJsonValue);
  var
    I: Integer;
  begin
    with Value do begin
      case DataType of
        jsObject:
        begin
          for I := Low(TJsonEntries(ObjectValue)) to High(TJsonEntries(ObjectValue)) do
          begin
            FreeValue(TJsonEntries(ObjectValue)[I].Value);
            StrDispose(TJsonEntries(ObjectValue)[I].Key);
          end;
        end;
        jsArray:
        begin
          for I := Low(TJsonValues(Items)) to High(TJsonValues(Items)) do
            FreeValue(TJsonValues(Items)[I]);
        end;
        jsString:
        begin
          StrDispose(StringValue);
        end;
      end;
    end;
  end;
end.
