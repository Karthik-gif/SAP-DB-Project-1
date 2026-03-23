@EndUserText.label: 'COF NEXUS Report - RAP Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: false

@UI.headerInfo: {
  typeName: 'COF Record',
  typeNamePlural: 'COF Records',
  title: { type: #STANDARD, value: 'TxnId' },
  description: { type: #STANDARD, value: 'PrdTypeDesc' }
}

define root view entity ZC_COF_REPORT
  provider contract transactional_query
  as projection on ZI_COF_REPORT
{
      @UI.facet: [{ id: 'General', type: #IDENTIFICATION_REFERENCE,
                    label: 'General Information', position: 10 }]

      @UI.identification: [{ position: 10 }]
      @UI.lineItem: [{ position: 10 }]
  key TxnId,

      @UI.identification: [{ position: 20 }]
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 10 }]
      PrdType,

      @UI.identification: [{ position: 30 }]
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 20 }]
      PrdTypeDesc,

      @UI.identification: [{ position: 40 }]
      @UI.lineItem: [{ position: 40 }]
      Facility,

      @UI.identification: [{ position: 50 }]
      ClassId,

      @UI.identification: [{ position: 60 }]
      TxnNo,

      @UI.identification: [{ position: 70 }]
      @UI.lineItem: [{ position: 70 }]
      @UI.selectionField: [{ position: 30 }]
      CounterParty,

      @UI.identification: [{ position: 80 }]
      RefRateType,

      @UI.identification: [{ position: 90 }]
      @UI.lineItem: [{ position: 90 }]
      @UI.selectionField: [{ position: 40 }]
      RateType,

      @UI.identification: [{ position: 100 }]
      StartDate,

      @UI.identification: [{ position: 110 }]
      EndDate,

      @UI.identification: [{ position: 120 }]
      TxnType,

      @Semantics.amount.currencyCode: 'PortfolioDesc'
      @UI.identification: [{ position: 130 }]
      @UI.lineItem: [{ position: 130 }]
      OpeningAmt,

      @UI.identification: [{ position: 140 }]
      AdditionAmt,

      @UI.identification: [{ position: 150 }]
      RedemptionAmt,

      @UI.identification: [{ position: 160 }]
      @UI.lineItem: [{ position: 160 }]
      ClosingAmt,

      @UI.identification: [{ position: 170 }]
      Days,

      @UI.identification: [{ position: 180 }]
      @UI.lineItem: [{ position: 180 }]
      AccrualAmt,

      @UI.identification: [{ position: 190 }]
      WtAvgAmt,

      @UI.identification: [{ position: 200 }]
      AvgFunds,

      @UI.identification: [{ position: 210 }]
      OpenEir,

      @UI.identification: [{ position: 220 }]
      @UI.lineItem: [{ position: 220 }]
      ExitEir,

      @UI.identification: [{ position: 230 }]
      WtIntAmtEir,

      @UI.identification: [{ position: 240 }]
      @UI.lineItem: [{ position: 240 }]
      AvgRateEir,

      @UI.identification: [{ position: 250 }]
      AvgRateEirPapm,

      @UI.identification: [{ position: 260 }]
      ExitRate,

      @UI.identification: [{ position: 270 }]
      ExitSpread,

      @UI.identification: [{ position: 280 }]
      ExitFinalRate,

      @UI.identification: [{ position: 290 }]
      ExitFinalRatePapm,

      @UI.identification: [{ position: 300 }]
      AvgRateYield,

      @UI.identification: [{ position: 310 }]
      AvgRateYieldPapm,

      @UI.identification: [{ position: 320 }]
      WtIntAmtCoupYld,

      @UI.identification: [{ position: 330 }]
      WtAmtCoupYld,

      @UI.identification: [{ position: 340 }]
      @UI.lineItem: [{ position: 340 }]
      @UI.selectionField: [{ position: 50 }]
      Portfolio,

      @UI.identification: [{ position: 350 }]
      @UI.lineItem: [{ position: 350 }]
      PortfolioDesc
}
