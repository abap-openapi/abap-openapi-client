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
    DATA ms_specification TYPE zif_oapi_specification_v3=>ty_specification.
    DATA ms_input TYPE ty_input.

    METHODS operation_implementation
      IMPORTING is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_return
      IMPORTING is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rs_type) TYPE zif_oapi_specification_v3=>ty_component_schema.

    METHODS parameters_to_abap
      IMPORTING it_parameters TYPE zif_oapi_specification_v3=>ty_parameters
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_class
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_interface
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS dump_types
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS dump_parser_methods
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_uri_prefix
      IMPORTING is_servers LIKE ms_specification-servers
      RETURNING VALUE(rv_prefix) TYPE string.

ENDCLASS.

CLASS zcl_oapi_main IMPLEMENTATION.

  METHOD run.
    DATA lo_parser TYPE REF TO zcl_oapi_parser.
    DATA lo_references TYPE REF TO zcl_oapi_references.

    ASSERT is_input-class_name IS NOT INITIAL.
    ASSERT is_input-interface_name IS NOT INITIAL.
    ASSERT is_input-json IS NOT INITIAL.
    ms_input = is_input.

    CREATE OBJECT lo_parser.
    ms_specification = lo_parser->parse( is_input-json ).

    CREATE OBJECT lo_references.
    ms_specification = lo_references->fix( ms_specification ).

    rs_result-clas = build_class( ).
    rs_result-intf = build_interface( ).

  ENDMETHOD.

  METHOD build_class.

    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_parameter TYPE zif_oapi_specification_v3=>ty_parameter.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.

    rv_abap =
      |CLASS { ms_input-class_name } DEFINITION PUBLIC.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |* { ms_specification-info-title }\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { ms_input-interface_name }.\n| &&
      |    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.\n| &&
      |  PROTECTED SECTION.\n| &&
      |    DATA mi_client TYPE REF TO if_http_client.\n| &&
      |    DATA mo_json TYPE REF TO zcl_oapi_json.\n| &&
      |    METHODS send_receive RETURNING VALUE(rv_code) TYPE i.\n|.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      rv_abap = rv_abap &&
        |    METHODS { ls_schema-abap_parser_method }\n| &&
        |      IMPORTING iv_prefix TYPE string\n| &&
        |      RETURNING VALUE({ ls_schema-abap_name }) TYPE { ms_input-interface_name }=>{ ls_schema-abap_name }\n| &&
        |      RAISING cx_static_check.\n|.
    ENDLOOP.

    rv_abap = rv_abap &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-class_name } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |    mi_client = ii_client.\n| &&
      |  ENDMETHOD.\n\n| &&
      |  METHOD send_receive.\n| &&
      |    mi_client->send( ).\n| &&
      |    mi_client->receive( ).\n| &&
      |    mi_client->response->get_status( IMPORTING code = rv_code ).\n| &&
      |  ENDMETHOD.\n\n|.

    rv_abap = rv_abap && dump_parser_methods( ).

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { ms_input-interface_name }~{ ls_operation-abap_name }.\n| &&
        operation_implementation( ls_operation ) &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.

  ENDMETHOD.

  METHOD dump_parser_methods.
* note: the parser methods might be called recursively, as the structures can be nested

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA ls_property TYPE zif_oapi_schema=>ty_property.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      rv_abap = rv_abap &&
        |  METHOD { ls_schema-abap_parser_method }.\n|.
      CASE ls_schema-schema->type.
        WHEN 'object'.
          LOOP AT ls_schema-schema->properties INTO ls_property.
            IF ls_property-schema->type = 'string'
                OR ls_property-schema->type = 'integer'.
              rv_abap = rv_abap && |    { ls_schema-abap_name }-{ ls_property-abap_name } = mo_json->value_string( iv_prefix && '/{ ls_property-name }' ).\n|.
            ELSEIF ls_property-schema->type = 'boolean'.
              rv_abap = rv_abap && |    { ls_schema-abap_name }-{ ls_property-abap_name } = mo_json->value_boolean( iv_prefix && '/{ ls_property-name }' ).\n|.
            ELSE.
              rv_abap = rv_abap && |* todo, object, { ls_property-schema->type }, { ls_property-abap_name }\n|.
            ENDIF.
          ENDLOOP.
        WHEN OTHERS.
          rv_abap = rv_abap && |* todo, handle type { ls_schema-schema->type }\n|.
      ENDCASE.
      rv_abap = rv_abap && |  ENDMETHOD.\n\n|.
    ENDLOOP.

  ENDMETHOD.

  METHOD dump_types.

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA ls_property TYPE zif_oapi_schema=>ty_property.
    DATA lv_count TYPE i.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      rv_abap = rv_abap && |* Component schema: { ls_schema-name }, { ls_schema-schema->type }\n|.
      IF ls_schema-schema->type = 'object'.
        rv_abap = rv_abap && |  TYPES: BEGIN OF { ls_schema-abap_name },\n|.
        lv_count = 0.
        LOOP AT ls_schema-schema->properties INTO ls_property.
          IF ls_property-schema->is_simple_type( ) = abap_true.
            rv_abap = rv_abap && |           | && ls_property-abap_name && | TYPE | && ls_property-schema->get_simple_type( ) && |,\n|.
          ELSE.
            rv_abap = rv_abap && |           | && ls_property-abap_name && | TYPE string, " not simple, todo\n|.
          ENDIF.
          lv_count = lv_count + 1.
        ENDLOOP.
        IF lv_count = 0. " temporary workaround
          rv_abap = rv_abap && |           dummy TYPE i,\n|.
        ENDIF.
        rv_abap = rv_abap && |         END OF { ls_schema-abap_name }.\n|.
      ELSE.
        rv_abap = rv_abap && |  TYPES { ls_schema-abap_name } TYPE string.\n|.
      ENDIF.
      rv_abap = rv_abap && |\n|.
    ENDLOOP.

  ENDMETHOD.

  METHOD build_interface.

    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_parameter LIKE LINE OF ls_operation-parameters.
    DATA ls_response LIKE LINE OF ls_operation-responses.
    DATA ls_content LIKE LINE OF ls_response-content.
    DATA ls_return TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_required TYPE string.
    DATA lv_extra TYPE string.
    DATA lv_ref TYPE string.

    rv_abap = |INTERFACE { ms_input-interface_name }.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |* { ms_specification-info-title }\n\n|.

    rv_abap = rv_abap && dump_types( ).

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |* { to_upper( ls_operation-method ) } - "{ ls_operation-summary }"\n|.
      IF ls_operation-operation_id IS NOT INITIAL.
        rv_abap = rv_abap && |* Operation id: { ls_operation-operation_id }\n|.
      ENDIF.
      LOOP AT ls_operation-parameters INTO ls_parameter.
        IF ls_parameter-required = abap_true.
          lv_required = 'required'.
        ELSE.
          lv_required = 'optional'.
        ENDIF.
        rv_abap = rv_abap &&
          |* Parameter: { ls_parameter-name }, { lv_required }, { ls_parameter-in }\n|.
      ENDLOOP.
      LOOP AT ls_operation-responses INTO ls_response.
        rv_abap = rv_abap &&
          |* Response: { ls_response-code }\n|.
        LOOP AT ls_response-content INTO ls_content.
          IF ls_content-schema_ref IS NOT INITIAL.
            lv_extra = |, { ls_content-schema_ref }|.
          ELSE.
            lv_extra = |, { ls_content-schema->type }|.
          ENDIF.
          rv_abap = rv_abap &&
            |*     { ls_content-type }{ lv_extra }\n|.
        ENDLOOP.
      ENDLOOP.
      IF ls_operation-body_schema_ref IS NOT INITIAL.
        rv_abap = rv_abap &&
          |* Body ref: { ls_operation-body_schema_ref }\n|.
      ENDIF.
      IF ls_operation-body_schema IS NOT INITIAL.
        rv_abap = rv_abap &&
          |* Body schema: { ls_operation-body_schema->type }\n|.
      ENDIF.
      rv_abap = rv_abap &&
        |  METHODS { ls_operation-abap_name }{ parameters_to_abap( ls_operation-parameters ) }|.
      ls_return = find_return( ls_operation ).
      IF ls_return IS NOT INITIAL.
        rv_abap = rv_abap && |    RETURNING VALUE(return_data) TYPE { ls_return-abap_name }\n|.
      ENDIF.
      rv_abap = rv_abap && |    RAISING cx_static_check.\n\n|.
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
    DATA ls_return TYPE zif_oapi_specification_v3=>ty_component_schema.

    rv_abap =
      |    DATA lv_code TYPE i.\n| &&
      |    DATA lv_temp TYPE string.\n| &&
      |    DATA lv_uri TYPE string VALUE '{ find_uri_prefix( ms_specification-servers ) }{ is_operation-path }'.\n|.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'path'.
      IF ls_parameter-schema->type = 'string'.
        rv_abap = rv_abap &&
          |    REPLACE ALL OCCURRENCES OF '\{{ ls_parameter-name }\}' IN lv_uri WITH { ls_parameter-abap_name }.\n|.
      ELSE.
        rv_abap = rv_abap &&
          |    lv_temp = { ls_parameter-abap_name }.\n| &&
          |    CONDENSE lv_temp.\n| &&
          |    REPLACE ALL OCCURRENCES OF '\{{ ls_parameter-name }\}' IN lv_uri WITH lv_temp.\n|.
      ENDIF.
    ENDLOOP.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'query'.
      IF ls_parameter-required = abap_false.
        rv_abap = rv_abap &&
          |    IF { ls_parameter-abap_name } IS SUPPLIED.\n| &&
          |      mi_client->request->set_form_field( name = '{ ls_parameter-name }' value = { ls_parameter-abap_name } ).\n| &&
          |    ENDIF.\n|.
      ELSE.
        rv_abap = rv_abap &&
          |    mi_client->request->set_form_field( name = '{ ls_parameter-name }' value = { ls_parameter-abap_name } ).\n|.
      ENDIF.
    ENDLOOP.

    rv_abap = rv_abap &&
      |    mi_client->request->set_method( '{ to_upper( is_operation-method ) }' ).\n| &&
      |    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).\n| &&
*      |    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).\n| &&
*      |    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).\n| &&
      |    lv_code = send_receive( ).\n| &&
      |    WRITE / lv_code.\n|.
* todo, accept and check content types

    ls_return = find_return( is_operation ).
    IF ls_return IS NOT INITIAL.
      rv_abap = rv_abap &&
        |    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).\n| &&
        |    return_data = { ls_return-abap_parser_method }( '' ).\n|.
    ELSE.
      rv_abap = rv_abap &&
        |    WRITE / mi_client->response->get_cdata( ).\n| &&
        |* todo, handle more responses\n|.
    ENDIF.

  ENDMETHOD.

  METHOD find_return.

    DATA ls_response LIKE LINE OF is_operation-responses.
    DATA ls_content LIKE LINE OF ls_response-content.

    LOOP AT is_operation-responses INTO ls_response.
      IF ls_response-code = '200'.
        READ TABLE ls_response-content INTO ls_content WITH KEY type = 'application/json'.
        IF sy-subrc = 0 AND ls_content-schema_ref IS NOT INITIAL.
          REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN ls_content-schema_ref WITH ''.
          READ TABLE ms_specification-components-schemas INTO rs_type WITH KEY name = ls_content-schema_ref.
          IF sy-subrc = 0.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD parameters_to_abap.

    DATA ls_parameter LIKE LINE OF it_parameters.
    DATA lt_tab TYPE string_table.
    DATA lv_type TYPE string.
    DATA lv_text TYPE string.
    DATA lv_default TYPE string.

    IF lines( it_parameters ) > 0.
      rv_abap = |\n    IMPORTING\n|.

      LOOP AT it_parameters INTO ls_parameter.

        lv_type = ls_parameter-schema->get_simple_type( ).
        IF lv_type IS INITIAL.
          lv_type = 'string'. " todo, at this point there should only be simple or referenced types?
        ENDIF.

        CLEAR lv_default.
        IF ls_parameter-schema IS NOT INITIAL AND ls_parameter-schema->default IS NOT INITIAL.
          IF ls_parameter-schema->default CO '0123456789'.
            lv_default = | DEFAULT { ls_parameter-schema->default }|.
          ELSE.
            lv_default = | DEFAULT '{ ls_parameter-schema->default }'|.
          ENDIF.
        ENDIF.

        lv_text = |      | && ls_parameter-abap_name && | TYPE | && lv_type && lv_default.
        IF ls_parameter-required = abap_false.
          lv_text = lv_text && | OPTIONAL|.
        ENDIF.
        APPEND lv_text TO lt_tab.
      ENDLOOP.

      lv_text = concat_lines_of( table = lt_tab
                                 sep = |\n| ).
    ENDIF.

    rv_abap = rv_abap && lv_text && |\n|.

  ENDMETHOD.

ENDCLASS.