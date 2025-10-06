@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for employee'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_EMPLOYEE_DETAILS
provider contract transactional_query
as projection on ZR_EMPLOYEE_DETAILS
{
    key EmpId,
    EmpName,
    EmpDept,
    EmpDob,
    EmpAge,
    EmpBasic,
    CreatedAt,
    CreatedBy,
    /* Associations */
    _leaves : redirected to composition child ZC_LEAVES 
}
