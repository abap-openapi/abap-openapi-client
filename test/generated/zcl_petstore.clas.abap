CLASS zcl_petstore DEFINITION PUBLIC.
* Generated by abap-openapi-client
* Swagger Petstore - OpenAPI 3.0
  PUBLIC SECTION.
    INTERFACES zif_petstore.
    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.
  PROTECTED SECTION.
    DATA mi_client TYPE REF TO if_http_client.
    DATA mo_json TYPE REF TO zcl_oapi_json.
    METHODS send_receive RETURNING VALUE(rv_code) TYPE i.
    METHODS parse_order
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(order) TYPE zif_petstore=>order
      RAISING cx_static_check.
    METHODS parse_customer
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(customer) TYPE zif_petstore=>customer
      RAISING cx_static_check.
    METHODS parse_address
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(address) TYPE zif_petstore=>address
      RAISING cx_static_check.
    METHODS parse_category
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(category) TYPE zif_petstore=>category
      RAISING cx_static_check.
    METHODS parse_user
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(user) TYPE zif_petstore=>user
      RAISING cx_static_check.
    METHODS parse_tag
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(tag) TYPE zif_petstore=>tag
      RAISING cx_static_check.
    METHODS parse_pet
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(pet) TYPE zif_petstore=>pet
      RAISING cx_static_check.
    METHODS parse_apiresponse
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(apiresponse) TYPE zif_petstore=>apiresponse
      RAISING cx_static_check.
ENDCLASS.

CLASS zcl_petstore IMPLEMENTATION.
  METHOD constructor.
    mi_client = ii_client.
  ENDMETHOD.

  METHOD send_receive.
    mi_client->send( ).
    mi_client->receive( ).
    mi_client->response->get_status( IMPORTING code = rv_code ).
  ENDMETHOD.

  METHOD parse_order.
    order-id = mo_json->value_string( iv_prefix && '/id' ).
    order-petid = mo_json->value_string( iv_prefix && '/petId' ).
    order-quantity = mo_json->value_string( iv_prefix && '/quantity' ).
    order-shipdate = mo_json->value_string( iv_prefix && '/shipDate' ).
    order-status = mo_json->value_string( iv_prefix && '/status' ).
    order-complete = mo_json->value_boolean( iv_prefix && '/complete' ).
  ENDMETHOD.

  METHOD parse_customer.
    customer-id = mo_json->value_string( iv_prefix && '/id' ).
    customer-username = mo_json->value_string( iv_prefix && '/username' ).
* todo, object, array, address
  ENDMETHOD.

  METHOD parse_address.
    address-street = mo_json->value_string( iv_prefix && '/street' ).
    address-city = mo_json->value_string( iv_prefix && '/city' ).
    address-state = mo_json->value_string( iv_prefix && '/state' ).
    address-zip = mo_json->value_string( iv_prefix && '/zip' ).
  ENDMETHOD.

  METHOD parse_category.
    category-id = mo_json->value_string( iv_prefix && '/id' ).
    category-name = mo_json->value_string( iv_prefix && '/name' ).
  ENDMETHOD.

  METHOD parse_user.
    user-id = mo_json->value_string( iv_prefix && '/id' ).
    user-username = mo_json->value_string( iv_prefix && '/username' ).
    user-firstname = mo_json->value_string( iv_prefix && '/firstName' ).
    user-lastname = mo_json->value_string( iv_prefix && '/lastName' ).
    user-email = mo_json->value_string( iv_prefix && '/email' ).
    user-password = mo_json->value_string( iv_prefix && '/password' ).
    user-phone = mo_json->value_string( iv_prefix && '/phone' ).
    user-userstatus = mo_json->value_string( iv_prefix && '/userStatus' ).
  ENDMETHOD.

  METHOD parse_tag.
    tag-id = mo_json->value_string( iv_prefix && '/id' ).
    tag-name = mo_json->value_string( iv_prefix && '/name' ).
  ENDMETHOD.

  METHOD parse_pet.
    pet-id = mo_json->value_string( iv_prefix && '/id' ).
    pet-name = mo_json->value_string( iv_prefix && '/name' ).
* todo, ref?
* todo, object, array, photourls
* todo, object, array, tags
    pet-status = mo_json->value_string( iv_prefix && '/status' ).
  ENDMETHOD.

  METHOD parse_apiresponse.
    apiresponse-code = mo_json->value_string( iv_prefix && '/code' ).
    apiresponse-type = mo_json->value_string( iv_prefix && '/type' ).
    apiresponse-message = mo_json->value_string( iv_prefix && '/message' ).
  ENDMETHOD.

  METHOD zif_petstore~updatepet.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet'.
    mi_client->request->set_method( 'PUT' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_pet( '' ).
  ENDMETHOD.

  METHOD zif_petstore~addpet.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_pet( '' ).
  ENDMETHOD.

  METHOD zif_petstore~findpetsbystatus.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/findByStatus'.
    IF status IS SUPPLIED.
      mi_client->request->set_form_field( name = 'status' value = status ).
    ENDIF.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~findpetsbytags.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/findByTags'.
    lv_temp = tags.
    CONDENSE lv_temp.
    IF tags IS SUPPLIED.
      mi_client->request->set_form_field( name = 'tags' value = lv_temp ).
    ENDIF.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~getpetbyid.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}'.
    lv_temp = petid.
    CONDENSE lv_temp.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH lv_temp.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_pet( '' ).
  ENDMETHOD.

  METHOD zif_petstore~updatepetwithform.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}'.
    lv_temp = petid.
    CONDENSE lv_temp.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH lv_temp.
    IF name IS SUPPLIED.
      mi_client->request->set_form_field( name = 'name' value = name ).
    ENDIF.
    IF status IS SUPPLIED.
      mi_client->request->set_form_field( name = 'status' value = status ).
    ENDIF.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~deletepet.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}'.
    lv_temp = petid.
    CONDENSE lv_temp.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH lv_temp.
    mi_client->request->set_method( 'DELETE' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~uploadfile.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}/uploadImage'.
    lv_temp = petid.
    CONDENSE lv_temp.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH lv_temp.
    IF additionalmetadata IS SUPPLIED.
      mi_client->request->set_form_field( name = 'additionalMetadata' value = additionalmetadata ).
    ENDIF.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_apiresponse( '' ).
  ENDMETHOD.

  METHOD zif_petstore~getinventory.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/store/inventory'.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~placeorder.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/store/order'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_order( '' ).
  ENDMETHOD.

  METHOD zif_petstore~getorderbyid.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/store/order/{orderId}'.
    lv_temp = orderid.
    CONDENSE lv_temp.
    REPLACE ALL OCCURRENCES OF '{orderId}' IN lv_uri WITH lv_temp.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_order( '' ).
  ENDMETHOD.

  METHOD zif_petstore~deleteorder.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/store/order/{orderId}'.
    lv_temp = orderid.
    CONDENSE lv_temp.
    REPLACE ALL OCCURRENCES OF '{orderId}' IN lv_uri WITH lv_temp.
    mi_client->request->set_method( 'DELETE' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~createuser.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~createuserswithlistinput.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user/createWithList'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_user( '' ).
  ENDMETHOD.

  METHOD zif_petstore~loginuser.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user/login'.
    IF username IS SUPPLIED.
      mi_client->request->set_form_field( name = 'username' value = username ).
    ENDIF.
    IF password IS SUPPLIED.
      mi_client->request->set_form_field( name = 'password' value = password ).
    ENDIF.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~logoutuser.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user/logout'.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~getuserbyname.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user/{username}'.
    REPLACE ALL OCCURRENCES OF '{username}' IN lv_uri WITH username.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).
    return_data = parse_user( '' ).
  ENDMETHOD.

  METHOD zif_petstore~updateuser.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user/{username}'.
    REPLACE ALL OCCURRENCES OF '{username}' IN lv_uri WITH username.
    mi_client->request->set_method( 'PUT' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

  METHOD zif_petstore~deleteuser.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/api/v3/user/{username}'.
    REPLACE ALL OCCURRENCES OF '{username}' IN lv_uri WITH username.
    mi_client->request->set_method( 'DELETE' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    WRITE / mi_client->response->get_cdata( ).
* todo, handle more responses
  ENDMETHOD.

ENDCLASS.