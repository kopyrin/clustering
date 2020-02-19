SET EXCLUSIVE ON
SET RESOURCE TO
CLOSE ALL
SET SAFETY OFF
SET STATUS OFF

CLEAR
? TIME()

WAIT windows NOWAIT "��������� �������"

**** ��������� ������� ***
**** ���������� ���� ***
oDiclemms = CREATEOBJECT("_diclemms")
oDiclemms.open()

*** ������������ ����� ***
oWords = CREATEOBJECT("_words")

*** ������������ ����� ***
oLemmas = CREATEOBJECT("_lemmas")

*** ������ �������� � �����
oPretext = CREATEOBJECT("_pretext")
oPretext.open()

*** ����� �����
oMinus = CREATEOBJECT("_minus")
oMinus.open()

**** �������� ***
oClasters = CREATEOBJECT("_clasters")
oClasters.open()

IF oClasters.append_data()
    oPretext.append_data()
    oMinus.append_data()

    ***** ��������� ����� �� �����
    SELECT clasters
    SET ORDER TO
    m.nReccount = RECCOUNT()

    * ������ ������ - �������� �� �����
    SCAN all
        WAIT windows NOWAIT "�������� ����� �� �����. " + ALLTRIM(STR((RECNO()*100)/m.nReccount)) + " % "
        oClasters.key       = clasters.key
        oClasters.frequency = clasters.frequency
        oClasters.count = 0
        oClasters.w1 = ""
        oClasters.w2 = ""
        oClasters.w3 = ""
        oClasters.w4 = ""
        oClasters.w5 = ""
        oClasters.w6 = ""
        oClasters.w7 = ""
        m.lZapret = .f.
        m.nL = 0
        * ���������� ���� � ������� 
        oClasters.count = GETWORDCOUNT(oClasters.key,' ')
        IF oClasters.count > 8
            SELECT clasters
            LOOP
        endif
        
        FOR m.nCount =1 TO 8
            * �������� �����
            m.cWord = GETWORDNUM(oClasters.key, m.nCount, ' ')
            * ���� ����� ���������
            IF NOT EMPTY(m.cWord)
                * ���� � ������� ����� ���� �����
                * ���� ������� �� ������� �� �����
                IF oMinus.seek_word(m.cWord)
                    SELECT clasters
                    m.lZapret = .t.
                    exit
                ENDIF
            
                * ���� � ������� ��������� �����
                * ���� ������� �� ����� ��������� �����
                IF oPretext.seek_word(m.cWord)
                    SELECT clasters                
                    LOOP
                ENDIF
                m.nL = m.nL + 1
                DO case
                    CASE m.nL = 1
                        oClasters.w1 = m.cWord
                    CASE m.nL = 2
                        oClasters.w2 = m.cWord
                    CASE m.nL = 3
                        oClasters.w3 = m.cWord
                    CASE m.nL = 4
                        oClasters.w4 = m.cWord
                    CASE m.nL = 5
                        oClasters.w5 = m.cWord
                    CASE m.nL = 6
                        oClasters.w6 = m.cWord
                    CASE m.nL = 7
                        oClasters.w7 = m.cWord
                endcase
            ENDIF
        ENDFOR

        IF NOT m.lZapret
            * ������� ���� �����������
            IF oClasters.frequency > 0 and oClasters.count >0
                oClasters.share = oClasters.frequency  / oClasters.count
            ENDIF

            SELECT clasters
            oClasters.gather_data
        ENDIF 
    ENDSCAN
    

    * ���������� �� ���� ������
    FLUSH
    

    * �������� ������� ����
    oWords.create()

    SELECT words
    m.nReccount = RECCOUNT()

    * ���� ����� ��� ����
    SCAN all
        WAIT windows NOWAIT "���� ����� ��� ���� � �������. " + ALLTRIM(STR((RECNO()*100)/m.nReccount)) + " % "
        oWords.words = words.words
        oWords.lemma = oDicLemms.SearchByWord(oWords.words)
        replace words.lemma WITH oWords.lemma
    endscan

    * ������� ������ ������������ ����
    oLemmas.create() 


    *** ������������� ������  � ����� ***
    oLemmas.SetStatus()


    * ���������� �� ���� ������
    FLUSH

    WAIT windows NOWAIT "������������� ������� � ���� ��������"
    *** ������������� ������� � ���� ��������
    SELECT words
    SET ORDER TO words
    SELECT lemmas
    SET ORDER TO lemma

    DECLARE aStatus [7]
    SELECT clasters
    SET ORDER TO
    m.nReccount = RECCOUNT()
    SCAN all
        oClasters.scatter_data()
        oClasters.wes = ""
        WAIT windows NOWAIT "�������� ����� � ��������. " + ALLTRIM(STR((RECNO()*100)/m.nReccount)) + " % "
    
        aStatus[1] = oClasters.setStatus(oClasters.w1)
        aStatus[2] = oClasters.setStatus(oClasters.w2)
        aStatus[3] = oClasters.setStatus(oClasters.w3)
        aStatus[4] = oClasters.setStatus(oClasters.w4)
        aStatus[5] = oClasters.setStatus(oClasters.w5)
        aStatus[6] = oClasters.setStatus(oClasters.w6)
        aStatus[7] = oClasters.setStatus(oClasters.w7)
        
        IF EMPTY(oClasters.w1+oClasters.w2+Clasters.w3+oClasters.w4+oClasters.w5+oClasters.w6+oClasters.w7)
            LOOP
        endif

        ASORT(aStatus,1,ALEN(aStatus),1)
        * ������ ��������� ���� � ������
        m.nStatus = aStatus[1]
        FOR m.nCountStatus = 2 TO 7
            IF m.nStatus = aStatus[m.nCountStatus]
                aStatus[m.nCountStatus] = ""
            ELSE
                m.nStatus = aStatus[m.nCountStatus]
            ENDIF
        endfor

        FOR m.nCount = 1 TO 7
            IF NOT EMPTY(aStatus[m.nCount]) 
                m.cW   = ALLTRIM(SUBSTR(aStatus[m.nCount],11,30))+ " "
                m.cWes = STR(99999-VAL(SUBSTR(aStatus[m.nCount],1,10)))+ " "
            ELSE
                m.cW   = ""
                m.cWes = ""
            ENDIF
            DO case
                CASE m.nCount =1 
                    oClasters.w1 = m.cW
                CASE m.nCount =2 
                    oClasters.w2 = m.cW
                CASE m.nCount = 3 
                    oClasters.w3 = m.cW
                CASE m.nCount = 4 
                    oClasters.w4 = m.cW
                CASE m.nCount = 5 
                    oClasters.w5 = m.cW
                CASE m.nCount = 6 
                    oClasters.w6 = m.cW
                CASE m.nCount = 7 
                    oClasters.w7 = m.cW
            ENDCASE
            oClasters.wes = oClasters.wes + m.cWes
        ENDFOR 
        SELECT clasters
        oClasters.gather_data
    ENDSCAN

    oClasters.setColor()

    * ���������� �� ���� ������
    FLUSH

    oClasters.Export()
    oWords.Export()
    oLemmas.Export()

ENDIF

* ���������� �� ���� ������
FLUSH

MODIFY FILE words.txt nowait
MODIFY FILE minus.txt nowait
MODIFY FILE pretext.txt nowait
MODIFY FILE lemmas.txt nowait


WAIT windows NOWAIT "������!"
? TIME()

oClasters.close()
oWords.close()
oPretext.close()
oMinus.close()
oLemmas.close()
oDicLemms.close()

******************************
*  ����� _diclemms
******************************
DEFINE CLASS _diclemms as Custom
    FUNCTION open

        IF FILE("diclemms.dbf")
            SELECT 0
            USE diclemms.dbf
        ELSE

            CREATE TABLE diclemms FREE  ;
               (word  C(30),;
                lemma C(30))

            INDEX ON word TAG word
            INDEX ON lemma TAG lemma
        ENDIF
        
        IF FILE('diclemms.txt') 
            SELECT diclemms
            ZAP
            WAIT windows NOWAIT "���������� ������ �� ����� diclemms.txt"
            APPEND FROM diclemms.txt FIELDS word, lemma DELIMITED WITH TAB
            IF FILE("diclemms.txt-old")
                ERASE diclemms.txt-old
            ENDIF
            RENAME diclemms.txt TO diclemms.txt-old
        endif           

    ENDFUNC

    FUNCTION SearchByWord(m.cWord)
        IF LEN(m.cWord) < 29
            m.cWord = m.cWord + SPACE(30-LEN(m.cWord))
        endif
        SELECT diclemms
        SET ORDER TO word
        SEEK(m.cWord)
        IF FOUND()
            IF EMPTY(diclemms.lemma)
                RETURN m.cWord
            ELSE
                return diclemms.lemma
            endif
        ELSE
            INSERT INTO diclemms(word) VALUES (m.cWord)
            RETURN m.cWord
        ENDIF
    ENDFUNC

    FUNCTION View
        SELECT diclemms
        SET ORDER TO word
        GO top
        BROWSE LAST FIELDS word :H = '�����',;
                           lemma :H = '�����' ;
        TITLE '������� ����' NOWAIT
    ENDFUNC
    
    FUNCTION close
        USE IN diclemms

ENDDEFINE


******************************
*  ����� _clasters
******************************
DEFINE CLASS _clasters as Custom
    key =""
    frequency = 0
    COUNT = 0
    w1 = ""
    w2 = ""
    w3 = ""
    w4 = ""
    w5 = ""
    w6 = ""
    w7 = ""
    share = 0
    wes = ""
    color = .f.

    FUNCTION scatter_data
        this.key       = clasters.key      
        this.frequency = clasters.frequency
        this.count     = clasters.count    
        this.w1        = clasters.w1       
        this.w2        = clasters.w2       
        this.w3        = clasters.w3       
        this.w4        = clasters.w4       
        this.w5        = clasters.w5       
        this.w6        = clasters.w6       
        this.w7        = clasters.w7       
        this.share     = clasters.share    
        this.color     = clasters.color    
        this.wes       = clasters.wes      
    ENDFUNC

    FUNCTION gather_data
        replace clasters.key       WITH this.key,;
                clasters.frequency WITH this.frequency,;
                clasters.count     WITH this.count    ,;
                clasters.w1        WITH this.w1       ,;
                clasters.w2        WITH this.w2       ,;
                clasters.w3        WITH this.w3       ,;
                clasters.w4        WITH this.w4       ,;
                clasters.w5        WITH this.w5       ,;
                clasters.w6        WITH this.w6       ,;
                clasters.w7        WITH this.w7       ,;
                clasters.share     WITH this.share    ,;
                clasters.color     WITH this.color    ,;
                clasters.wes       WITH this.wes  
    ENDFUNC

    FUNCTION open
        CREATE TABLE clasters FREE  ;
           (key C(254) ,;
            frequency I,;
            count I,;
            w1 C(30),;
            w2 C(30),;
            w3 C(30),;
            w4 C(30),;
            w5 C(30),;
            w6 C(30),;
            w7 C(30),;
            share F(15,5),;
            color L,;
            wes C(70) )
        INDEX ON alltrim(w1)+alltrim(w2)+alltrim(w3)+alltrim(w4)+alltrim(w5)+alltrim(w6)+alltrim(w7)+STR(999999-frequency) TAG group
        INDEX ON wes+STR(999999-frequency) TAG wes
        SET ORDER TO
        
    ENDFUNC

    FUNCTION close
        USE IN clasters
        IF FILE('clasters.dbf')
            ERASE clasters.dbf
            ERASE clasters.cdx
        endif
    
    ENDFUNC 

    ***** ��������� ������ �� �����
    FUNCTION append_data
        IF FILE("clasters.txt")
            SELECT clasters
            ZAP
            WAIT windows NOWAIT "���������� ������ �� ����� clasters.txt"
            APPEND FROM clasters.txt FIELDS key, frequency DELIMITED WITH TAB
            RETURN  .t.
        ELSE
            RETURN .f.
        endif
    ENDFUNC


    FUNCTION SetStatus(m.cWord)
        IF EMPTY(m.cWord)
            RETURN ""
        endif
        
        SELECT words
        SEEK(m.cWord)
        IF  FOUND()
            m.cLemma = words.lemma
            SELECT lemmas
            SEEK(m.cLemma)
            IF FOUND()
                 return STR(Lemmas.status) + Lemmas.lemma 
            ELSE 
                RETURN ""
            ENDIF
        ELSE 
            RETURN ""
        Endif
    ENDFUNC

    FUNCTION Export
        WAIT windows NOWAIT "��������� ������ clasters"
        IF FILE("clasters.txt-old")
            ERASE clasters.txt-old
        ENDIF
        RENAME clasters.txt TO clasters.txt-old
        SELECT clasters
        SET ORDER TO WES
        IF FILE('clasters-long.txt')  && ���� ����������? 
            IF FILE("clasters-long.txt")
                ERASE clasters-long.txt
            ENDIF
           m.nFile = FCREATE('clasters-long.txt')  && ���� ���, ������� ���
        ELSE
           m.nFile = FCREATE('clasters-long.txt')  && ���� ���, ������� ���
        ENDIF
        IF m.nFile < 0  && �������� ������� ������ �������� ��� �������� �����
           WAIT '���������� ������� ��� ������� ����' WINDOW NOWAIT
        ELSE  && ���� ��� ������, ������ � ����
            SCAN ALL FOR NOT EMPTY(w1+w2+w3+w4+w5+w6+w7)
                m.cWord = ALLTRIM(key) + CHR(9) 
                m.cWord = m.cWord + ALLTRIM(str(frequency)) + CHR(9) 
                m.cWord = m.cWord + ALLTRIM(w1)
                m.cWord = m.cWord + IIF(not EMPTY(w2)," " + ALLTRIM(w2),"")
                m.cWord = m.cWord + IIF(not EMPTY(w3)," " + ALLTRIM(w3),"")
                m.cWord = m.cWord + IIF(not EMPTY(w4)," " + ALLTRIM(w4),"")
                m.cWord = m.cWord + IIF(not EMPTY(w5)," " + ALLTRIM(w5),"")
                m.cWord = m.cWord + IIF(not EMPTY(w6)," " + ALLTRIM(w6),"")
                m.cWord = m.cWord + IIF(not EMPTY(w7)," " + ALLTRIM(w7),"")
                m.cWord = m.cWord + CHR(13)+ CHR(10)                
               =FWRITE(m.nFile, m.cWord )
            ENDSCAN 
        ENDIF
        =FCLOSE(m.nFile)  && ��������� ����
        FFLUSH(m.nFile)

        IF FILE('clasters-short.txt')  && ���� ����������? 

            * ������� ���
            IF FILE("clasters-short.txt")
                ERASE clasters-short.txt
            ENDIF
        ENDIF
        m.nFile = FCREATE('clasters-short.txt')  && ������� ���
        
        IF m.nFile < 0  && �������� ������� ������ �������� ��� �������� �����
           WAIT '���������� ������� ��� ������� ����' WINDOW NOWAIT
        ELSE  && ���� ��� ������, ������ � ����
            SCAN ALL FOR color
                m.cWord =           ALLTRIM(key) + CHR(9) 
                m.cWord = m.cWord + ALLTRIM(str(frequency)) + CHR(9) 
                m.cWord = m.cWord + ALLTRIM(w1)
                m.cWord = m.cWord + IIF(not EMPTY(w2)," " + ALLTRIM(w2),"")
                m.cWord = m.cWord + IIF(not EMPTY(w3)," " + ALLTRIM(w3),"")
                m.cWord = m.cWord + IIF(not EMPTY(w4)," " + ALLTRIM(w4),"")
                m.cWord = m.cWord + IIF(not EMPTY(w5)," " + ALLTRIM(w5),"")
                m.cWord = m.cWord + IIF(not EMPTY(w6)," " + ALLTRIM(w6),"")
                m.cWord = m.cWord + IIF(not EMPTY(w7)," " + ALLTRIM(w7),"")
                m.cWord = m.cWord + CHR(13)+ CHR(10)                
               =FWRITE(m.nFile, m.cWord )
            ENDSCAN 
        ENDIF
        =FCLOSE(m.nFile)  && ��������� ����
        FFLUSH(m.nFile)
        
        IF FILE('clasters-minus.txt')  && ���� ����������? 
            * ������� ��� 
            IF FILE("clasters-minus.txt")
                ERASE clasters-minus.txt
            ENDIF
        ENDIF
        m.nFile = FCREATE('clasters-minus.txt')  && ���� ���, ������� ���
        IF m.nFile < 0  && �������� ������� ������ �������� ��� �������� �����
           WAIT '���������� ������� ��� ������� ����' WINDOW NOWAIT
        ELSE  && ���� ��� ������, ������ � ����
            SCAN ALL FOR EMPTY(w1+w2+w3+w4+w5+w6+w7)
                m.cWord = ALLTRIM(key) + CHR(9) 
                m.cWord = m.cWord + ALLTRIM(str(frequency)) + CHR(9) 
                m.cWord = m.cWord + ALLTRIM(w1)
                m.cWord = m.cWord + IIF(not EMPTY(w2)," " + ALLTRIM(w2),"")
                m.cWord = m.cWord + IIF(not EMPTY(w3)," " + ALLTRIM(w3),"")
                m.cWord = m.cWord + IIF(not EMPTY(w4)," " + ALLTRIM(w4),"")
                m.cWord = m.cWord + IIF(not EMPTY(w5)," " + ALLTRIM(w5),"")
                m.cWord = m.cWord + IIF(not EMPTY(w6)," " + ALLTRIM(w6),"")
                m.cWord = m.cWord + IIF(not EMPTY(w7)," " + ALLTRIM(w7),"")
                m.cWord = m.cWord + CHR(13)+ CHR(10)                
               =FWRITE(m.nFile, m.cWord )
            ENDSCAN 
        ENDIF
        =FCLOSE(m.nFile)  && ��������� ����    
        FFLUSH(m.nFile)    
    ENDFUNC

    FUNCTION SetColor
        SELECT clasters
        SET ORDER TO wes
        m.nReccount = RECCOUNT()
        m.nCountRec = 0
        m.cWes = ""

        SCAN all
            m.nCountRec = m.nCountRec + 1
            WAIT windows NOWAIT "���� ������� ��������� " + ALLTRIM(STR((RECNO()*100)/m.nReccount))
            IF m.cWes == Clasters.Wes
                replace clasters.color WITH .f.
            ELSE
                replace clasters.color WITH .t.
                m.cWes = Clasters.Wes
            ENDIF
        endscan
    ENDFUNC

    FUNCTION View
        SELECT clasters
        SET ORDER TO group 

        GO top
        BROWSE FIELDS key                                                :H = '������',;
                      group=ALLTRIM(w1)+" "+ALLTRIM(w2)+" "+ALLTRIM(w3)+" "+ALLTRIM(w4)+" "+ALLTRIM(w5)+" "+ALLTRIM(w6)+" "+ALLTRIM(w7) :H = '�������',;
                      frequency :H = '���������';
        TITLE '��������' noedit NOWAIT name clastersBrowse

        with clastersBrowse
            .deletemark = .f.
            .highlightrow = .t.
            .backcolor = rgb(255,255,255)
            .column1.DynamicBackColor = "IIF(color = .t., RGB(255,255,0), RGB(255,255,255))"
            .column2.DynamicBackColor = "IIF(color = .t., RGB(255,255,0), RGB(255,255,255))"
            .column3.DynamicBackColor = "IIF(color = .t., RGB(255,255,0), RGB(255,255,255))"
            .refresh()
        endwith

    ENDFUNC

ENDDEFINE


******************************
*  ����� _words
******************************
DEFINE CLASS _words as Custom
    words      = ""
    frecuency  = 0
    COUNT      = 0
    lemma      = ""
    count_lemm = 0
    
    FUNCTION create
        WAIT windows NOWAIT "�������� ������� ���� "
        SELECT Clasters.w1 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w1);
         GROUP BY Clasters.w1;
         union;
        SELECT Clasters.w2 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w2);
         GROUP BY Clasters.w2;
         union;
        SELECT Clasters.w3 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w3);
         GROUP BY Clasters.w3;
         union;
        SELECT Clasters.w4 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w4);
         GROUP BY Clasters.w4;
         union;
        SELECT Clasters.w5 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w5);
         GROUP BY Clasters.w5;
         union;
        SELECT Clasters.w6 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w6);
         GROUP BY Clasters.w6;
         union;
        SELECT Clasters.w7 as words,;
              SUM(Clasters.frequency) AS frequency,;
              SUM(Clasters.count)     AS count,;
              SUM(clasters.share)    as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w7);
         GROUP BY Clasters.w7;
         INTO CURSOR temp1

        SELECT temp1.words      as words,;
               SUM(temp1.share) as share,;
               "                   " as lemma;
         FROM temp1;
         GROUP BY 1;
         ORDER BY 2;
         INTO table words.dbf

         INDEX ON words TAG words
         INDEX ON share TAG share
         SET ORDER TO
         
         USE IN temp1
        
    ENDFUNC
    
    FUNCTION close
        IF USED('words')
            USE IN words
        endif
        IF FILE('words.dbf')
            ERASE words.dbf
            ERASE words.cdx
        endif
    ENDFUNC
    

    FUNCTION Export
        WAIT windows NOWAIT "��������� ������ words"
        SELECT words
        SET ORDER TO share desc
        copy TO words.txt DELIMITED WITH TAB FIELDS words, share FOR NOT EMPTY(words)
    ENDFUNC


ENDDEFINE

******************************
*  ����� _lemmas
******************************
DEFINE CLASS _lemmas as Custom

    lemma = ""
    count_lemm = 0
    frec_lemm = 0
    weight = 0
    status = 0

    FUNCTION create 
        SELECT Words.lemma as lemma, ;
           Words.share as weight,;
           000000000 as status;
         FROM words;
         ORDER by 2 desc;
         INTO TABLE lemmas.dbf

         INDEX ON lemma TAG lemma
         INDEX ON weight TAG weight
         INDEX ON status TAG status
         SET ORDER TO

    ENDFUNC
    
    FUNCTION close
        IF USED('lemmas')
            USE IN lemmas
        endif

        IF FILE('lemmas.dbf')
            ERASE lemmas.dbf
            ERASE lemmas.cdx
        endif
    ENDFUNC


    FUNCTION SearchByWord()
        m.cAlias = ALIAS()
        IF LEN(this.lemma) < 29
            this.lemma = this.lemma + SPACE(30-LEN(this.lemma))
        endif
        SELECT lemmas
        SET ORDER TO lemma
        SEEK(this.lemma)
        IF FOUND()
            IF EMPTY(lemmas.lemma)
                SELECT (m.cAlias)
                RETURN this.lemma
            ELSE
                SELECT (m.cAlias)
                return lemmas.lemma
            endif
        ELSE
            RETURN ""
        ENDIF
    ENDFUNC

    FUNCTION SearchByStatus(m.nStatus)
        m.cAlias = ALIAS()
        SELECT lemmas
        SET ORDER TO status
        SEEK(m.nStatus)
        IF FOUND()
            m.cLemma = ALLTRIM(lemmas.lemma) + "  "
            SELECT (m.cAlias)
            return m.cLemma 
        ELSE
            SELECT (m.cAlias)
            RETURN ""
        ENDIF
    ENDFUNC


    FUNCTION SetStatus
        WAIT windows NOWAIT "������������� Status �����"
        SELECT lemmas
        SET ORDER TO weight 
        m.nStatus = 1000
        SCAN all
            m.nStatus = m.nStatus + 1
            replace lemmas.status WITH m.nStatus
        ENDscan
    ENDFUNC


    FUNCTION Export
        WAIT windows NOWAIT "��������� ������ lemmas"
        SELECT lemmas
        SET ORDER TO weight DESCENDING
        copy TO lemmas.txt DELIMITED WITH TAB FIELDS lemma, weight
    ENDFUNC

ENDDEFINE

******************************
*  ����� _pretext
******************************
DEFINE CLASS _pretext as Custom
    FUNCTION open
        CREATE TABLE pretext FREE  ;
               (pretext C(30))
        INDEX ON pretext TAG pretext
    ENDFUNC

    FUNCTION close
        IF USED('pretext')
            USE IN pretext
        endif

        IF FILE('pretext.dbf')
            ERASE pretext.dbf
            ERASE pretext.cdx
        endif
        
    ENDFUNC

    FUNCTION append_data
        IF FILE("pretext.txt")
            SELECT pretext
            ZAP
            WAIT windows NOWAIT "���������� ������ �� ����� pretext.txt"
            APPEND FROM pretext.txt DELIMITED WITH TAB
        endif
    ENDFUNC

    *************************************
    * ����� � ������ ���� Pretext
    *************************************
    FUNCTION seek_word(m.cPretext)
        IF EMPTY(m.cPretext)
            RETURN .f.
        ENDIF
        IF LEN(m.cPretext) < 29
            m.cPretext = m.cPretext + SPACE(30-LEN(m.cPretext))
        endif
        SELECT pretext
        IF SEEK(m.cPretext)
            RETURN .t.
        ELSE
            RETURN .f.
        ENDIF
    endfunc


ENDDEFINE

******************************
*  ����� _minus
******************************
DEFINE CLASS _minus as Custom
    FUNCTION open
        CREATE TABLE minus FREE  ;
               (minus C(30))
        INDEX ON minus TAG minus
    ENDFUNC
    
    FUNCTION close
        IF USED('minus')
            USE IN minus
        endif

        IF FILE('minus.dbf')
            ERASE minus.dbf
            ERASE minus.cdx
        endif
        
    ENDFUNC    

    FUNCTION append_data
        IF FILE("minus.txt")
            SELECT minus
            ZAP
            WAIT windows NOWAIT "���������� ������ �� ����� minus.txt"
            APPEND FROM minus.txt DELIMITED WITH TAB
        endif
    ENDFUNC

    *************************************
    * ����� � ������ ���� Minus
    *************************************
    FUNCTION seek_word(m.cMinus)
        IF EMPTY(m.cMinus)
            RETURN .f.
        ENDIF
        IF LEN(m.cMinus) < 29
            m.cMinus = m.cMinus + SPACE(30-LEN(m.cMinus))
        endif
        SELECT minus
        IF SEEK(m.cMinus)
            RETURN .t.
        ELSE
            RETURN .f.
        ENDIF
    endfunc


ENDDEFINE


