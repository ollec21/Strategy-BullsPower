//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_BullsPower_EURUSD_M15_Params : Stg_BullsPower_Params {
  Stg_BullsPower_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    BullsPower_Period = 13;
    BullsPower_Applied_Price = 1;
    BullsPower_Shift = 0;
    BullsPower_TrailingStopMethod = 0;
    BullsPower_TrailingProfitMethod = 0;
    BullsPower_SignalOpenLevel = 0;
    BullsPower_SignalBaseMethod = 0;
    BullsPower_SignalOpenMethod1 = 0;
    BullsPower_SignalOpenMethod2 = 0;
    BullsPower_SignalCloseLevel = 0;
    BullsPower_SignalCloseMethod1 = 0;
    BullsPower_SignalCloseMethod2 = 0;
    BullsPower_MaxSpread = 0;
  }
};
