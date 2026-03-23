managed implementation in class zbp_i_cof_report unique;
strict ( 2 );

define behavior for ZI_COF_REPORT alias CofReport
  persistent table ztcof_data
  lock master
  authorization master ( instance )
  etag dependent by TxnId
{
  -- READ-ONLY service: no CUD operations exposed
  -- All transactional ops are internal only
  internal create;
  internal update;
  internal delete;
}
