@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for leaves'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_LEAVES
as select from ZI_LEAVES
association to parent ZR_EMPLOYEE_DETAILS as _employee
on $projection.EmpId = _employee.EmpId
{
    key EmpId,
    key LeaveId,
    LeaveType,
    StartDate,
    EndDate,
    Duration,
    Approve,
     @Semantics.systemDateTime.createdAt: true
    CreatedAt,
    @Semantics.user.createdBy: true
    CreatedBy,
    _employee // Make association public
}
