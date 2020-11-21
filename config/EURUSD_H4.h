/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_BullsPower_Params_H4 : Indi_BullsPower_Params {
  Indi_BullsPower_Params_H4() : Indi_BullsPower_Params(indi_bulls_defaults, PERIOD_H4) { shift = 0; }
} indi_bulls_h4;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct stg_bulls_Params_H4 : StgParams {
  // Struct constructor.
  stg_bulls_Params_H4() : StgParams(stg_bulls_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = 0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = 0;
    price_limit_method = 0;
    price_limit_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_bulls_h4;
