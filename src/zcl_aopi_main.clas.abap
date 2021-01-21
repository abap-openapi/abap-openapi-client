CLASS zcl_aopi_main DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS operation_implementation
      IMPORTING is_operation TYPE zif_aopi_specification=>ty_operation
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS parameters_to_abap
      IMPORTING it_parameters TYPE zif_aopi_specification=>ty_parameters
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_class
      IMPORTING
      iv_interface_name TYPE string
      it_operations TYPE zif_aopi_specification=>ty_operations
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_interface
      IMPORTING
      iv_interface_name TYPE string
      it_operations TYPE zif_aopi_specification=>ty_operations
      RETURNING VALUE(rv_abap) TYPE string.

ENDCLASS.

CLASS zcl_aopi_main IMPLEMENTATION.

  METHOD run.
    DATA ls_specification TYPE zif_aopi_specification=>ty_specification.
    DATA lv_interface_name TYPE string.
    DATA lo_parser TYPE REF TO zcl_aopi_parser.

    CREATE OBJECT lo_parser.
    ls_specification = lo_parser->parse( iv_json ).
    lv_interface_name = 'zif_bar'.

    rs_result-clas = build_class(
      iv_interface_name = lv_interface_name
      it_operations = ls_specification-operations ).

    rs_result-intf = build_interface(
      iv_interface_name = lv_interface_name
      it_operations = ls_specification-operations ).

  ENDMETHOD.

  METHOD build_class.

    DATA ls_operation LIKE LINE OF it_operations.
    DATA ls_parameter TYPE zif_aopi_specification=>ty_parameter.

    rv_abap =
      |CLASS zcl_bar DEFINITION PUBLIC.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { iv_interface_name }.\n| &&
      |    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.\n| &&
      |  PRIVATE SECTION.\n| &&
      |    DATA mi_client TYPE REF TO if_http_client.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS zcl_bar IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |    mi_client = ii_client.\n| &&
      |  ENDMETHOD.\n\n|.

    LOOP AT it_operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { iv_interface_name }~{ ls_operation-abap_name }.\n| &&
        operation_implementation( ls_operation ) &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.

  ENDMETHOD.

  METHOD build_interface.

    DATA ls_operation LIKE LINE OF it_operations.
    DATA ls_parameter TYPE zif_aopi_specification=>ty_parameter.

    rv_abap = |INTERFACE { iv_interface_name }.\n| &&
      |* Generated by abap-openapi-client\n\n|.
    LOOP AT it_operations INTO ls_operation.
      rv_abap = rv_abap &&
        |* { to_upper( ls_operation-method ) } - "{ ls_operation-summary }"\n|.
      LOOP AT ls_operation-parameters INTO ls_parameter.
        rv_abap = rv_abap &&
          |* { ls_parameter-name }, { ls_parameter-required }, "{ ls_parameter-description }", { ls_parameter-in }\n|.
      ENDLOOP.
      rv_abap = rv_abap &&
        |  METHODS { ls_operation-abap_name }{ parameters_to_abap( ls_operation-parameters ) }.\n|.
    ENDLOOP.
    rv_abap = rv_abap && |ENDINTERFACE.|.

  ENDMETHOD.

  METHOD operation_implementation.

    DATA ls_parameter LIKE LINE OF is_operation-parameters.

    rv_abap =
      |    DATA lv_uri TYPE string VALUE '{ is_operation-path }'.\n|.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'path'.
      rv_abap = rv_abap &&
        |    REPLACE ALL OCCURRENCES OF '\{{ ls_parameter-name }\}' IN lv_uri WITH { ls_parameter-abap_name }.\n|.
    ENDLOOP.

    rv_abap = rv_abap &&
      |    mi_client->request->set_method( '{ to_upper( is_operation-method ) }' ).\n| &&
      |    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).\n| &&
      |    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).\n| &&
      |    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).\n|.
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