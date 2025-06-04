SET EXCLUSIVE ON
SET RESOURCE TO
CLOSE ALL
SET SAFETY OFF
SET STATUS OFF

CLEAR
? "Шаг 1. Открываем таблицы." 
? TIME()

**** справочник лемм ***
oDiclemms = CREATEOBJECT("_diclemms")
oDiclemms.open()

*** используемые слова ***
oWords = CREATEOBJECT("_words")

*** лишние предлоги и цифры
oPretext = CREATEOBJECT("_pretext")
oPretext.open()

*** минус слова
oMinus = CREATEOBJECT("_minus")
oMinus.open()

**** кластеры ***
oClasters = CREATEOBJECT("_clasters")
oClasters.open()

? "Шаг 2. Добавляем данные из текстовых файлов"
? TIME()

oPretext.append_data()
oMinus.append_data()

IF oClasters.append_data()


    * собираем словарь слов
    ? "Шаг 4.Собираем словарь слов с 1) леммой 2) числом максимальной частотности"
    ? TIME()
    oWords.create()

    SELECT words
    SET ORDER TO words

    DECLARE aStatus [7]
    
    SELECT clasters
    SET ORDER TO
    
    m.nReccount = RECCOUNT()
    m.cWords = ""
    ? "Шаг 4. Собираем слова в кластеры. "
    ? TIME()
    SCAN all
        SCATTER NAME oClasters
        oClasters.wes = ""

        WAIT windows NOWAIT "% выполнения " + ALLTRIM(STR((RECNO()*100)/m.nReccount))
        * ищем для каждого слова частотность + само слово

        FOR countStatus = 1  TO 7
            DO CASE 
                CASE countStatus = 1 
                    cWords = oClasters.w1
                CASE countStatus = 2
                    cWords = oClasters.w2
                CASE countStatus = 3
                    cWords = oClasters.w3
                CASE countStatus = 4
                    cWords = oClasters.w4
                CASE countStatus = 5
                    cWords = oClasters.w5
                CASE countStatus = 6
                    cWords = oClasters.w6
                CASE countStatus = 7
                    cWords = oClasters.w7
                OTHERWISE 
                    cWords = ""
            ENDCASE 
            aStatus[countStatus] = ""
            IF EMPTY(cWords)
                LOOP
            ENDIF
            SELECT words
            IF SEEK(m.cWords)
                aStatus[countStatus] = STR(words.frequency) + words.lemma
            endif
        ENDFOR 
        ASORT(aStatus,1,ALEN(aStatus),1)
        * удаляю дубликаты слов в строке
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
                * возвращаем слово из массива
                m.cW   = ALLTRIM(SUBSTR(aStatus[m.nCount],11,40))+ " "
                * возвращаем частотность из массива
                m.cWes = VAL(SUBSTR(aStatus[m.nCount],1,10))
            ELSE
                m.cW   = ""
                m.cWes = 0
            ENDIF
            DO case
                CASE m.nCount =1
                    oClasters.w1     = m.cW
                    oClasters.l1_max = m.cWes
                CASE m.nCount =2
                    oClasters.w2 = m.cW
                    oClasters.l2_max = m.cWes
                CASE m.nCount = 3
                    oClasters.w3 = m.cW
                    oClasters.l3_max = m.cWes
                CASE m.nCount = 4
                    oClasters.w4 = m.cW
                    oClasters.l4_max = m.cWes
                CASE m.nCount = 5
                    oClasters.w5 = m.cW
                    oClasters.l5_max = m.cWes
                CASE m.nCount = 6
                    oClasters.w6 = m.cW
                    oClasters.l6_max = m.cWes
                CASE m.nCount = 7
                    oClasters.w7 = m.cW
                    oClasters.l7_max = m.cWes
            ENDCASE
            oClasters.wes = oClasters.wes+CHR(9)+m.cW +CHR(9)+IIF(m.cWes>0,ALLTRIM(STR(m.cWes)),"")
        ENDFOR
        SELECT clasters
        GATHER name oClasters
    ENDSCAN


    ? "Шаг 5 Выгружаем данные clasters в файл"
    ? TIME()
    
    IF FILE("clasters.txt-old")
        ERASE clasters.txt-old
    ENDIF
    RENAME clasters.txt TO clasters.txt-old
    SELECT clasters
    IF FILE('clasters-long.txt')  && Файл существует?
        IF FILE("clasters-long.txt")
            ERASE clasters-long.txt
        ENDIF
       m.nFile = FCREATE('clasters-long.txt')  && Если нет, создаем его
    ELSE
       m.nFile = FCREATE('clasters-long.txt')  && Если нет, создаем его
    ENDIF
    IF m.nFile < 0  && Проверка наличия ошибок открытия или создания файла
       WAIT 'Невозможно открыть или создать файл' WINDOW NOWAIT
    ELSE  && Если нет ошибки, запись в файл
        SELECT *;
            FROM clasters;
            ORDER BY l1_max desc,;
                     l2_max desc,;
                     l3_max desc,;
                     l4_max desc,;
                     l5_max desc,;
                     l6_max desc,;
                     l7_max desc;
            INTO CURSOR clasters_cur
            
            SELECT clasters_cur
            
        SCAN ALL FOR frequency > 9
            * запрос
            m.cWord = ALLTRIM(key) + CHR(9)
            * частотность
            m.cWord = m.cWord + ALLTRIM(str(frequency)) + CHR(9)
            * леммы
            m.cWord = m.cWord + ALLTRIM(w1)
            m.cWord = m.cWord + IIF(not EMPTY(w2)," " + ALLTRIM(w2),"")
            m.cWord = m.cWord + IIF(not EMPTY(w3)," " + ALLTRIM(w3),"")
            m.cWord = m.cWord + IIF(not EMPTY(w4)," " + ALLTRIM(w4),"")
            m.cWord = m.cWord + IIF(not EMPTY(w5)," " + ALLTRIM(w5),"")
            m.cWord = m.cWord + IIF(not EMPTY(w6)," " + ALLTRIM(w6),"")
            m.cWord = m.cWord + IIF(not EMPTY(w7)," " + ALLTRIM(w7),"")+ CHR(9)
            m.cWord = m.cWord + ALLTRIM(Wes)
            m.cWord = m.cWord + CHR(13)+ CHR(10)
           =FWRITE(m.nFile, m.cWord )
        ENDSCAN
    ENDIF
    =FCLOSE(m.nFile)  && Закрываем файл
    FFLUSH(m.nFile)

    IF USED("clasters_cur")
        USE IN clasters_cur
    ENDIF 
    
    ? "Шаг 6. Выгружаем данные words в файл"
    ? TIME()
    SELECT words
    SET ORDER TO frequency ASCENDING
    copy TO words.txt DELIMITED WITH TAB FIELDS words, frequency FOR NOT EMPTY(words)
    


ENDIF

? "Закрываем таблицы"
? TIME()

IF USED('clasters')
    USE IN clasters
endif
IF FILE('clasters.dbf')
    ERASE clasters.dbf
    ERASE clasters.cdx
ENDIF

IF USED('words')
    USE IN words
endif
IF FILE('words.dbf')
    ERASE words.dbf
    ERASE words.cdx
ENDIF

IF USED('pretext')
    USE IN pretext
endif
IF FILE('pretext.dbf')
    ERASE pretext.dbf
    ERASE pretext.cdx
endif

IF USED('minus')
    USE IN minus
endif
IF FILE('minus.dbf')
    ERASE minus.dbf
    ERASE minus.cdx
endif

IF USED("diclemms")
    USE IN diclemms
endif

? "Закончили"
? TIME()

******************************
*  класс _diclemms
* на каждое слово своя словоформа
* слов много словоформа - одна
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
            ? "Добавление данных из файла diclemms.txt"
            ? TIME()
            APPEND FROM diclemms.txt FIELDS word, lemma DELIMITED WITH TAB
            IF FILE("diclemms.txt-old")
                ERASE diclemms.txt-old
            ENDIF
            RENAME diclemms.txt TO diclemms.txt-old
        endif

    ENDFUNC

    FUNCTION SearchByWord(m.cWord)
        IF LEN(m.cWord) < 30
            m.cWord = m.cWord + SPACE(30-LEN(m.cWord))
        ENDIF
        
        SELECT diclemms
        SET ORDER TO word
        IF SEEK(m.cWord)
            RETURN IIF( EMPTY(diclemms.lemma), m.cWord, diclemms.lemma)
        ELSE
            INSERT INTO diclemms(word, lemma) VALUES (m.cWord, m.cWord)
            RETURN m.cWord
        ENDIF
    ENDFUNC




ENDDEFINE


******************************
*  класс _clasters
******************************
DEFINE CLASS _clasters as Custom
    key =""
    frequency = 0
    COUNT = 0
    w1 = ""
    l1 = ""
    l1_max = 0
    w2 = ""
    l2 = ""
    l2_max = 0
    w3 = ""
    l3 = ""
    l3_max = 0
    w4 = ""
    l4 = ""
    l4_max = 0
    w5 = ""
    l5 = ""
    l5_max = 0
    w6 = ""
    l6 = ""
    l6_max = 0
    w7 = ""
    l7 = ""
    l7_max = 0
    share = 0
    wes = ""
    color = .f.


    FUNCTION open
        CREATE TABLE clasters FREE  ;
           (key C(254) ,;
            frequency I,;
            count I,;
            w1 C(30),;
            l1 C(30),;
            l1_max N(10),;
            w2 C(30),;
            l2 C(30),;
            l2_max N(10),;
            w3 C(30),;
            l3 C(30),;
            l3_max N(10),;
            w4 C(30),;
            l4 C(30),;
            l4_max N(10),;
            w5 C(30),;
            l5 C(30),;
            l5_max N(10),;
            w6 C(30),;
            l6 C(30),;
            l6_max N(10),;
            w7 C(30),;
            l7 C(30),;
            l7_max N(10),;
            share F(15,5),;
            color L,;
            wes C(70) )
        INDEX ON alltrim(w1)+alltrim(w2)+alltrim(w3)+alltrim(w4)+alltrim(w5)+alltrim(w6)+alltrim(w7)+STR(999999-frequency) TAG group
        INDEX ON Wes TAG wes
        SET ORDER TO

    ENDFUNC


    ***** добавляем данные из файла
    FUNCTION append_data
        IF FILE("clasters.txt")
            SELECT clasters
            ZAP
            LOCAL nHandle, lcLine

            * Открываем файл на чтение
            nHandle = FOPEN("clasters.txt", 0)  && 0 = чтение
            IF nHandle < 0
                MESSAGEBOX("Не удалось открыть файл для чтения", 16, "Ошибка")
                RETURN
            ENDIF
            lnStroka = 0

            ? "Добавляем данные из файла clasters.txt"
            ? TIME()
            
            * Читаем до конца
            DO WHILE NOT FEOF(nHandle)
                lcLine = FGETS(nHandle)   && читает одну строку (включая символы конца строки)
                lnStroka = lnStroka +1
                WAIT windows NOWAIT  "Строка № " +STR( lnStroka )
                IF VARTYPE(lcLine) = "C"
                    lcLine = RTRIM(lcLine)  && убираем завершающие пробелы и символы конца строки
                    * — здесь можно обработать lcLine
                    * ? lcLine  && например, вывести в окно результатов
                    LOCAL laFields[2], nFields, i

                    * — допустим, у вас есть строка с табами
                    * lcLine = "Поле1" + CHR(9) + "Поле2" + CHR(9) + "Поле3"

                    * — разбиваем строку на массив laFields по табу
                    * нас интересует 1 и 2 поле
                    laFields[1] = GETWORDNUM(lcLine, 1, CHR(9))
                    laFields[2] = GETWORDNUM(lcLine, 2, CHR(9))
                    * — теперь в laFields[1]- запрос
                    * — теперь в laFields[2]- частота запроса за месяц

                    ***** разбиваем ключи на слова

                    * WAIT windows NOWAIT "Шаг 3. Разбивка ключа на слова. "
                    oClasters.key       = laFields[1]
                    oClasters.frequency = VAL(laFields[2])
                    oClasters.count = 0
                    oClasters.w1 = ""
                    oClasters.l1 = ""
                    oClasters.w2 = ""
                    oClasters.l2 = ""
                    oClasters.w3 = ""
                    oClasters.l3 = ""
                    oClasters.w4 = ""
                    oClasters.l4 = ""
                    oClasters.w5 = ""
                    oClasters.l5 = ""
                    oClasters.w6 = ""
                    oClasters.l6 = ""
                    oClasters.w7 = ""
                    oClasters.l7 = ""
                    m.lZapret    = .f.
                    m.nL = 0
                    * количество слов в запросе
                    oClasters.count = GETWORDCOUNT(oClasters.key,' ')

                    FOR m.nCount =1 TO oClasters.count
                        * получаем слово
                        m.cWord = GETWORDNUM(oClasters.key, m.nCount, ' ')
                        * если слово существуе
                        IF NOT EMPTY(m.cWord)
                            * ищем в таблице минус слов слово (точное совпаде
                            * если находим то выходим из цикла
                            IF oMinus.seek_word(m.cWord)
                                SELECT clasters
                                m.lZapret = .t.
                                exit
                            ENDIF

                            * ищем в таблице предлогов слово
                            * если находим то берем следующее слово
                            IF oPretext.seek_word(m.cWord)
                                SELECT clasters
                                LOOP
                            ENDIF

                            DO case
                                CASE m.nCount = 1
                                    oClasters.w1 = m.cWord
                                    oClasters.l1 = oDicLemms.SearchByWord(m.cWord)
                                CASE m.nCount = 2
                                    oClasters.w2 = m.cWord
                                    oClasters.l2 = oDicLemms.SearchByWord(m.cWord)
                                CASE m.nCount = 3
                                    oClasters.w3 = m.cWord
                                    oClasters.l3 = oDicLemms.SearchByWord(m.cWord)
                                CASE m.nCount = 4
                                    oClasters.w4 = m.cWord
                                    oClasters.l4 = oDicLemms.SearchByWord(m.cWord)
                                CASE m.nCount = 5
                                    oClasters.w5 = m.cWord
                                    oClasters.l5 = oDicLemms.SearchByWord(m.cWord)
                                CASE m.nCount = 6
                                    oClasters.w6 = m.cWord
                                    oClasters.l6 = oDicLemms.SearchByWord(m.cWord)
                                CASE m.nCount = 7
                                    oClasters.w7 = m.cWord
                                    oClasters.l7 = oDicLemms.SearchByWord(m.cWord)
                                OTHERWISE 
                                    ? "Вышли за 7 слов в ключе "
                            endcase
                        ENDIF
                    ENDFOR
                    IF NOT m.lZapret
                        * считаем доли частотности
                        IF oClasters.frequency > 0 and oClasters.count >0
                            oClasters.share = oClasters.frequency  / oClasters.count
                        ENDIF
                        INSERT INTO clasters FROM NAME oClasters
                    ENDIF
                ENDIF
            ENDDO

            * Закрываем файл
            =FCLOSE(nHandle)
            RETURN  .t.
        ELSE
            ? "файл clasters.txt отсуствует" 
            RETURN .f.
        endif
    ENDFUNC


ENDDEFINE


******************************
*  класс _words
******************************
DEFINE CLASS _words as Custom
    words      = ""
    frecuency  = 0
    COUNT      = 0
    lemma      = ""
    count_lemm = 0

    FUNCTION create
        ? "Собираем словарь слов из запросов"
        ? TIME()
        
        SELECT Clasters.w1 as words,;
               Clasters.l1 as l,;
              MAX(Clasters.frequency) AS frequency,;
              0 AS count,;
              0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w1);
         GROUP BY 1,2;
         union;
        SELECT Clasters.w2 as words,;
              Clasters.l2 as l,;
              MAX(Clasters.frequency) AS frequency,;
              0 AS count,;
              0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w2);
         GROUP BY 1,2;
         union;
        SELECT Clasters.w3 as words,;
              Clasters.l3 as l,;
              MAX(Clasters.frequency) AS frequency,;
              0 AS count,;
              0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w3);
         GROUP BY 1,2;
         union;
        SELECT Clasters.w4 as words,;
              Clasters.l4 as l,;
              MAX(Clasters.frequency) AS frequency,;
              0 AS count,;
              0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w4);
         GROUP BY 1,2;
         union;
        SELECT Clasters.w5 as words,;
              Clasters.l5 as l,;
              MAX(Clasters.frequency) AS frequency,;
              0 AS count,;
              0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w5);
         GROUP BY 1,2;
         union;
        SELECT Clasters.w6 as words,;
               Clasters.l6 as l,;
               MAX(Clasters.frequency) AS frequency,;
               0 AS count,;
               0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w6);
         GROUP BY 1,2;
         union;
        SELECT Clasters.w7 as words,;
              Clasters.l7 as l,;
              MAX(Clasters.frequency) AS frequency,;
              0 AS count,;
              0 as share;
         FROM clasters;
         WHERE NOT EMPTY(Clasters.w7);
         GROUP BY 1,2;
         INTO CURSOR temp1

        SELECT temp1.words           as words,;
               temp1.l               as lemma,;
               MAX(temp1.frequency)  as frequency;
         FROM temp1;
         GROUP BY 1,2;
         ORDER BY 2;
         INTO table words.dbf

         INDEX ON words TAG words
         INDEX ON frequency TAG frequency
         SET ORDER TO

         USE IN temp1

    ENDFUNC


ENDDEFINE


******************************
*  класс _pretext
******************************
DEFINE CLASS _pretext as Custom
    FUNCTION open
        CREATE TABLE pretext FREE  ;
               (pretext C(30))
        INDEX ON pretext TAG pretext
    ENDFUNC


    FUNCTION append_data
        IF FILE("pretext.txt")
            SELECT pretext
            ZAP
            ? "Добавление данных из файла pretext.txt"
            ? TIME()
            APPEND FROM pretext.txt DELIMITED WITH TAB
        endif
    ENDFUNC

    *************************************
    * поиск в списке слов Pretext
    *************************************
    FUNCTION seek_word(m.cPretext)
        IF EMPTY(m.cPretext)
            RETURN .f.
        ENDIF
        IF LEN(m.cPretext) < 30
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
*  класс _minus
******************************
DEFINE CLASS _minus as Custom
    FUNCTION open
        CREATE TABLE minus FREE  ;
               (minus C(30))
        INDEX ON minus TAG minus
    ENDFUNC



    FUNCTION append_data
        IF FILE("minus.txt")
            SELECT minus
            ZAP
            ? "Добавление данных из файла minus.txt"
            ? TIME()
            APPEND FROM minus.txt DELIMITED WITH TAB
        endif
    ENDFUNC

    *************************************
    * поиск в списке слов Minus
    *************************************
    FUNCTION seek_word(m.cMinus)
        IF EMPTY(m.cMinus)
            RETURN .f.
        ENDIF
        IF LEN(m.cMinus) < 30
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


