CLASS lhc_zr_leaves DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateDu FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_leaves~calculateDu.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_leaves RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_leaves RESULT result.

    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION zr_leaves~Approve RESULT result.
    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION zr_leaves~Reject RESULT result.
    METHODS validate_start_end FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_leaves~validate_start_end.
    METHODS defaultstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_leaves~defaultstatus.
ENDCLASS.

CLASS lhc_zr_leaves IMPLEMENTATION.

  METHOD calculateDu.
    READ ENTITIES OF zr_employee_details IN LOCAL MODE
    ENTITY zr_leaves
      FIELDS ( StartDate EndDate Duration )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leaves).

    "2. Loop through the records and calculate duration
    LOOP AT lt_leaves ASSIGNING FIELD-SYMBOL(<ls_leave>).

      IF <ls_leave>-StartDate IS NOT INITIAL
         AND <ls_leave>-EndDate   IS NOT INITIAL
         AND <ls_leave>-EndDate   >= <ls_leave>-StartDate.

        " Calculate number of days (EndDate - StartDate + 1)
        DATA(lv_days) = <ls_leave>-EndDate - <ls_leave>-StartDate + 1.

        "3. Update entity with calculated days
        MODIFY ENTITIES OF zr_employee_details IN LOCAL MODE
          ENTITY zr_leaves
          UPDATE FIELDS ( Duration )
          WITH VALUE #(
            ( %tky          = <ls_leave>-%tky
              Duration  = lv_days
              %control-Duration = if_abap_behv=>mk-on )
          ).

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD Approve.
    MODIFY ENTITIES OF zr_employee_details IN LOCAL MODE
      ENTITY zr_leaves
      UPDATE FROM VALUE #(  FOR key IN keys (
*      BookUuid = key-BookUuid
      EmpId = key-EmpId
      LeaveId = key-LeaveId
      Approve = 'Approved'
      %control-Approve = if_abap_behv=>mk-on
      ) )
      FAILED failed
      REPORTED reported.
    READ ENTITIES OF zr_employee_details IN LOCAL MODE
    ENTITY zr_leaves
    FROM VALUE #(  FOR key IN keys (  EmpId = key-EmpId LeaveId = key-LeaveId ) ) RESULT DATA(lt_project).
    result = VALUE #( FOR lw_project IN lt_project ( EmpId = lw_project-EmpId LeaveId = lw_project-LeaveId %param = lw_project  ) ).
  ENDMETHOD.

  METHOD Reject.
    MODIFY ENTITIES OF zr_employee_details IN LOCAL MODE
        ENTITY zr_leaves
        UPDATE FROM VALUE #(  FOR key IN keys (
        EmpId = key-EmpId
        LeaveId = key-LeaveId
        Approve = 'Rejected'
        %control-Approve = if_abap_behv=>mk-on
        ) )
        FAILED failed
        REPORTED reported.
    READ ENTITIES OF zr_employee_details IN LOCAL MODE
    ENTITY zr_leaves
    FROM VALUE #(  FOR key IN keys (  EmpId = key-EmpId LeaveId = key-LeaveId ) ) RESULT DATA(lt_project).
    result = VALUE #( FOR lw_project IN lt_project ( EmpId = lw_project-EmpId LeaveId = lw_project-LeaveId %param = lw_project  ) ).
  ENDMETHOD.

  METHOD validate_start_end.
    " Read StartDate & EndDate for the entities being saved
    READ ENTITIES OF zr_employee_details IN LOCAL MODE
      ENTITY zr_leaves
        FIELDS ( StartDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_leaves).

    LOOP AT lt_leaves ASSIGNING FIELD-SYMBOL(<fs_leave>).

      " Only validate if both dates are provided
      IF <fs_leave>-StartDate IS NOT INITIAL
         AND <fs_leave>-EndDate   IS NOT INITIAL
         AND <fs_leave>-StartDate > <fs_leave>-EndDate.

        " Raise error message
        APPEND VALUE #(
          %tky = <fs_leave>-%tky
          %msg = new_message(
                   id       = 'ZMSG_LEAVE'
                   number   = '003'   " <-- create this message in SE91
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-zr_leaves.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD defaultStatus.
  " reading the object being created
  READ ENTITIES OF zr_employee_details in local mode
  ENTITY zr_leaves
  FIELDS ( Approve )
  with CORRESPONDING #( keys )
  result data(lt_leave).

  " loop the internal table and check the status value is null
  loop at lt_leave ASSIGNING FIELD-SYMBOL(<ls_leave>).
    if <ls_leave>-Approve is INITIAL.
    modify ENTITIES OF zr_employee_details in local mode
  ENTITY zr_leaves

  update from value #(
  ( %tky = <ls_leave>-%tky
  Approve = 'Pending'
  %control-Approve = if_abap_behv=>mk-on )

  ).
  ENDIF.
  ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_employee_details DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zr_employee_details IMPLEMENTATION.

  METHOD adjust_numbers.
    IF mapped-zr_employee_details IS NOT INITIAL.
      LOOP AT mapped-zr_employee_details ASSIGNING FIELD-SYMBOL(<fs_emp>).
        TRY.
            CALL METHOD cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr       = '01'
                object            = '/DMO/TRV_M'
*               quantity          = CONV #( lines( mapped-jounryheader ) )
              IMPORTING
                number            = DATA(number_range_key)
                returncode        = DATA(number_range_return_code)
                returned_quantity = DATA(number_range_returned_quantity) ).
          CATCH cx_nr_object_not_found INTO DATA(lo_uuid_error).
            lo_uuid_error->get_text(  RECEIVING  result = DATA(lv_errortext) ).
          CATCH cx_number_ranges INTO DATA(lx_number_ranges).
            lx_number_ranges->get_text(  RECEIVING  result = lv_errortext ).
        ENDTRY.
      ENDLOOP.
      <fs_emp>-EmpId = number_range_key.

    ELSEIF mapped-zr_leaves IS NOT INITIAL.
      LOOP AT mapped-zr_leaves ASSIGNING FIELD-SYMBOL(<fs_temp>).
        TRY.
            CALL METHOD cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr       = '01'
                object            = '/DMO/TRV_M'
*               quantity          = CONV #( lines( mapped-jounryheader ) )
              IMPORTING
                number            = DATA(number_range_key2)
                returncode        = DATA(number_range_return_code1)
                returned_quantity = DATA(number_range_returned_quantit) ).
          CATCH cx_nr_object_not_found INTO DATA(lo_uuid_error1).
            lo_uuid_error->get_text(  RECEIVING  result = DATA(lv_errortext1) ).
          CATCH cx_number_ranges INTO DATA(lx_number_ranges1).
            lx_number_ranges->get_text(  RECEIVING  result = lv_errortext1 ).
        ENDTRY.
      ENDLOOP.
      <fs_temp>-LeaveId = number_range_key2.
      <fs_temp>-EmpId = <fs_temp>-%tmp-EmpId.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZR_EMPLOYEE_DETAILS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_employee_details RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_employee_details RESULT result.
    METHODS validate_basic_dob FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_employee_details~validate_basic_dob.
    METHODS calculateage FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_employee_details~calculateage.
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR zr_employee_details RESULT result.


ENDCLASS.

CLASS lhc_ZR_EMPLOYEE_DETAILS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validate_basic_dob.
    READ ENTITIES OF zr_employee_details IN LOCAL MODE
      ENTITY zr_employee_details
        FIELDS ( EmpDob )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_entities).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      " Validate Basic Salary > 0
      IF <fs_entity>-EmpBasic <= 0.
        APPEND VALUE #(
          %tky   = <fs_entity>-%tky
          %msg   = new_message(
                     id       = 'ZMSG_LEAVE'
                     number   = '001'
                     severity = if_abap_behv_message=>severity-error )
        ) TO reported-zr_employee_details.
      ENDIF.

      " Validate DOB < Today
      IF <fs_entity>-EmpDob >= cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #(
          %tky   = <fs_entity>-%tky
          %msg   = new_message(
                     id       = 'ZMSG_LEAVE'
                     number   = '002'
                     severity = if_abap_behv_message=>severity-error )
        ) TO reported-zr_employee_details.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


*  METHOD get_instance_features.
*  ENDMETHOD.

  METHOD calculateAge.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    "Read the data to be modified
    READ ENTITIES OF zr_employee_details  IN LOCAL MODE
      ENTITY zr_employee_details  FIELDS ( EmpDob )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_dob).

    LOOP AT lt_dob INTO DATA(is_dob).
      DATA(lv_age) = COND #(
        WHEN is_dob-EmpDob IS INITIAL THEN 0
        ELSE lv_today(4) - is_dob-EmpDob(4)
      ).
      IF lv_today+4(4) < is_dob-EmpDob+4(4).
        lv_age =  lv_age - 1.
      ENDIF.



      "Update the Front End
      MODIFY ENTITIES OF zr_employee_details IN LOCAL MODE
        ENTITY zr_employee_details
        UPDATE FIELDS ( EmpAge )
        WITH VALUE #(
          ( %tky       = is_dob-%tky
            %data-EmpAge  = lv_age
            %control-EmpAge = if_abap_behv=>mk-on ) ).

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
