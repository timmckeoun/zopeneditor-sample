ASAM1    AMODE 31
ASAM1    CSECT
         USING ASAM1,R15
****************************************************************
* LICENSED MATERIALS - PROPERTY OF IBM
* "RESTRICTED MATERIALS OF IBM"
* (C) COPYRIGHT IBM CORPORATION 2020. ALL RIGHTS RESERVED
* US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
* OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
* CONTRACT WITH IBM CORPORATION
****************************************************************
*  SAMPLE PROGRAM ASAM1
*     AUTHOR: DOUG STOUT
*             IBM CORPORATION 2
*
*  A SIMPLE PROGRAM THAT:
*   - READS A QSAM FILE
*   - WRITES THE FIRST 80 BYTES OF EACH RECORD TO AN OUTPUT FILE
*     IN CHARACTER
*
*  PARAMETERS PASSED FROM CALLING PROGRAM:
*    NONE
*
*  FILES:
*    1. INPUT FILE IS QSAM AND HAS DD NAME = FILEIN
*         LRECL = 80
*    2. OUTPUT FILE IS QSAM OR SYSPRINT AND HAS DD NAME = FILEOUT
*         LRECL = 80
*
************************************************************
*                                  AT ENTRY, R13 = REGISTER SAVE AREA
*                                            R14 = RETURN ADDR
*                                            R15 = ADDR OF THIS PROGRAM
START    STM   R14,R12,12(R13)     SAVE REGISTERS IN PASSED SAVE AREA
         DROP  R15                 NO LONGER NEEDED AS BASE REGISTER
         LR    R12,R15             USE R12 AS THE BASE REGISTER
         USING ASAM1,R12           "
         LA    R14,SAVEAREA        R14 = ADDR OF NEW SAVE AREA
         ST    R13,4(R14)          STORE PREVIOUS SAVE AREA ADDR
         ST    R14,8(R13)          STORE NEW SAVE AREA ADDRESS
         LR    R13,R14             R13 = ADDR OF NEW SAVE AREA
         B     MAINLINE
         DS    0H
         DC    CL32'******** PROGRAM ASAM1 *********'
MAINLINE BAL   R11,OPENFILS
         BAL   R11,MAINLOOP
         BAL   R11,CLOSFILS
*
         MVC  STATUS,=C'RETURNING TO CALLING PROGRAM  '
*
RETURN00 L     R15,RETCODE
         L     R13,4(R13)          R13 = ADDR OF PREVIOUS SAVE AREA
         ST    R15,16(R13)         SAVE RETURN CODE
         LM    R14,R12,12(R13)     RESTORE REGISTERS (EXCEPT 13)
         BR    R14                 RETURN TO CALLER
*******************************************
* PROCEDURE MAINLOOP
*
MAINLOOP ST    R11,MAINLSAV      SAVE RETURN ADDRESS
*     * READ INPUT RECORD
MAINLTOP BAL   R11,READIN
*     * CHECK FOR END-OF-FILE
         CLC   EOFFLAG,=X'FF'      END OF FILE?
         BE    MAINLEX               IF YES - EXIT MAIN LOOP
*     * CALL SUBPROGRAM TO GET HEX CHARACTERS
         MVC   STATUS,=C'CALLING SUBPROGRAM ASAM2      '
         LA    R13,SAVEAREA
*     * WRITE LINE: 'RECORD NUMBER NNNNNN'
         UNPK  OUTRECCT,RECCOUNT   FORMAT RECORD COUNT
         OI    OUTRECCT+9,X'F0'
         MVC   OUTREC,OUTLINE1     REC NUM LINE
         BAL   R11,WRITEOUT
*     * WRITE RULE LINES   ....5...10...15...20...
         MVC   OUTREC,OUTLINE2
         BAL   R11,WRITEOUT
         MVC   OUTREC,OUTLINE3
         BAL   R11,WRITEOUT
*     * WRITE DATA LINE 1: (CHARACTER FORMAT)
         MVC   OUTREC,INREC
         BAL   R11,WRITEOUT
*     * WRITE BLANK LINE
         MVC   OUTREC,BLANKS
         BAL   R11,WRITEOUT
*     * GO BACK TO TOP OF LOOP
         B     MAINLTOP
*
LOADERR  WTO   '* ASAM1: ERROR LOADING PROGRAM ASAM2 '
         MVI   EOFFLAG,X'FF'
MAINLEX  L     R11,MAINLSAV
         BR    R11                    RETURN TO MAINLINE LOGIC
*
*******************************************
* PROCEDURE OPENFILS
*
OPENFILS ST    R11,OPENFSAV
         MVC  STATUS,=C'IN OPENFILS SUBROUTINE        '
         SLR   R15,R15                SET DEFAULT RETURN CODE TO ZERO
         OPEN  (FILEOUT,OUTPUT)       OPEN DDNAME
         LTR   R15,R15                OPEN RC = 0 ?
         BNZ   BADOPENI                 IF NO - THEN ERROR
         OPEN  (FILEIN,INPUT)         OPEN DDNAME
         LTR   R15,R15                OPEN RC = 0 ?
         BNZ   BADOPENI                 IF NO - THEN ERROR
         L     R11,OPENFSAV
         BR    R11                    RETURN TO MAINLINE LOGIC
BADOPENI WTO   '* ASAM1: ERROR OPENING INPUT FILE    '
         ST    R15,RETCODE
         B     RETURN00
BADOPENO WTO   '* ASAM1: ERROR OPENING OUTPUT FILE   '
         ST    R15,RETCODE
         B     RETURN00
*******************************************
* PROCEDURE CLOSFILS
*
CLOSFILS ST    R11,CLOSFSAV      SAVE RETURN ADDRESS
         MVC   STATUS,=C'IN CLOSFILS PROCEDURE         '
         CLOSE FILEOUT
         CLOSE FILEIN
         L     R11,CLOSFSAV
         BR    R11               RETURN
*******************************************
* PROCEDURE READIN
*
READIN   ST    R11,READISAV
         MVC   STATUS,=C'IN READIN PROCEDURE           '
         SLR   R15,R15                SET DEFAULT RETURN CODE TO ZERO
         GET   FILEIN,INREC           READ INPUT RECORD
         AP    RECCOUNT,=PL1'1'       INCREMENT RECORD COUNTER
         B     READIEX
READIEOF MVI   EOFFLAG,X'FF'
READIEX  L     R11,READISAV
         BR    R11
*
*******************************************
* PROCEDURE WRITEOUT
*
WRITEOUT ST    R11,WRITOSAV
         MVC   STATUS,=C'IN WRITEOUT PROCEDURE         '
         PUT   FILEOUT,OUTREC         WRITE OUTPUT RECORD
         L     R11,WRITOSAV
         BR    R11
********************************************************
* STORAGE AREAS
*
EYECATCH DC    CL32'*** PROGRAM ASAM1 DATA AREAS ***'
FILECC   DC    H'0'                  MAX RETURN CODE FROM FILE OPENS
RECCOUNT DC    PL4'0'                INPUT RECORD COUNT
PROCCNT  DC    PL4'0'                PROCEDURE COUNT
STATUS   DC    CL30' '               CURRENT PROGRAM STATUS
EOFFLAG  DC    XL1'00'               END OF INPUT FILE FLAG
INREC    DC    CL80' '               INPUT RECORD
OUTREC   DC    CL80' '               OUTPUT RECORD
RETCODE  DC    F'0'                  DEFAULT RETURN CODE IS ZERO
MAINLSAV DC    F'0'
OPENFSAV DC    F'0'
CLOSFSAV DC    F'0'
READISAV DC    F'0'
WRITOSAV DC    F'0'
*
OUTLINE1 DS    0CL80
         DC    CL14'RECORD NUMBER '
OUTRECCT DC    CL10'          '
         DC    56C' '
*
OUTLINE2 DS    0CL80
         DC    CL40'....0....1....1....2....2....3....3....4'
         DC    CL40'....4....5....5....6....6....7....7....8'
*
OUTLINE3 DS    0CL80
         DC    CL40'....5....0....5....0....5....0....5....0'
         DC    CL40'....5....0....5....0....5....0....5....0'
*
BLANKS   DC    80C' '
*
*        LTORG
SAVEAREA DC    18F'0'
********************************************************
* FILE DEFINITIONS
*
FILEOUT  DCB   DSORG=PS,RECFM=FB,MACRF=(PM),LRECL=80,                  X
               DDNAME=FILEOUT
FILEIN   DCB   DSORG=PS,RECFM=FB,MACRF=(GM),LRECL=80,                  X
               DDNAME=FILEIN,EODAD=READIEOF
*
         COPY  REGISTRS
*
         END
