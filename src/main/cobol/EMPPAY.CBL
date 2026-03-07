       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPPAY.
       AUTHOR. ASHIS KUMAR NAIK.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       77 REC-COUNTER       PIC 9(1).
       01 EMP-RECORD.
          05 EMP-NAME.
             10 EMP-FNAME    PIC X(15) VALUE 'FRANCISCO'.
             10 EMP-LNAME    PIC X(15).
          05 EMP-HOURLY-RATE PIC 9(3)V99.
          05 EMP-OT-RATE     PIC V99.
          05 EMP-REWARD      PIC V99.
          05 EMP-HOURS       PIC 9(3).
          05 EMP-PAY-WEEK    PIC 9(7)V99.
          05 EMP-PAY-MONTH   PIC 9(7)V99.

       PROCEDURE DIVISION.

           PERFORM 100-INITIALIZATION.
           PERFORM 200-PAYMENT-WEEKLY.
           PERFORM 300-PAYMENT-MONTHLY.
           PERFORM 400-SHOW-OUTPUT.
           STOP RUN.

       100-INITIALIZATION.
           MOVE "Millard" TO EMP-FNAME.
           MOVE "Fillmore" TO EMP-LNAME.
           MOVE 19 TO EMP-HOURS.
           MOVE 23.50 TO EMP-HOURLY-RATE.

       200-PAYMENT-WEEKLY.
      * Logic Fix: Check 50 first, otherwise 40 overrides it.
           IF EMP-HOURS >= 50
              MOVE .50 TO EMP-OT-RATE
           ELSE IF EMP-HOURS >= 40
              MOVE .25 TO EMP-OT-RATE
           ELSE
              MOVE ZERO TO EMP-OT-RATE
           END-IF.

           COMPUTE EMP-PAY-WEEK = 
               (EMP-HOURS * EMP-HOURLY-RATE) * (1 + EMP-OT-RATE).

       300-PAYMENT-MONTHLY.
           IF EMP-HOURS > 150
              MOVE .50 TO EMP-REWARD
           ELSE
              MOVE ZERO TO EMP-REWARD
           END-IF.

           COMPUTE EMP-PAY-MONTH = 
               (EMP-PAY-WEEK * 4) * (1 + EMP-REWARD).

       400-SHOW-OUTPUT.
           DISPLAY "Name: " EMP-NAME.
           DISPLAY "Hours Worked Per Week: " EMP-HOURS.
           DISPLAY "Hourly Rate: " EMP-HOURLY-RATE.
           DISPLAY "Bonus-Rate: " EMP-OT-RATE.
           DISPLAY "Gross Pay Per Week: " EMP-PAY-WEEK.
           DISPLAY "Gross Pay Per Month: " EMP-PAY-MONTH.
           DISPLAY "Hi Chris - how's Loretta today?".