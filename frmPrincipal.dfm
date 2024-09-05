object frPrincipal: TfrPrincipal
  Left = 0
  Top = 0
  Caption = 'Pesquisa de Ceps no ViaCep'
  ClientHeight = 435
  ClientWidth = 863
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  TextHeight = 15
  object PathLabel: TLabel
    Left = 0
    Top = 420
    Width = 863
    Height = 15
    Align = alBottom
    Caption = 'PathLabel'
    ExplicitWidth = 52
  end
  object pgDados: TPageControl
    Left = 0
    Top = 0
    Width = 863
    Height = 420
    ActivePage = tsDados
    Align = alClient
    TabOrder = 0
    object tsPesquisa: TTabSheet
      Caption = 'Pesquisar'
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 855
        Height = 390
        Align = alClient
        Caption = 'Pesquisar'
        TabOrder = 0
        object lblLocalidade: TLabel
          Left = 323
          Top = 15
          Width = 57
          Height = 15
          Caption = 'Localidade'
        end
        object lblLogradouro: TLabel
          Left = 472
          Top = 15
          Width = 62
          Height = 15
          Caption = 'Logradouro'
        end
        object lblUF: TLabel
          Left = 168
          Top = 14
          Width = 14
          Height = 15
          Caption = 'UF'
        end
        object lblFiltro: TLabel
          Left = 16
          Top = 15
          Width = 27
          Height = 15
          Caption = 'Filtro'
        end
        object Label11: TLabel
          Left = 698
          Top = 15
          Width = 48
          Height = 15
          Caption = 'Tipo Arq.'
        end
        object edtConsultar: TEdit
          Left = 472
          Top = 36
          Width = 216
          Height = 21
          CharCase = ecUpperCase
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          TextHint = 'Informe um CEP para ser consultado '
        end
        object btnPesquisar: TButton
          Left = 766
          Top = 34
          Width = 75
          Height = 25
          Caption = 'Pesquisar'
          TabOrder = 5
          OnClick = btnPesquisarClick
        end
        object dbDados: TDBGrid
          Left = 16
          Top = 72
          Width = 825
          Height = 302
          DataSource = DataSource1
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 6
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnCellClick = dbDadosCellClick
          OnDblClick = dbDadosDblClick
        end
        object cbFiltro: TComboBox
          Left = 16
          Top = 35
          Width = 142
          Height = 22
          Style = csOwnerDrawFixed
          TabOrder = 0
          OnExit = cbFiltroExit
          OnSelect = cbFiltroSelect
          Items.Strings = (
            'CEP'
            'Logradouro')
        end
        object cbUF: TComboBox
          Left = 168
          Top = 35
          Width = 145
          Height = 22
          Style = csOwnerDrawFixed
          TabOrder = 1
          Items.Strings = (
            'AC - Acre'
            'AL  - Alagoas '
            'AP  - Amap'#225
            'AM - Amazonas'
            'BA  - Bahia '
            'CE  - Cear'#225
            'DF  - Distrito Federal'
            'ES  - Esp'#237'rito Santo'
            'GO - Goi'#225's'
            'MA - Maranh'#227'o'
            'MT - Mato Grosso'
            'MS - Mato Grosso do Sul'
            'MG - Minas Gerais'
            'PA  - Par'#225
            'PB - Para'#237'ba'
            'PR - Paran'#225
            'PE - Pernambuco'
            'PI - Piau'#237
            'RJ - Rio de Janeiro'
            'RN - Rio Grande do Norte'
            'RS - Rio Grande do Sul'
            'RO - R'#244'ndonia'
            'RR - Roraima'
            'SC - Santa Catarina'
            'SP - S'#227'o Paulo'
            'SE - Sergipe'
            'TO - Tocantins')
        end
        object edtLocalidadePesq: TEdit
          Left = 323
          Top = 36
          Width = 139
          Height = 21
          CharCase = ecUpperCase
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          TextHint = 'Informe a Localidade  para ser consultado '
        end
        object cbTipoArquivo: TComboBox
          Left = 698
          Top = 35
          Width = 55
          Height = 22
          Style = csOwnerDrawFixed
          ItemIndex = 0
          TabOrder = 4
          Text = 'Json'
          Items.Strings = (
            'Json'
            'Xml')
        end
      end
    end
    object tsDados: TTabSheet
      Caption = 'Dados'
      ImageIndex = 1
      object GroupBox2: TGroupBox
        Left = 0
        Top = 0
        Width = 855
        Height = 390
        Align = alClient
        Caption = 'Consultar'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 15
          Width = 20
          Height = 13
          Caption = 'CEP'
        end
        object Label2: TLabel
          Left = 143
          Top = 15
          Width = 62
          Height = 13
          Caption = 'Logradouro'
        end
        object Label3: TLabel
          Left = 16
          Top = 63
          Width = 74
          Height = 13
          Caption = 'Complemento'
        end
        object Label4: TLabel
          Left = 407
          Top = 63
          Width = 31
          Height = 13
          Caption = 'Bairro'
        end
        object Label5: TLabel
          Left = 16
          Top = 111
          Width = 56
          Height = 13
          Caption = 'Localidade'
        end
        object Label6: TLabel
          Left = 407
          Top = 111
          Width = 14
          Height = 13
          Caption = 'UF'
        end
        object Label7: TLabel
          Left = 471
          Top = 111
          Width = 24
          Height = 13
          Caption = 'DDD'
        end
        object Label8: TLabel
          Left = 514
          Top = 15
          Width = 24
          Height = 13
          Caption = 'IBGE'
        end
        object Label9: TLabel
          Left = 641
          Top = 15
          Width = 60
          Height = 13
          Caption = 'C'#243'digo GIA'
        end
        object Label10: TLabel
          Left = 16
          Top = 157
          Width = 28
          Height = 13
          Caption = 'JSON'
        end
        object edtCEP: TEdit
          Left = 16
          Top = 34
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object edtLogradouro: TEdit
          Left = 143
          Top = 34
          Width = 365
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object edtComplemento: TEdit
          Left = 16
          Top = 130
          Width = 385
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
        end
        object edtBairro: TEdit
          Left = 407
          Top = 82
          Width = 355
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
        end
        object edtLocalidade: TEdit
          Left = 16
          Top = 82
          Width = 385
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
        end
        object edtUF: TEdit
          Left = 410
          Top = 130
          Width = 54
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 7
        end
        object edtDDD: TEdit
          Left = 471
          Top = 130
          Width = 291
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 8
        end
        object edtIBGE: TEdit
          Left = 514
          Top = 34
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object edtGIA: TEdit
          Left = 641
          Top = 34
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
        end
        object edtJSON: TMemo
          Left = 16
          Top = 176
          Width = 746
          Height = 93
          Color = clBtnFace
          Enabled = False
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 9
        end
        object btnGravar: TButton
          Left = 687
          Top = 275
          Width = 75
          Height = 25
          Caption = 'Gravar'
          TabOrder = 10
          OnClick = btnGravarClick
        end
        object btnExcluir: TButton
          Left = 606
          Top = 275
          Width = 75
          Height = 25
          Caption = 'Excluir'
          Enabled = False
          TabOrder = 11
          OnClick = btnExcluirClick
        end
      end
    end
  end
  object DataSource1: TDataSource
    Left = 48
    Top = 344
  end
end
