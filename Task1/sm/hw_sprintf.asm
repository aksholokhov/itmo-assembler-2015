global hw_sprintf

section .text

CONTROL_FLAG        equ  1              ;%  short name - C_flag
SIGN_FULL_FLAG      equ  1 << 1         ;+  short name - SF_flag
LEFT_ALIGN_FLAG     equ  1 << 2         ;-  short name - LA_flag
FILL_ZERO_FLAG      equ  1 << 3         ;0  short name - FZ_flag
ONLY_MINUS_FLAG     equ  1 << 4         ;   short name - OM_flag
LONG_FLAG           equ  1 << 5         ;ll short name - L_flag
SIGNED_NUM_FLAG     equ  1 << 6         ;id short name - SN_flag
REVERTED_SIGN_FLAG  equ  1 << 7         ;   short name - RS_flag


; SPRINTF FUNCTION
; edi - output stream address
; esi - format stream address
; ebp - current number address
; bh - flags
; bl - current character
; edx - width (0 as default)
; ecx - start of the control sequence

hw_sprintf:         push ebp
                    push esi
                    push edi
                    push ebx

                    xor ebx, ebx
                    xor edx, edx
                    xor ecx, ecx

                    mov edi, [esp + 20]     ; edi = out
                    mov esi, [esp + 24]     ; esi = format
                    lea ebp, [esp + 28]     ; ebp =

.char_matching      mov bl, byte [esi]      ; write the next format char to bl
                    cmp bl, '%'             ;
                    jne .read_control_seq
                    jmp .set_C_flag

.read_control_seq   cmp bl, '+'
                    je  .set_SF_flag
                    cmp bl, '-'
                    je  .set_LA_flag
                    cmp bl, ' '
                    je  .set_OM_flag
                    cmp bl, '0'
                    je  .set_FZ_flag
                    cmp bl, 'u'
                    je  .print_unsigned
                    cmp bl, 'i'
                    je  .print_signed
                    cmp bl, 'd'
                    je  .print_signed
                    cmp bl, 'l'
                    je  .try_set_L_flag
                    cmp bl, '0'
                    jg  .try_set_width
                    jmp .print_as_is

.next_char          cmp bl, 0
                    je  .after_all
                    inc esi
                    jmp .char_matching

.after_all          pop ebx
                    pop edi
                    pop esi
                    pop ebp
                    ret


;Flags setters
;set the value of the chosen flag and do related tasks

.set_C_flag         test bh, CONTROL_FLAG
                    jnz .print_as_is
                    or  bh, CONTROL_FLAG
                    mov ecx, esi             ;OR mov ecx, esi
                    jmp .read_control_seq

.set_SF_flag        or bh, SIGN_FULL_FLAG
                    jmp .next_char

.set_OM_flag        or bh, ONLY_MINUS_FLAG
                    jmp .next_char

.set_LA_flag        or bh, LEFT_ALIGN_FLAG
                    jmp .next_char

.set_FZ_flag        or bh, FILL_ZERO_FLAG
                    jmp .next_char

.try_set_L_flag     cmp [esi+1], bl
                    jne .next_char
                    or  bh, LONG_FLAG
                    jmp .next_char

.try_set_width      cmp bl, 9
                    jg  .print_as_is
                    jmp .read_int

;read functions
;reads the int from input buffer and stores it to eax
;input buffer address - esi
;output int - eax

.read_int           xor edx, edx
.loop_read_int      mul edx, 10
                    mov bl, byte [esi]
                    sub bl, '0'
                    add edx, bl
                    inc esi
                    cmp byte [esi], '9'
                    jg .char_matching
                    cmp byte [esi], '1'
                    jge .loop_read_int
                    jmp .char_matching


;Print functions

;prints numbers or sequences
print_as_is         mov al, [ecx]
                    mov [edi], al
                    inc edi
                    inc ecx
                    cmp ecx, esi
                    jbe .print_as_is
                    xor al, al
                    xor ecx, ecx
                    xor bh, bh
                    jmp .next_char


print_char          xor eax, eax
                    mov [edi], bl
                    inc edi
                    jmp .next_char


print_signed        or bh, SIGNED_NUM_FLAG
                    jmp .print_signed

print_unsigned      test bh, LONG_FLAG
                    jnz .print_int
                    jmp .print_long

;Prints integer, stored in

print_int           push edx                ;Width (stored in [esp+1]
                    push bh                 ;Flags (stored in [esp]
                    mov ecx, [ebp]
                    test byte [esp], SIGNED_NUM_FLAG
                    jz  .sgate1             ;Length calculating
                    cmp ecx, 0
                    jl  .revert_sign
;Length calculating, stores length in eax
.stage1             xor eax, eax
.loop_stage1        div ecx, 10
                    inc eax
                    cmp ecx, 0
                    jg  .loop_stage1
                    mov ecx, [ebp]
                    push .stage2
                    jmp print_left_part
;module print
.stage2             lea edi, [edi+eax]
                    mov ecx, [ebp]
.loop_stage2        dec edi
                    mov edx, ecx
                    div edx, 10
                    mul edx, 10
                    sub edx, ecx
                    neg edx
                    mov [edi], edx
                    cmp ecx, 0
                    jg .loop_stage2
                    lea edi, [edi+eax]
                    push .stage3
                    test byte[esp+4], LEFT_ALIGN_FLAG
                    jnz print_right_part
                    add esp, 4
.stage3             add ebp, 4
                    jmp cleaner
;ecx - int, needs to be reverted

.revert_sign        or byte [esp], REVERTED_SIGN_FLAG
                    neg ecx
                    mov [ebp], ecx
                    ret

print_long          ret

print_left_part

print_right_part

; other functions

