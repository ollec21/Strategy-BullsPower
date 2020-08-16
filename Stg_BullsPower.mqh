/**
 * @file
 * Implements BullsPower strategy based on the Bulls Power indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_BullsPower.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT float BullsPower_LotSize = 0;                    // Lot size
INPUT int BullsPower_SignalOpenMethod = 0;             // Signal open method (0-
INPUT float BullsPower_SignalOpenLevel = 0.00000000;   // Signal open level
INPUT int BullsPower_SignalOpenFilterMethod = 0;       // Signal filter method
INPUT int BullsPower_SignalOpenBoostMethod = 0;        // Signal boost method
INPUT int BullsPower_SignalCloseMethod = 0;            // Signal close method
INPUT float BullsPower_SignalCloseLevel = 0.00000000;  // Signal close level
INPUT int BullsPower_PriceLimitMethod = 0;             // Price limit method
INPUT float BullsPower_PriceLimitLevel = 0;            // Price limit level
INPUT int BullsPower_TickFilterMethod = 0;             // Tick filter method
INPUT float BullsPower_MaxSpread = 6.0;                // Max spread to trade (pips)
INPUT int BullsPower_Shift = 0;                        // Shift (relative to the current bar, 0 - default)
INPUT string __BullsPower_Indi_BullsPower_Parameters__ =
    "-- BullsPower strategy: BullsPower indicator params --";  // >>> BullsPower strategy: BullsPower indicator <<<
INPUT int Indi_BullsPower_Period = 13;                         // Period
INPUT ENUM_APPLIED_PRICE Indi_BullsPower_Applied_Price = PRICE_CLOSE;  // Applied Price

// Structs.

// Defines struct with default user indicator values.
struct Indi_BullsPower_Params_Defaults : BullsPowerParams {
  Indi_BullsPower_Params_Defaults() : BullsPowerParams(::Indi_BullsPower_Period, ::Indi_BullsPower_Applied_Price) {}
} indi_bulls_defaults;

// Defines struct to store indicator parameter values.
struct Indi_BullsPower_Params : public BullsPowerParams {
  // Struct constructors.
  void Indi_BullsPower_Params(BullsPowerParams &_params, ENUM_TIMEFRAMES _tf) : BullsPowerParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_BullsPower_Params_Defaults : StgParams {
  Stg_BullsPower_Params_Defaults()
      : StgParams(::BullsPower_SignalOpenMethod, ::BullsPower_SignalOpenFilterMethod, ::BullsPower_SignalOpenLevel,
                  ::BullsPower_SignalOpenBoostMethod, ::BullsPower_SignalCloseMethod, ::BullsPower_SignalCloseLevel,
                  ::BullsPower_PriceLimitMethod, ::BullsPower_PriceLimitLevel, ::BullsPower_TickFilterMethod,
                  ::BullsPower_MaxSpread, ::BullsPower_Shift) {}
} stg_bulls_defaults;

// Struct to define strategy parameters to override.
struct Stg_BullsPower_Params : StgParams {
  Indi_BullsPower_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_BullsPower_Params(Indi_BullsPower_Params &_iparams, StgParams &_sparams)
      : iparams(indi_bulls_defaults, _iparams.tf), sparams(stg_bulls_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_BullsPower : public Strategy {
 public:
  Stg_BullsPower(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_BullsPower *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_BullsPower_Params _indi_params(indi_bulls_defaults, _tf);
    StgParams _stg_params(stg_bulls_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_BullsPower_Params>(_indi_params, _tf, indi_bulls_m1, indi_bulls_m5, indi_bulls_m15,
                                            indi_bulls_m30, indi_bulls_h1, indi_bulls_h4, indi_bulls_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_bulls_m1, stg_bulls_m5, stg_bulls_m15, stg_bulls_m30, stg_bulls_h1,
                               stg_bulls_h4, stg_bulls_h8);
    }
    // Initialize indicator.
    BullsPowerParams bulls_params(_indi_params);
    _stg_params.SetIndicator(new Indi_BullsPower(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_BullsPower(_stg_params, "BullsPower");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    Chart *_chart = Chart();
    Indi_BullsPower *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Strong uptrend - the histogram is located above balance line.
        _result &= _indi[CURR].value[0] > _level;
        if (_method != 0) {
          // The growth of histogram, which is below zero, suggests that,
          // while sellers dominate the market, their strength begins to weaken and buyers gradually increase their
          // interest.
          if (METHOD(_method, 0))
            _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];  // ... 2 consecutive columns are green.
          if (METHOD(_method, 1))
            _result &= _indi[PPREV].value[0] > _indi[3].value[0];  // ... 3 consecutive columns are green.
          if (METHOD(_method, 2))
            _result &= _indi[3].value[0] > _indi[4].value[0];  // ... 4 consecutive columns are green.
          // When the histogram is above zero level, but the beams are directed downwards (the tendency to decrease),
          // then we can assume that, despite the still bullish sentiments on the market, their strength is weakening.
          if (METHOD(_method, 3))
            _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];  // ... 2 consecutive columns are red.
          if (METHOD(_method, 4))
            _result &= _indi[PPREV].value[0] < _indi[3].value[0];  // ... 3 consecutive columns are red.
          if (METHOD(_method, 5))
            _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are red.
          if (METHOD(_method, 6)) _result &= _indi[PREV].value[0] > 0;
          // @todo: Divergence situations between the price schedule and Bulls Power histogram - a traditionally strong
          // reversal signal.
        }
        break;
      case ORDER_TYPE_SELL:
        // Histogram is below zero level.
        _result &= _indi[CURR].value[0] < _level;
        if (_method != 0) {
          // If the histogram is above zero level, but the beams are directed downwards (the tendency to decrease),
          // then we can assume that, despite the still bullish sentiments on the market, their strength is weakening
          if (METHOD(_method, 0))
            _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];  // ... 2 consecutive columns are red.
          if (METHOD(_method, 1))
            _result &= _indi[PPREV].value[0] < _indi[3].value[0];  // ... 3 consecutive columns are red.
          if (METHOD(_method, 2))
            _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are red.
          if (METHOD(_method, 3))
            _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];  // ... 2 consecutive columns are green.
          if (METHOD(_method, 4))
            _result &= _indi[PPREV].value[0] > _indi[3].value[0];  // ... 3 consecutive columns are green.
          if (METHOD(_method, 5))
            _result &= _indi[3].value[0] > _indi[4].value[0];  // ... 4 consecutive columns are green.
          // When the histogram passes through the zero level from top down,
          // bulls lost control of the market and bears increase pressure; waiting for price to turn down.
          if (METHOD(_method, 6)) _result &= _indi[PREV].value[0] < 0;
          // @todo: Divergence situations between the price schedule and Bulls Power histogram - a traditionally strong
          // reversal signal.
        }
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_BullsPower *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd) * (_mode == ORDER_TYPE_SL ? -1 : 1);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count0 = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count0))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count0));
        break;
      }
      case 1: {
        int _bar_count1 = (int)_level * (int)_indi.GetPeriod();
        _result = _direction < 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count1))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count1));
        break;
      }
    }
    return (float)_result;
  }
};
