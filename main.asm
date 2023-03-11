.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

; Hotkey identifier
HKID equ 1

; Virtual key code of F7 key
VK_F7 equ 76h

.data
msg MSG <>
isTopMost dd 0

.code
main PROC
    ; Register a hotkey with the F7 key using the RegisterHotKey() function
    ; Parameters: HWND hWnd - Handle to the window that will receive hotkey messages (NULL means the application's message queue)
    ;             int id - Identifier of the hotkey
    ;             UINT fsModifiers - Modifier keys (0 means no modifiers)
    ;             UINT vk - Virtual key code of the hotkey (VK_F7 means F7 key)
    invoke RegisterHotKey, NULL, HKID, 0, VK_F7
    cmp eax, 0 ; If the hotkey registration fails, exit the program
    je ExitProgram

MessageLoop:
    ; Wait for a message
    invoke GetMessage, addr msg, NULL, 0, 0
    cmp eax, 0 ; If WM_QUIT is received, exit the program
    je ExitProgram

    ; If the message is a hotkey message
    cmp dword ptr [msg.message], WM_HOTKEY
    jne MessageLoop

    ; Get the handle of the foreground window using the GetForegroundWindow() function
    invoke GetForegroundWindow
    mov ebx, eax

    ; Toggle the window's topmost property
    invoke GetWindowLong, ebx, GWL_EXSTYLE
    mov dword ptr [isTopMost], eax
    test eax, WS_EX_TOPMOST
    jz SetTopMost
    invoke SetWindowPos, ebx, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE
    jmp MessageLoop
SetTopMost:
    invoke SetWindowPos, ebx, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE
    jmp MessageLoop

ExitProgram:
    ; Unregister the hotkey using the UnregisterHotKey() function
    invoke UnregisterHotKey, NULL, HKID
    invoke ExitProcess, 0
main ENDP
END main
