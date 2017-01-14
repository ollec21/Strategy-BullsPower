//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of Bears/Bulls Power Strategy based on the Bears/Bulls Power indicators.
 *
 * @docs
 * - https://docs.mql4.com/indicators/iBearsPower
 * - https://docs.mql4.com/indicators/iBullsPower
 * - https://www.mql5.com/en/docs/indicators/iBearsPower
 * - https://www.mql5.com/en/docs/indicators/iBullsPower
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __BBPower_Parameters__ = "-- Settings for the Bulls/Bears Power indicator --"; // >>> BULLS/BEARS POWER <<<
#ifdef __input__ input #endif int BBPower_Period = 13; // Period
#ifdef __input__ input #endif ENUM_APPLIED_PRICE BBPower_Applied_Price = 0; // Applied Price
#ifdef __input__ input #endif double BBPower_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input #endif int BBPower_SignalMethod = 15; // Signal method (0-
#ifdef __input__ input #endif int BBPower_SignalMethods = ""; // Signal methods (0-

class BBPower: public Strategy {
protected:

  double bbpower[H1][FINAL_ENUM_INDICATOR_INDEX][OP_SELL+1];
  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Bears Power and Bulls Power indicators.
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      BBPower[index][i][OP_BUY]  = iBullsPower(symbol, tf, BBPower_Period, BBPower_Applied_Price, i);
      BBPower[index][i][OP_SELL] = iBearsPower(symbol, tf, BBPower_Period, BBPower_Applied_Price, i);
    }
    success = (bool)(BBPower[index][CURR][OP_BUY] || BBPower[index][CURR][OP_SELL]);
    // Message("Bulls: " + BBPower[index][CURR][OP_BUY] + ", Bears: " + BBPower[index][CURR][OP_SELL]);
  }

  /**
   * Checks whether signal is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE; int period = Timeframe::TfToIndex(tf);
    UpdateIndicator(S_BBPower, tf);
    if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_BBPower, tf, 0);
    if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_BBPower, tf, 0.0);
    switch (cmd) {
      case OP_BUY:
        /*
          bool result = BBPower[period][CURR][LOWER] != 0.0 || BBPower[period][PREV][LOWER] != 0.0 || BBPower[period][FAR][LOWER] != 0.0;
          if ((signal_method &   1) != 0) result &= Open[CURR] > Close[CURR];
          if ((signal_method &   2) != 0) result &= !BBPower_On_Sell(tf);
          if ((signal_method &   4) != 0) result &= BBPower_On_Buy(fmin(period + 1, M30));
          if ((signal_method &   8) != 0) result &= BBPower_On_Buy(M30);
          if ((signal_method &  16) != 0) result &= BBPower[period][FAR][LOWER] != 0.0;
          if ((signal_method &  32) != 0) result &= !BBPower_On_Sell(M30);
          */
      break;
      case OP_SELL:
        /*
          bool result = BBPower[period][CURR][UPPER] != 0.0 || BBPower[period][PREV][UPPER] != 0.0 || BBPower[period][FAR][UPPER] != 0.0;
          if ((signal_method &   1) != 0) result &= Open[CURR] < Close[CURR];
          if ((signal_method &   2) != 0) result &= !BBPower_On_Buy(tf);
          if ((signal_method &   4) != 0) result &= BBPower_On_Sell(fmin(period + 1, M30));
          if ((signal_method &   8) != 0) result &= BBPower_On_Sell(M30);
          if ((signal_method &  16) != 0) result &= BBPower[period][FAR][UPPER] != 0.0;
          if ((signal_method &  32) != 0) result &= !BBPower_On_Buy(M30);
          */
      break;
    }
    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return result;
  }

};
