CLASS lcl_abap_name DEFINITION.
  PUBLIC SECTION.
    METHODS to_abap_name
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_name) TYPE string.
  PRIVATE SECTION.
    DATA mt_used TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    METHODS numbering IMPORTING iv_name TYPE string RETURNING VALUE(rv_name) TYPE string.
ENDCLASS.

CLASS lcl_abap_name IMPLEMENTATION.
  METHOD to_abap_name.
    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.
    rv_name = to_lower( iv_name ).
    REPLACE ALL OCCURRENCES OF '-' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN rv_name WITH '_'.
    IF strlen( rv_name ) > 30.
      rv_name = rv_name(30).
    ENDIF.
    READ TABLE mt_used WITH KEY table_line = rv_name TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      rv_name = numbering( rv_name ).
    ENDIF.
    APPEND rv_name TO mt_used.
  ENDMETHOD.

  METHOD numbering.
    DATA lv_number TYPE n LENGTH 2.
    DATA lv_offset TYPE i.
    lv_offset = strlen( iv_name ).
    IF lv_offset > 28.
      lv_offset = 28.
    ENDIF.
    DO 99 TIMES.
      lv_number = sy-index.
      rv_name = iv_name.
      rv_name+lv_offset = lv_number.
      WRITE / rv_name.
      READ TABLE mt_used WITH KEY table_line = rv_name TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDDO.
    ASSERT 0 = 1.
  ENDMETHOD.
ENDCLASS.