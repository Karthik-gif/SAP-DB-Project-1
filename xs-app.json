@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'COF NEXUS Report - RAP Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #X,
  sizeCategory: #XL,
  dataClass: #MIXED
}
define root view entity ZI_COF_REPORT
  as select from ztcof_data
{
  key txn_id               as TxnId,
      prd_type             as PrdType,
      prd_type_desc        as PrdTypeDesc,
      facility             as Facility,
      class_id             as ClassId,
      txn_no               as TxnNo,
      counter_party        as CounterParty,
      ref_rate_type        as RefRateType,
      rate_type            as RateType,
      start_date           as StartDate,
      end_date             as EndDate,
      txn_type             as TxnType,
      opening_amt          as OpeningAmt,
      addition_amt         as AdditionAmt,
      redemption_amt       as RedemptionAmt,
      closing_amt          as ClosingAmt,
      days                 as Days,
      accrual_amt          as AccrualAmt,
      wt_avg_amt           as WtAvgAmt,
      avg_funds            as AvgFunds,
      open_eir             as OpenEir,
      exit_eir             as ExitEir,
      wt_int_amt_eir       as WtIntAmtEir,
      avg_rate_eir         as AvgRateEir,
      avg_rate_eir_papm    as AvgRateEirPapm,
      exit_rate            as ExitRate,
      exit_spread          as ExitSpread,
      exit_final_rate      as ExitFinalRate,
      exit_final_rate_papm as ExitFinalRatePapm,
      avg_rate_yield       as AvgRateYield,
      avg_rate_yield_papm  as AvgRateYieldPapm,
      wt_int_amt_cyl       as WtIntAmtCoupYld,
      wt_amt_cyl           as WtAmtCoupYld,
      portfolio            as Portfolio,
      portfolio_desc       as PortfolioDesc
}
