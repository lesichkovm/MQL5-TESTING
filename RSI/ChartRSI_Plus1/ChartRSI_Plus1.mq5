//+------------------------------------------------------------------+
//|                                               ChartRSI_Plus1.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2018, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property version     "1.0"
//--- Свойства
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   7
#property indicator_color1  clrMediumSeaGreen
#property indicator_color2  clrRed
#property indicator_color5  clrMediumSeaGreen
#property indicator_color6  clrRed
//--- Стрелки для сигналов: 159 - точки; 233/234 - стрелки;
#define ARROW_BUY  159
#define ARROW_SELL 159

//--- Подключаем классы индикаторов
#include "Includes\ATR.mqh"
#include "Includes\RsiPlus.mqh"

//--- Входные параметры
input int              PeriodRSI   =8;         // RSI period
input double           SignalLevel =30;        // Signal level
input ENUM_BREAK_INOUT BreakMode   =BREAK_OUT; // Break mode
input int              PeriodATR   =200;       // ATR period

//--- Отступ для стрелок
int arrow_shift=30;
//--- Экземпляры индикаторов для работы
CATR     atr(PeriodATR);
CRsiPlus rsi(PeriodRSI,SignalLevel,BreakMode);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
//--- Передача указателя на ATR
   rsi.AtrPointer(atr);
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
   if(!rsi.CalculateIndicatorRSI(rates_total,prev_calculated,close,spread))
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
   ::IndicatorSetString(INDICATOR_SHORTNAME,"RSI_PLUS_CHART");
//--- Знаков после запятой
   ::IndicatorSetInteger(INDICATOR_DIGITS,::Digits());
//--- Буферы индикатора
   ::SetIndexBuffer(0,rsi.m_buy_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(1,rsi.m_sell_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(2,rsi.m_buy_counter_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(3,rsi.m_sell_counter_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(4,rsi.m_buy_level_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(5,rsi.m_sell_level_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(6,atr.m_atr_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(7,rsi.m_rsi_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(8,rsi.m_pos_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(9,rsi.m_neg_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(10,atr.m_tr_buffer,INDICATOR_CALCULATIONS);
//--- Инициализация массивов
   atr.ZeroIndicatorBuffers();
   rsi.ZeroIndicatorBuffers();
//--- Установим метки
   string plot_label[]={"buy","sell","buy counter","sell counter","buy level","sell level","atr"};
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetString(i,PLOT_LABEL,plot_label[i]);
//--- Установим толщину для индикаторных буферов
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetInteger(i,PLOT_LINE_WIDTH,1);
//--- Установим тип для индикаторных буферов
   ENUM_DRAW_TYPE draw_type[]={DRAW_ARROW,DRAW_ARROW,DRAW_NONE,DRAW_NONE,DRAW_LINE,DRAW_LINE,DRAW_NONE};
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetInteger(i,PLOT_DRAW_TYPE,draw_type[i]);
//--- Номера меток
   ::PlotIndexSetInteger(0,PLOT_ARROW,ARROW_BUY);
   ::PlotIndexSetInteger(1,PLOT_ARROW,ARROW_SELL);
//--- Пустое значение для построения, для которого нет отрисовки
   for(int i=0; i<indicator_buffers; i++)
      ::PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0);
//--- Сдвиг по оси Y
   if(BreakMode==BREAK_IN_REVERSE || BreakMode==BREAK_OUT_REVERSE)
     {
      ::PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,arrow_shift);
      ::PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-arrow_shift);
     }
   else
     {
      ::PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-arrow_shift);
      ::PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,arrow_shift);
     }
  }
//+------------------------------------------------------------------+
