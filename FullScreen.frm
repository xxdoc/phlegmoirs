VERSION 5.00
Begin VB.Form frmFullScreen 
   BorderStyle     =   0  'None
   ClientHeight    =   7005
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   8475
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   ScaleHeight     =   7005
   ScaleWidth      =   8475
   WindowState     =   2  'Maximized
   Begin VB.PictureBox picFullScreen 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      ClipControls    =   0   'False
      ForeColor       =   &H80000008&
      Height          =   5655
      Left            =   0
      ScaleHeight     =   5655
      ScaleWidth      =   8190
      TabIndex        =   0
      Top             =   0
      Width           =   8190
      Begin VB.CommandButton btnClose 
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Small Fonts"
            Size            =   6.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   175
         Left            =   0
         TabIndex        =   1
         TabStop         =   0   'False
         ToolTipText     =   "Exit Fullscreen Mode (F11 or Esc)"
         Top             =   0
         Width           =   175
      End
      Begin VB.Label lblFileNameZoom 
         Alignment       =   1  'Right Justify
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "c:\penis\penis   69%"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   4200
         TabIndex        =   2
         Top             =   0
         Width           =   1785
      End
      Begin VB.Image Image1 
         Appearance      =   0  'Flat
         Height          =   4560
         Left            =   0
         MousePointer    =   15  'Size All
         Stretch         =   -1  'True
         Top             =   0
         Width           =   3600
      End
   End
End
Attribute VB_Name = "frmFullScreen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Binary
Option Explicit

Private Sub btnClose_Click()
      Unload frmFullScreen
End Sub

Private Sub CopyDimensions()
Attribute CopyDimensions.VB_UserMemId = 1610809346
      With frmMain.Image1
            Image1.Move .Left, .Top, .Width, .Height
      End With
End Sub

Private Sub Form_Load()
      gfFullScreenMode = True
      Set gImageData.OutPic = Image1
      
      picFullScreen.Move 0, 0, ScaleWidth, ScaleHeight
      CopyDimensions
      Image1.Picture = frmMain.Image1.Picture
      
      lblFileNameZoom.Left = picFullScreen.Width - lblFileNameZoom.Width
      lblFileNameZoom = frmMain.Caption & "  "
      
      gpOldfrmFullScreenProc = SetWindowLong(hwnd, GWL_WNDPROC, _
            AddressOf TrackMouseWheel)
End Sub

Private Sub Form_Resize()
Attribute Form_Resize.VB_UserMemId = 1610809347
      picFullScreen.Move 0, 0, ScaleWidth, ScaleHeight
      lblFileNameZoom.Left = picFullScreen.Width - lblFileNameZoom.Width
End Sub

Private Sub Form_Unload(Cancel As Integer)
Attribute Form_Unload.VB_UserMemId = 1610809353
      SetWindowLong hwnd, GWL_WNDPROC, gpOldfrmFullScreenProc
      gpOldfrmFullScreenProc = 0
      
      With Image1
            frmMain.Image1.Move .Left, .Top, .Width, .Height
            frmMain.Image1.Picture = .Picture
      End With
      Set gImageData.OutPic = frmMain.Image1
      gfFullScreenMode = False
      frmMain.Show
End Sub

Private Sub Image1_DblClick()
Attribute Image1_DblClick.VB_UserMemId = 1610809349
      ' This needs to (effectively) call an Image1_mousedown... but with what parameters???
      Dim poiPrev As POINTAPI
      
      GetCursorPos poiPrev
      
      gImageData.PrevX = poiPrev.X * Screen.TwipsPerPixelX
      gImageData.PrevY = poiPrev.Y * Screen.TwipsPerPixelY
      gImageData.Dragging = True
End Sub

Private Sub Image1_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute Image1_MouseDown.VB_UserMemId = 1610809350
      gImageData.PrevX = X
      gImageData.PrevY = Y
      If Button = vbLeftButton Then
            gImageData.Dragging = True
      End If
End Sub

Private Sub Image1_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute Image1_MouseMove.VB_UserMemId = 1610809351
      If gImageData.Dragging Then
            Image1.Move Image1.Left + X - gImageData.PrevX, Image1.Top + Y - gImageData.PrevY, _
                  Image1.Width, Image1.Height
            If X <> gImageData.PrevX Or Y <> gImageData.PrevY Then gImageData.Moved = True
      End If
End Sub

Private Sub Image1_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute Image1_MouseUp.VB_UserMemId = 1610809352
      ' Mouse button lifted?  Stop the drag!
      gImageData.Dragging = False
      
      If Not gImageData.Moved And Not gImageData.Zoomed And Button = vbLeftButton Then
            ' On a left click, we'll go to the next picture.  We spare no expense on ease of use.
            frmMain.BrowserExecuteNext
      ElseIf Not gImageData.Moved And Not gImageData.Zoomed And Button = vbRightButton Then
            ' On a right click, we go to the previous picture.
            ' Essentially, it'll means we don't need the toolbar open for picture manipulation.
            frmMain.BrowserExecuteNext True
      End If
      
      gImageData.Moved = False
      gImageData.Zoomed = False
End Sub

Private Sub picFullScreen_KeyDown(KeyCode As Integer, Shift As Integer)
Attribute picFullScreen_KeyDown.VB_UserMemId = 1610809354
      With frmMain.sliZoom
            Select Case KeyCode
                  Case 107, 187 ' "+" and Keypad "+"
                        If Shift = 0 Then
                              frmMain.ImageZoomIn .SmallChange
                              RedoCaption
                        ElseIf Shift = vbCtrlMask Then
                              frmMain.ImageZoomIn .LargeChange
                              RedoCaption
                        End If
                  Case 109, 189 ' "-" and Keypad "-"
                        If Shift = 0 Then
                              frmMain.ImageZoomOut .SmallChange
                              RedoCaption
                        ElseIf Shift = vbCtrlMask Then
                              frmMain.ImageZoomOut .LargeChange
                              RedoCaption
                        End If
                  Case vbKey0, 106 ' 0 and Keypad "*" -- reset position and size.
                        .value = 100
                        RedoCaption
                        Image1.Move 0, 0, gImageData.DefaultWidth, gImageData.DefaultHeight
                  Case 103, 55   ' 7 and Keypad 7
                        .value = .value / 2
                        RedoCaption
                  Case 104, 56   ' 8 and Keypad 8
                        .value = .value * 2
                        RedoCaption
                  Case vbKeyDown
                        Image1.Top = Image1.Top + MoveIncrement
                  Case vbKeyUp
                        Image1.Top = Image1.Top - MoveIncrement
                  Case vbKeyLeft
                        Image1.Left = Image1.Left - MoveIncrement
                  Case vbKeyRight
                        Image1.Left = Image1.Left + MoveIncrement
                  
                  Case vbKeyHome
                        Image1.Top = 0
                  Case vbKeyEnd
                        Image1.Top = picFullScreen.Height - Image1.Height
                        
                  Case vbKeyPageUp
                        If Image1.Top < -picFullScreen.Height Then
                              Image1.Top = Image1.Top + picFullScreen.Height
                        ElseIf Image1.Top < 0 Then
                              Image1.Top = 0
                        End If
                        
                  Case vbKeyPageDown
                        If Image1.Top + Image1.Height > picFullScreen.Height * 2 Then
                              Image1.Top = Image1.Top - picFullScreen.Height
                        ElseIf Image1.Top + Image1.Height > picFullScreen.Height Then
                              Image1.Top = picFullScreen.Height - Image1.Height
                        End If
                        
                  Case vbKeySpace, vbKeyN, 221   ' Right Bracket "]"
                        If Shift = 0 Then frmMain.BrowserExecuteNext
                  Case vbKeyBack, vbKeyP, 219   ' Left Bracket "["
                        If Shift = 0 Then frmMain.BrowserExecuteNext True
                        
                  Case vbKeyF11, vbKeyEscape
                        If Shift = 0 Then Unload frmFullScreen
            End Select
      End With

End Sub

Private Sub picfullscreen_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Attribute picfullscreen_MouseUp.VB_UserMemId = 1610809348
      If Not gImageData.Zoomed And Not gImageData.Moved And Button = vbLeftButton Then
            ' On a left click, we'll go to the next picture.  We spare no expense on ease of use.
            frmMain.BrowserExecuteNext
      ElseIf Not gImageData.Zoomed And Not gImageData.Moved And Button = vbRightButton Then
            ' On a right click, we go to the previous picture.
            ' Essentially, it'll means we don't need the toolbar open for picture manipulation.
            frmMain.BrowserExecuteNext True
      ElseIf Not gImageData.Moved And Not gImageData.Zoomed And Button = vbMiddleButton Then
            Unload frmFullScreen
      End If
      
      gImageData.Zoomed = False
      gImageData.Moved = False
End Sub

Private Sub RedoCaption()
Attribute RedoCaption.VB_UserMemId = 1610809355
      lblFileNameZoom = frmMain.agEditor.tag & " (" & frmMain.sliZoom.value & "%)  "
End Sub

