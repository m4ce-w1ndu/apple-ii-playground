; hello.s - A simple "Hello, World!" program for the Apple II

.setcpu "6502"

; ROM routine addresses
COUT        = $FDED                 ; Character output routine
HOME        = $FC58                 ; Clears the screen and homes the cursor

.org $6000                          ; Start from $6000 (process address space starts here)

start:
    jsr HOME                        ; Clear the screen
    ldx #$00                        ; Initializse X register to 0

print_loop:
    lda message, x                  ; Load message address (first character) into A
    beq done                        ; branch to "done" if the character is NULL terminator
    ora #$80                        ; Set the high bit for text mode
    stx $06                         ; save X (DOS 3.3 compatibility)
    jsr COUT                        ; Print the character to the screen
    ldx $06                         ; restore X
    inx                             ; Increment X to point to the next character
    jmp print_loop                  ; If not reached end of string, keep going

done:
    rts                             ; Return to BASIC / Monitor

; Data section
message:
    .byte "HELLO, WORLD!", $0D, $00 ; $0D is CR, $00 terminator of string