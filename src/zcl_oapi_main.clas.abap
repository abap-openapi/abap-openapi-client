CLASS zcl_oapi_main DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             class_name     TYPE c LENGTH 30,
             interface_name TYPE c LENGTH 30,
             json           TYPE string,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING is_input TYPE ty_input
      RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    DATA ms_specification TYPE zif_oapi_specification=>ty_specification.
    DATA ms_input TYPE ty_input.

    METHODS operation_implementation
      IMPORTING is_operation TYPE zif_oapi_specification=>ty_operation
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS parameters_to_abap
      IMPORTING it_parameters TYPE zif_oapi_specification=>ty_parameters
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_class
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_interface
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_uri_prefix
      IMPORTING is_servers LIKE ms_specification-servers
      RETURNING VALUE(rv_prefix) TYPE string.

ENDCLASS.

CLASS zcl_oapi_main IMPLEMENTATION.

  METHOD run.
    DATA lo_parser TYPE REF TO zcl_oapi_parser.

    ASSERT is_input-class_name IS NOT INITIAL.
    ASSERT is_input-interface_name IS NOT INITIAL.
    ASSERT is_input-json IS NOT INITIAL.
    ms_input = is_input.

    CREATE OBJECT lo_parser.
    ms_specification = lo_parser->parse( is_input-json ).

    rs_result-clas = build_class( ).

    rs_result-intf = build_interface( ).

  ENDMETHOD.

  METHOD build_class.

    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_parameter TYPE zif_oapi_specification=>ty_parameter.

    rv_abap =
      |CLASS { ms_input-class_name } DEFINITION PUBLIC.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |* { ms_specification-info-title }\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { ms_input-interface_name }.\n| &&
      |    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.\n| &&
      |  PRIVATE SECTION.\n| &&
      |    DATA mi_client TYPE REF TO if_http_client.\n| &&
      |    METHODS send_receive.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-class_name } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |    mi_client = ii_client.\n| &&
      |  ENDMETHOD.\n\n| &&
      |  METHOD send_receive.\n| &&
      |    DATA lv_code TYPE i.\n| &&
      |    DATA lv_cdata TYPE string.\n| &&
      |    mi_client->send( ).\n| &&
      |    mi_client->receive( ).\n| &&
      |    mi_client->response->get_status( IMPORTING code = lv_code ).\n| &&
      |  ENDMETHOD.\n\n|.

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { ms_input-interface_name }~{ ls_operation-abap_name }.\n| &&
        operation_implementation( ls_operation ) &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.

  ENDMETHOD.

  METHOD build_interface.

    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_parameter LIKE LINE OF ls_operation-parameters.
    DATA ls_response LIKE LINE OF ls_operation-responses.
    DATA ls_content LIKE LINE OF ls_response-content.

    rv_abap = |INTERFACE { ms_input-interface_name }.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |* { ms_specification-info-title }\n\n|.
    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |* { to_upper( ls_operation-method ) } - "{ ls_operation-summary }"\n|.
      LOOP AT ls_operation-parameters INTO ls_parameter.
        rv_abap = rv_abap &&
          |* Parameter: { ls_parameter-name }, { ls_parameter-required }, "{ ls_parameter-description }", { ls_parameter-in }\n|.
      ENDLOOP.
      LOOP AT ls_operation-responses INTO ls_response.
        rv_abap = rv_abap &&
          |* Response: { ls_response-code }, { ls_response-description }\n|.
        LOOP AT ls_response-content INTO ls_content.
          rv_abap = rv_abap &&
            |*     { ls_content-type }, { ls_content-schema_ref }\n|.
        ENDLOOP.
      ENDLOOP.
      rv_abap = rv_abap &&
        |  METHODS { ls_operation-abap_name }{ parameters_to_abap( ls_operation-parameters ) }.\n|.
    ENDLOOP.
    rv_abap = rv_abap && |ENDINTERFACE.|.

  ENDMETHOD.

  METHOD find_uri_prefix.
    DATA ls_server LIKE LINE OF ms_specification-servers.
    READ TABLE is_servers INDEX 1 INTO ls_server.
    IF sy-subrc = 0.
      rv_prefix = ls_server-url.
      IF rv_prefix CP 'http*'.
        FIND REGEX '\w(\/[\w\d\.\-\/]+)' IN ls_server-url SUBMATCHES rv_prefix.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD operation_implementation.

    DATA ls_parameter LIKE LINE OF is_operation-parameters.

    rv_abap =
      |    DATA lv_uri TYPE string VALUE '{ find_uri_prefix( ms_specification-servers ) }{ is_operation-path }'.\n|.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'path'.
      rv_abap = rv_abap &&
        |    REPLACE ALL OCCURRENCES OF '\{{ ls_parameter-name }\}' IN lv_uri WITH { ls_parameter-abap_name }.\n|.
    ENDLOOP.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'query'.
      rv_abap = rv_abap &&
        |    mi_client->request->set_form_field( name = '{ ls_parameter-name }' value = { ls_parameter-abap_name } ).\n|.
    ENDLOOP.

    rv_abap = rv_abap &&
      |    mi_client->request->set_method( '{ to_upper( is_operation-method ) }' ).\n| &&
      |    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).\n| &&
      |*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).\n| &&
      |*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).\n| &&
      |    send_receive( ).\n| &&
      |    WRITE / mi_client->response->get_cdata( ).\n|.
  ENDMETHOD.

  METHOD parameters_to_abap.

    DATA ls_parameter LIKE LINE OF it_parameters.
    DATA lt_tab TYPE string_table.
    DATA lv_text TYPE string.

    IF lines( it_parameters ) > 0.
      rv_abap = |\n    IMPORTING\n|.

      LOOP AT it_parameters INTO ls_parameter.
        lv_text = |      | && ls_parameter-abap_name && | TYPE string|.
        IF ls_parameter-required = abap_false.
          lv_text = lv_text && | OPTIONAL|.
        ENDIF.
        APPEND lv_text TO lt_tab.
      ENDLOOP.

      lv_text = concat_lines_of( table = lt_tab
                                 sep = |\n| ).
    ENDIF.

    rv_abap = rv_abap && lv_text && |\n    RAISING cx_static_check|.

  ENDMETHOD.

ENDCLASS.