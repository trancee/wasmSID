
           *= $0801
           .BYTE $4C,$14,$08,$00,$97
TURBOASS   = 780
           .TEXT "780"
           .BYTE $2C,$30,$3A,$9E,$32,$30
           .BYTE $37,$33,$00,$00,$00
           LDA #1
           STA TURBOASS
           JMP MAIN

ROM
           LDA #$2F // %00101111
           STA 0    // D6510
           LDA #$37 // %00110111
           STA 1    // R6510
           CLI
           RTS


MAIN
           JSR PRINT
           .BYTE 13
           .TEXT "�MMUFETCH"
           .BYTE 0

           JSR ROM
           SEI

;A000 RAM-ROM-RAM
           LDY #1
           STY $24
           DEY
           STY $25
           LDA #$36
           STA 1
           LDA $A4DF
           PHA
           LDA $A4E0
           PHA
           LDA $A4E1
           PHA
           LDA $A4E2
           PHA
           LDA $A4E3
           PHA
           LDA #$86
           STA $A4DF
           LDA #1
           STA $A4E0
           LDA #0
           STA $A4E1
           STA $A4E2
           LDA #$60
           STA $A4E3
           LDA #$36
           LDX #$37
           JSR $A4DF
           PLA
           STA $A4E3
           PLA
           STA $A4E2
           PLA
           STA $A4E1
           PLA
           STA $A4E0
           PLA
           STA $A4DF

;B000 RAM-ROM-RAM
           LDY #1
           STY $14
           DEY
           STY $15
           LDA #$36
           STA 1
           LDA $B828
           PHA
           LDA $B829
           PHA
           LDA $B82A
           PHA
           LDA $B82B
           PHA
           LDA $B82C
           PHA
           LDA #$86
           STA $B828
           LDA #1
           STA $B829
           LDA #0
           STA $B82A
           STA $B82B
           LDA #$60
           STA $B82C
           LDA #$36
           LDX #$37
           JSR $B828
           PLA
           STA $B82C
           PLA
           STA $B82B
           PLA
           STA $B82A
           PLA
           STA $B829
           PLA
           STA $B828

;E000 RAM-ROM-RAM
           LDA #$86
           STA $EA77
           LDA #1
           STA $EA78
           LDA #0
           STA $EA79
           STA $EA7A
           LDA #$60
           STA $EA7B
           LDA #$35
           LDX #$37
           STA 1
           JSR $EA77

;F000 RAM-ROM-RAM
           LDY #1
           STY $C3
           DEY
           STY $C4
           LDA #$86
           STA $FD25
           LDA #1
           STA $FD26
           LDA #0
           STA $FD27
           STA $FD28
           LDA #$60
           STA $FD29
           LDA #$35
           LDX #$37
           STA 1
           JSR $FD25

;D000 RAM-ROM-RAM
           LDA $91
           PHA
           LDA $92
           PHA
           LDY #1
           STY $91
           DEY
           STY $92
           LDA #$34
           STA 1
           LDA #$86
           STA $D400
           LDA #1
           STA $D401
           LDA #0
           STA $D402
           STA $D403
           LDA #$60
           STA $D404
           LDA #$34
           LDX #$33
           STA 1
           JSR $D400
           PLA
           STA $92
           PLA
           STA $91

;D000 RAM-IO-RAM
           LDA #$37
           STA 1
           LDA #$85
           STA $D002
           LDA #1
           STA $D003
           LDA #0
           STA $D004
           LDA #$33
           STA 1
           LDA #$86
           STA $D000
           LDA #1
           STA $D001
           LDA #0
           STA $D002
           STA $D003
           LDA #$60
           STA $D004
           LDA #$34
           LDX #$37
           STA 1
           JSR $D000

           JSR ROM

OK
           JSR PRINT
           .TEXT " - OK"
           .BYTE 13,0
           LDA TURBOASS
           BEQ LOAD
WAIT       JSR $FFE4
           BEQ WAIT
           JMP $8000

LOAD
           LDA #47
           STA 0
           JSR PRINT
NAME       .TEXT "MMU"
NAMELEN    = *-NAME
           .BYTE 0
           LDA #0
           STA $0A
           STA $B9
           LDA #NAMELEN
           STA $B7
           LDA #<NAME
           STA $BB
           LDA #>NAME
           STA $BC
           PLA
           PLA
           JMP $E16F

PRINT      PLA
           .BLOCK
           STA PRINT0+1
           PLA
           STA PRINT0+2
           LDX #1
PRINT0     LDA !*,X
           BEQ PRINT1
           JSR $FFD2
           INX
           BNE PRINT0
PRINT1     SEC
           TXA
           ADC PRINT0+1
           STA PRINT2+1
           LDA #0
           ADC PRINT0+2
           STA PRINT2+2
PRINT2     JMP !*
           .BEND

PRINTHB
           .BLOCK
           PHA
           LSR A
           LSR A
           LSR A
           LSR A
           JSR PRINTHN
           PLA
           AND #$0F
PRINTHN
           ORA #$30
           CMP #$3A
           BCC PRINTHN0
           ADC #6
PRINTHN0
           JSR $FFD2
           RTS
           .BEND
