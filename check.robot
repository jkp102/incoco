.PROGRAM check.robot(error)
;
; ABSTRACT:
;
; INPUTS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;
; DATA STRUCT:
;
; MISC:  Program created in ACE version 3.7.2.6
;
;* Copyright (c) 2019 by SungJoon

;        LOCAL jtsafe[]

        error = 0
        REACTE err.rob.reacte        ; 여기서 에러 감시 시작
 10     IF (STATE(4) BAND 4) == 4 THEN    ; ESTOP 이 작동하고 있는 경우
            $sys.error = "E-Stop Button Pressed"
            GOTO 100
        END

        $sys.error = ""


        IF NOT SWITCH(POWER) THEN    ; Robot Power Switch OFF 상태
            SIGNAL -bo.robot.ready    ; PLC에 ready signal off

        END

        WHILE NOT SWITCH(POWER) DO    ; Robot Power 안들어오면 Power
            $sys.message = "Waiting Robot Power ON"

            WAIT
            ENABLE POWER        ; Software Power ON -> Panel 전원 깜빡 거림
        END

        $rob.status = ""

        IF PARAMETER(NOT.CALIBRATED) <> 0 THEN    ; Calibration 안 되있을 경우
            $sys.message = "Robot Calibrating..."

            error = 0

            CALIBRATE , error         ; Calibration 진행

            IF error < 0 GOTO 100

            DO
                WAIT

            UNTIL (STATE(1) BAND 7) OR (NOT SWITCH(POWER)) OR ((STATE(1) BAND 4))
            ; ETOP, Power ON, Robot is Under Program Control이면 대기

        ELSE                    ; Calibration 되있을 경우
            IF (NOT (STATE(1) BAND 7)) AND (NOT (STATE(3) BAND 5)) THEN
            ; Under Program Control, Computer Control 상태가 아닌 경우
                IF STATE(1) == 4 THEN    ; Manual Mode인 경우
                    $sys.error = "Robot is in Manual Mode"
                    error = -1
                END

                $sys.message = "Waiting MCP is in COMP mode" ; MCP , 즉 반도체 칩이 준비상태까지 기다리는중이라는 뜻?

                DO
                    WAIT

                UNTIL ((STATE(1) BAND 7)) OR ((STATE(3) BAND 5))
            ; Robot Under program control, Computer Control이 될때까지 대기
            END
            $sys.error = ""
        END

 100    DETACH ()

        RETURN

.END
