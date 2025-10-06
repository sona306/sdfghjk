@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for dept dropdown'
//@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define root view entity ZR_DEPT_DROPDOWN 
as select from zdb_emp_dept

{
@Search.defaultSearchElement: true
@EndUserText.label: 'Sensitive'
    key type as Type,
    value as Value
}
