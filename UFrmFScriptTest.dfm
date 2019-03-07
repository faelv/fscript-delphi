object FrmFScriptTest: TFrmFScriptTest
  Left = 0
  Top = 0
  Caption = 'FScript'
  ClientHeight = 451
  ClientWidth = 619
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 171
    Width = 619
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    ResizeStyle = rsUpdate
    ExplicitLeft = 8
    ExplicitTop = 167
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 321
    Width = 619
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    ResizeStyle = rsUpdate
    ExplicitLeft = -3
    ExplicitTop = 375
  end
  object redtInput: TRichEdit
    Left = 0
    Top = 0
    Width = 619
    Height = 171
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    HideScrollBars = False
    Lines.Strings = (
      '[['
      ''
      ']]')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
    WordWrap = False
  end
  object redtOutput: TRichEdit
    Left = 0
    Top = 174
    Width = 619
    Height = 147
    Align = alBottom
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    HideScrollBars = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WantTabs = True
    WordWrap = False
  end
  object tbCommands: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 426
    Width = 613
    Height = 22
    Align = alBottom
    AutoSize = True
    ButtonWidth = 61
    Caption = 'tbCommands'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    List = True
    ParentFont = False
    AllowTextButtons = True
    TabOrder = 2
    object tbtnExecute: TToolButton
      Left = 0
      Top = 0
      Caption = '&Executar'
      ImageIndex = 0
      Style = tbsTextButton
      OnClick = tbtnExecuteClick
    end
    object tbtnStop: TToolButton
      Left = 65
      Top = 0
      Caption = '&Parar'
      Enabled = False
      ImageIndex = 1
      Style = tbsTextButton
      OnClick = tbtnStopClick
    end
  end
  object lsbMessages: TListBox
    Left = 0
    Top = 324
    Width = 619
    Height = 99
    Align = alBottom
    Color = clBtnFace
    ItemHeight = 13
    TabOrder = 3
  end
end
