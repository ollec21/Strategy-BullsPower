/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_BullsPower_Params_M30 : Indi_BullsPower_Params {
  Indi_BullsPower_Params_M30() : Indi_BullsPower_Params(indi_bulls_defaults, PERIOD_M30) {
    applied_price = (ENUM_APPLIED_PRICE)2;
    ma_method = 0;
    period = 14;
    shift = 0;
  }
} indi_bulls_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_BullsPower_Params_M30 : StgParams {
  // Struct constructor.
  Stg_BullsPower_Params_M30() : StgParams(stg_bulls_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0.0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_bulls_m30;
