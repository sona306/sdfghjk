@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for employees'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_EMPLOYEE_DETAILS 
as select from ZI_EMPLOYEE_DETAILS
composition [0..*] of ZR_LEAVES as _leaves
association [0..*] to ZR_DEPT_DROPDOWN as _dept
on $projection.EmpDept =  _dept.Value
{
    key EmpId,
    EmpName,
    EmpDept,
    EmpDob,
    EmpAge,
    EmpBasic,
    @Semantics.systemDateTime.createdAt: true
    CreatedAt,
    @Semantics.user.createdBy: true
    CreatedBy,
    _leaves ,
    _dept // Make association public
    
}
