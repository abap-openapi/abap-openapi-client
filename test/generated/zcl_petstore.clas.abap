CLASS zcl_petstore DEFINITION PUBLIC.
* Generated by abap-openapi-client
* Swagger Petstore - OpenAPI 3.0
  PUBLIC SECTION.
    INTERFACES zif_petstore.
    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.
  PRIVATE SECTION.
    DATA mi_client TYPE REF TO if_http_client.
    METHODS send_receive.
ENDCLASS.

CLASS zcl_petstore IMPLEMENTATION.
  METHOD constructor.
    mi_client = ii_client.
  ENDMETHOD.

  METHOD send_receive.
    DATA lv_code TYPE i.
    DATA lv_cdata TYPE string.
    mi_client->send( ).
    mi_client->receive( ).
    mi_client->response->get_status( IMPORTING code = lv_code ).
  ENDMETHOD.

  METHOD zif_petstore~updatepet.
    DATA lv_uri TYPE string VALUE '/api/v3/pet'.
    mi_client->request->set_method( 'PUT' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~addpet.
    DATA lv_uri TYPE string VALUE '/api/v3/pet'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~findpetsbystatus.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/findByStatus'.
    mi_client->request->set_form_field( name = 'status' value = status ).
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~findpetsbytags.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/findByTags'.
    mi_client->request->set_form_field( name = 'tags' value = tags ).
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~getpetbyid.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}'.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH petid.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~updatepetwithform.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}'.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH petid.
    mi_client->request->set_form_field( name = 'name' value = name ).
    mi_client->request->set_form_field( name = 'status' value = status ).
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~deletepet.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}'.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH petid.
    mi_client->request->set_method( 'DELETE' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~uploadfile.
    DATA lv_uri TYPE string VALUE '/api/v3/pet/{petId}/uploadImage'.
    REPLACE ALL OCCURRENCES OF '{petId}' IN lv_uri WITH petid.
    mi_client->request->set_form_field( name = 'additionalMetadata' value = additionalmetadata ).
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~getinventory.
    DATA lv_uri TYPE string VALUE '/api/v3/store/inventory'.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~placeorder.
    DATA lv_uri TYPE string VALUE '/api/v3/store/order'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~getorderbyid.
    DATA lv_uri TYPE string VALUE '/api/v3/store/order/{orderId}'.
    REPLACE ALL OCCURRENCES OF '{orderId}' IN lv_uri WITH orderid.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~deleteorder.
    DATA lv_uri TYPE string VALUE '/api/v3/store/order/{orderId}'.
    REPLACE ALL OCCURRENCES OF '{orderId}' IN lv_uri WITH orderid.
    mi_client->request->set_method( 'DELETE' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~createuser.
    DATA lv_uri TYPE string VALUE '/api/v3/user'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~createuserswithlistinput.
    DATA lv_uri TYPE string VALUE '/api/v3/user/createWithList'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~loginuser.
    DATA lv_uri TYPE string VALUE '/api/v3/user/login'.
    mi_client->request->set_form_field( name = 'username' value = username ).
    mi_client->request->set_form_field( name = 'password' value = password ).
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~logoutuser.
    DATA lv_uri TYPE string VALUE '/api/v3/user/logout'.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~getuserbyname.
    DATA lv_uri TYPE string VALUE '/api/v3/user/{username}'.
    REPLACE ALL OCCURRENCES OF '{username}' IN lv_uri WITH username.
    mi_client->request->set_method( 'GET' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~updateuser.
    DATA lv_uri TYPE string VALUE '/api/v3/user/{username}'.
    REPLACE ALL OCCURRENCES OF '{username}' IN lv_uri WITH username.
    mi_client->request->set_method( 'PUT' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

  METHOD zif_petstore~deleteuser.
    DATA lv_uri TYPE string VALUE '/api/v3/user/{username}'.
    REPLACE ALL OCCURRENCES OF '{username}' IN lv_uri WITH username.
    mi_client->request->set_method( 'DELETE' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
*    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).
*    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).
    send_receive( ).
    WRITE / mi_client->response->get_cdata( ).
  ENDMETHOD.

ENDCLASS.