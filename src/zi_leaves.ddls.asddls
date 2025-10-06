@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for leaves'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_LEAVES 
as select from zdb_leave
{
    key emp_id as EmpId,
    key leave_id as LeaveId,
    leave_type as LeaveType,
    start_date as StartDate,
    end_date as EndDate,
    duration as Duration,
    approve as Approve,
    created_at as CreatedAt,
    created_by as CreatedBy
}
