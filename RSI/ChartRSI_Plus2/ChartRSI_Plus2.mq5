//+------------------------------------------------------------------+
//|                                               ChartRSI_Plus2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2018, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "email: hello.tol64@gmail.com"
#property version     "1.0"
//--- Свойства
#property indicator_chart_window
#property indicator_buffers 20
#property indicator_plots   15
#property indicator_color1  clrMediumSeaGreen
#property indicator_color2  clrRed
#property indicator_color5  clrMediumSeaGreen
#property indicator_color6  clrRed
#property indicator_color10 clrMediumSeaGreen
#property indicator_color11 clrRed
#property indicator_color14 clrMediumSeaGreen // C'16,109,27' // C'46,139,87' // clrSeaGreen
#property indicator_color15 clrRed            // C'190,0,  0' // C'220,20,60' // clrCrimson

//--- Стрелки для сигналов: 159 - точки; 233/234 - стрелки;
#define ARROW_BUY_IN   233
#define ARROW_SELL_IN  234
#define ARROW_BUY_OUT  159
#define ARROW_SELL_OUT 159

//--- Подключаем классы индикаторов
#include "Includes\ATR.mqh"
#include "Includes\RsiPlus.mqh"

//--- Входные параметры
input int    PeriodRSI      =8;   // RSI period
input double SignalLevelIn  =35;  // Signal level In
input double SignalLevelOut =30;  // Signal level Out
input int    PeriodATR      =100; // ATR period

//--- Отступ для стрелок
int arrow_shift=30;
//--- Экземпляры индикаторов для работы
CATR     atr(PeriodATR);
CRsiPlus rsi_in(PeriodRSI,SignalLevelIn,BREAK_IN_REVERSE);
CRsiPlus rsi_out(PeriodRSI,SignalLevelOut,BREAK_OUT_REVERSE);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
//--- Передача указателя на ATR  
   rsi_in.AtrPointer(atr);
   rsi_out.AtrPointer(atr);
//--- Установим свойства индикатора
   SetPropertiesIndicator();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int      rates_total,
                const int      prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
//--- Рассчитать индикатор ATR
   if(!atr.CalculateIndicatorATR(rates_total,prev_calculated,time,close,high,low))
      return(0);
//--- Рассчитать индикатор RSI
   if(!rsi_in.CalculateIndicatorRSI(rates_total,prev_calculated,close,spread))
      return(0);
   if(!rsi_out.CalculateIndicatorRSI(rates_total,prev_calculated,close,spread))
      return(0);
//--- Вернуть последнее рассчитанное количество элементов
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Устанавливает свойства индикатора                                |
//+------------------------------------------------------------------+
void SetPropertiesIndicator(void)
  {
//--- Короткое имя
   ::IndicatorSetString(INDICATOR_SHORTNAME,"RSI_PLUS2_CHART");
//--- Знаков после запятой
   ::IndicatorSetInteger(INDICATOR_DIGITS,::Digits());
//--- Буферы индикатора
   ::SetIndexBuffer(0,rsi_in.m_buy_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(1,rsi_in.m_sell_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(2,rsi_in.m_buy_counter_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(3,rsi_in.m_sell_counter_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(4,rsi_in.m_buy_level_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(5,rsi_in.m_sell_level_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(6,rsi_in.m_rsi_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(7,rsi_in.m_pos_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(8,rsi_in.m_neg_buffer,INDICATOR_CALCULATIONS);
//---
   ::SetIndexBuffer(9,rsi_out.m_buy_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(10,rsi_out.m_sell_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(11,rsi_out.m_buy_counter_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(12,rsi_out.m_sell_counter_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(13,rsi_out.m_buy_level_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(14,rsi_out.m_sell_level_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(15,rsi_out.m_rsi_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(16,rsi_out.m_pos_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(17,rsi_out.m_neg_buffer,INDICATOR_CALCULATIONS);
//---
   ::SetIndexBuffer(18,atr.m_atr_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(19,atr.m_tr_buffer,INDICATOR_CALCULATIONS);
//--- Инициализация массивов
   atr.ZeroIndicatorBuffers();
   rsi_in.ZeroIndicatorBuffers();
   rsi_out.ZeroIndicatorBuffers();
//--- Установим метки
   string plot_label1[]={"buy in","sell in","buy in counter","sell in counter","buy in level","sell in level"};
   for(int i=0; i<6; i++)
      ::PlotIndexSetString(i,PLOT_LABEL,plot_label1[i]);
   string plot_label2[]={"buy out","sell out","buy out counter","sell out counter","buy out level","sell out level"};
   for(int i=9; i<indicator_plots; i++)
      ::PlotIndexSetString(i,PLOT_LABEL,plot_label2[i-9]);
//--- Установим толщину для индикаторных буферов
   for(int i=0; i<19; i++)
      ::PlotIndexSetInteger(i,PLOT_LINE_WIDTH,-1);
//--- Установим тип для индикаторных буферов
   ENUM_DRAW_TYPE draw_type1[]={DRAW_ARROW,DRAW_ARROW,DRAW_NONE,DRAW_NONE,DRAW_LINE,DRAW_LINE,DRAW_LINE};
   for(int i=0; i<7; i++)
      ::PlotIndexSetInteger(i,PLOT_DRAW_TYPE,draw_type1[i]);
   ENUM_DRAW_TYPE draw_type2[]={DRAW_ARROW,DRAW_ARROW,DRAW_NONE,DRAW_NONE,DRAW_LINE,DRAW_LINE,DRAW_LINE};
   for(int i=9; i<indicator_plots; i++)
      ::PlotIndexSetInteger(i,PLOT_DRAW_TYPE,draw_type2[i-9]);
//--- Установим стиль линиям указанных индикаторных буферов
   ::PlotIndexSetInteger(13,PLOT_LINE_STYLE,STYLE_DOT);
   ::PlotIndexSetInteger(14,PLOT_LINE_STYLE,STYLE_DOT);
//--- Номера меток
   ::PlotIndexSetInteger(0,PLOT_ARROW,ARROW_BUY_IN);
   ::PlotIndexSetInteger(1,PLOT_ARROW,ARROW_SELL_IN);
   ::PlotIndexSetInteger(9,PLOT_ARROW,ARROW_BUY_OUT);
   ::PlotIndexSetInteger(10,PLOT_ARROW,ARROW_SELL_OUT);
//--- Пустое значение для построения, для которого нет отрисовки
   for(int i=0; i<19; i++)
      ::PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0);
//--- Сдвиг по оси Y
   ::PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,arrow_shift);
   ::PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-arrow_shift);
   ::PlotIndexSetInteger(9,PLOT_ARROW_SHIFT,arrow_shift);
   ::PlotIndexSetInteger(10,PLOT_ARROW_SHIFT,-arrow_shift);
  }
//+------------------------------------------------------------------+
