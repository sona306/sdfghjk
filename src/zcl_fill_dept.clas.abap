CLASS zcl_fill_dept DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FILL_DEPT IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.
    DATA lt_boolean TYPE STANDARD TABLE OF zdb_emp_dept.
    lt_boolean = VALUE #( ( type = 'SAP' value = 'SAP BTP' )
    ( type = 'IT' value = 'IT' )
    ( type = 'HR' value = 'HR' )
    ( type = 'FIN' value = 'FINANCE' )
     ).
    insert zdb_emp_dept from table @lt_boolean.
    if sy-subrc eq 0.
    commit work.
    out->write( 'Successfully updated' ).
    endif.
    ENDMETHOD.
ENDCLASS.
