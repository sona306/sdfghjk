@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for employees'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_EMPLOYEE_DETAILS
as select from zdb_employee
{
    key emp_id as EmpId,
    emp_name as EmpName,
    emp_dept as EmpDept,
    emp_dob as EmpDob,
    emp_age as EmpAge,
    emp_basic as EmpBasic,
    created_at as CreatedAt,
    created_by as CreatedBy
}
