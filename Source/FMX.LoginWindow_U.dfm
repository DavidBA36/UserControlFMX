object frmLoginWindow: TfrmLoginWindow
  Left = 343
  Top = 286
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Login'
  ClientHeight = 258
  ClientWidth = 452
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object PTop: TPanel
    Left = 0
    Top = 0
    Width = 452
    Height = 17
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ImgTop: TImage
      Left = 0
      Top = 0
      Width = 0
      Height = 0
      AutoSize = True
      Center = True
    end
    object Image1: TImage
      Left = 256
      Top = 16
      Width = 105
      Height = 105
    end
  end
  object PLeft: TPanel
    Left = 0
    Top = 17
    Width = 10
    Height = 202
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object imgLeft: TImage
      Left = 0
      Top = 0
      Width = 0
      Height = 0
      AutoSize = True
      Center = True
      Transparent = True
    end
  end
  object PBottom: TPanel
    Left = 0
    Top = 219
    Width = 452
    Height = 11
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object ImgBottom: TImage
      Left = 0
      Top = 0
      Width = 0
      Height = 0
      AutoSize = True
      Center = True
    end
  end
  object Panel1: TPanel
    Left = 10
    Top = 17
    Width = 442
    Height = 202
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object GridPanel1: TGridPanel
      Left = 0
      Top = 0
      Width = 442
      Height = 202
      Align = alClient
      BevelOuter = bvNone
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 90.000000000000000000
        end
        item
          Value = 49.999618529303310000
        end
        item
          SizeStyle = ssAbsolute
          Value = 90.000000000000000000
        end
        item
          Value = 50.000381470696690000
        end>
      ControlCollection = <
        item
          Column = 1
          ColumnSpan = 3
          Control = EditSenha
          Row = 2
        end
        item
          Column = 1
          ColumnSpan = 3
          Control = EditUsuario
          Row = 1
        end
        item
          Column = 0
          ColumnSpan = 4
          Control = lbEsqueci
          Row = 3
        end
        item
          Column = 0
          Control = LbSenha
          Row = 2
        end
        item
          Column = 0
          Control = LbUsuario
          Row = 1
        end
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 0
          Control = CheckBox1
          Row = 4
        end
        item
          Column = 1
          Control = CheckBox2
          Row = 4
        end
        item
          Column = 2
          Control = CheckBox3
          Row = 4
        end
        item
          Column = 2
          Control = Button1
          Row = 0
        end
        item
          Column = 3
          Control = Button2
          Row = 0
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 32.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 32.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 32.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 21.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 25.000000000000000000
        end
        item
          SizeStyle = ssAuto
        end>
      TabOrder = 0
      DesignSize = (
        442
        202)
      object EditSenha: TEdit
        AlignWithMargins = True
        Left = 93
        Top = 67
        Width = 346
        Height = 26
        Align = alClient
        Ctl3D = True
        MaxLength = 50
        ParentCtl3D = False
        PasswordChar = '*'
        TabOrder = 1
        ExplicitHeight = 24
      end
      object EditUsuario: TEdit
        AlignWithMargins = True
        Left = 93
        Top = 35
        Width = 346
        Height = 26
        Align = alClient
        CharCase = ecUpperCase
        Ctl3D = True
        MaxLength = 15
        ParentCtl3D = False
        TabOrder = 0
        OnChange = EditUsuarioChange
        ExplicitHeight = 24
      end
      object lbEsqueci: TLabel
        Left = 0
        Top = 96
        Width = 442
        Height = 21
        Cursor = crHandPoint
        Align = alClient
        Alignment = taCenter
        Caption = 'Olvide mi contrase'#241'a'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
        Layout = tlCenter
        Visible = False
        ExplicitWidth = 99
        ExplicitHeight = 13
      end
      object LbSenha: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 67
        Width = 84
        Height = 26
        Align = alClient
        Caption = 'Senha :'
        Layout = tlCenter
        ExplicitWidth = 45
        ExplicitHeight = 16
      end
      object LbUsuario: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 35
        Width = 84
        Height = 26
        Align = alClient
        Caption = 'Usu'#225'rio :'
        Layout = tlCenter
        ExplicitWidth = 53
        ExplicitHeight = 16
      end
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 84
        Height = 26
        Align = alClient
        Caption = 'Empresa'
        Layout = tlCenter
        ExplicitWidth = 55
        ExplicitHeight = 16
      end
      object CheckBox1: TCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 120
        Width = 84
        Height = 19
        Align = alClient
        Caption = 'Recordar'
        TabOrder = 2
      end
      object CheckBox2: TCheckBox
        AlignWithMargins = True
        Left = 93
        Top = 120
        Width = 124
        Height = 19
        Align = alClient
        Caption = 'AutoIniciar'
        TabOrder = 3
      end
      object CheckBox3: TCheckBox
        AlignWithMargins = True
        Left = 223
        Top = 120
        Width = 84
        Height = 19
        Align = alClient
        Caption = 'AutoLogin'
        TabOrder = 4
      end
      object Button1: TButton
        Left = 227
        Top = 3
        Width = 75
        Height = 25
        Anchors = []
        Caption = 'Button1'
        TabOrder = 5
        ExplicitLeft = 80
        ExplicitTop = 176
      end
      object Button2: TButton
        Left = 338
        Top = 3
        Width = 75
        Height = 25
        Anchors = []
        Caption = 'Button1'
        TabOrder = 6
        ExplicitLeft = 80
        ExplicitTop = 176
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 230
    Width = 452
    Height = 28
    Panels = <
      item
        Text = 'Tentativa: '
        Width = 80
      end
      item
        Alignment = taCenter
        Width = 60
      end
      item
        Text = 'Limite de Tentativas: '
        Width = 160
      end
      item
        Alignment = taCenter
        Width = 50
      end>
    ParentFont = True
    UseSystemFont = False
  end
  object DSMaster: TDataSource
    DataSet = FDMaster
    Left = 56
    Top = 88
  end
  object FDMaster: TFDQuery
    UpdateOptions.AssignedValues = [uvFetchGeneratorsPoint, uvGeneratorName]
    UpdateOptions.FetchGeneratorsPoint = gpImmediate
    UpdateOptions.GeneratorName = 'GEN_INT$UC_USERS_ID'
    UpdateOptions.UpdateTableName = 'INT$UC_USERS'
    UpdateOptions.KeyFields = 'CLAVE'
    UpdateOptions.AutoIncFields = 'CLAVE'
    SQL.Strings = (
      'SELECT A.* '
      'FROM INT$ENTIDAD A '
      'WHERE A.CLAVE>0'
      'ORDER BY A.CODIGO'
      '')
    Left = 328
    Top = 161
  end
end
