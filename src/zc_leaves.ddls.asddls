@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for leaves'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_LEAVES
as projection on ZR_LEAVES
{
    key EmpId,
    key LeaveId,
    LeaveType,
    StartDate,
    EndDate,
    Duration,
    Approve,
    CreatedAt,
    CreatedBy,
    /* Associations */
    _employee : redirected to parent ZC_EMPLOYEE_DETAILS
}
