//+------------------------------------------------------------------+
//|                                                   RSI plus 1.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2018, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property version     "1.0"
//--- Свойства
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_color1  clrSteelBlue
#property indicator_color2  clrMediumSeaGreen
#property indicator_color3  clrRed
//--- Стрелки для сигналов: 159 - точки; 233/234 - стрелки;
#define ARROW_BUY  159
#define ARROW_SELL 159
//--- Перечисление режимов пробоя границ канала
enum ENUM_BREAK_INOUT
  {
   BREAK_IN          =0, // Break in
   BREAK_IN_REVERSE  =1, // Break in reverse
   BREAK_OUT         =2, // Break out
   BREAK_OUT_REVERSE =3  // Break out reverse
  };
//--- Входные параметры
input  int              PeriodRSI   =8;         // RSI Period
input  double           SignalLevel =30;        // Signal Level
input  ENUM_BREAK_INOUT BreakMode   =BREAK_OUT; // Break Mode
//--- Индикаторные массивы
double rsi_buffer[];
double buy_buffer[];
double sell_buffer[];
double pos_buffer[];
double neg_buffer[];
//--- Отступ для стрелок
int arrow_shift=0;
//--- Период индикатора
int period_rsi=0;
//--- Значения горизонтальных уровней индикатора
double up_level   =0;
double down_level =0;
//--- Начальная позиция для расчётов индикатора
int start_pos=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
//--- Проверка значения внешнего параметра
   if(PeriodRSI<1)
     {
      period_rsi=2;
      Print("Incorrect value for input variable PeriodRSI =",PeriodRSI,
            "Indicator will use value =",period_rsi,"for calculations.");
     }
   else
      period_rsi=PeriodRSI;
//--- Установим свойства индикатора
   SetPropertiesIndicator();
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
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
//--- Выйти, если данных недостаточно
   if(rates_total<=period_rsi)
      return(0);
//--- Предварительные расчеты
   PreliminaryCalculations(prev_calculated,close);
//--- Основной цикл для расчётов
   for(int i=start_pos; i<rates_total && !::IsStopped(); i++)
     {
      //--- Рассчитывает индикатор RSI
      CalculateRSI(i,close);
      //--- Рассчитывает сигналы
      CalculateSignals(i);
     }
//--- Вернуть последнее рассчитанное количество элементов
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Устанавливает свойства индикатора                                |
//+------------------------------------------------------------------+
void SetPropertiesIndicator(void)
  {
//--- Короткое имя
   ::IndicatorSetString(INDICATOR_SHORTNAME,"RSI_PLUS1");
//--- Знаков после запятой
   ::IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- Массивы индикатора
   ::SetIndexBuffer(0,rsi_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(1,buy_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(2,sell_buffer,INDICATOR_DATA);
   ::SetIndexBuffer(3,pos_buffer,INDICATOR_CALCULATIONS);
   ::SetIndexBuffer(4,neg_buffer,INDICATOR_CALCULATIONS);
//--- Инициализация массивов
   ZeroIndicatorBuffers();
//--- Установим текстовые метки
   string plot_label[]={"RSI","buy","sell"};
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetString(i,PLOT_LABEL,plot_label[i]);
//--- Установим толщину для индикаторных массивов
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetInteger(i,PLOT_LINE_WIDTH,1);
//--- Установим тип для индикаторных массивов
   ENUM_DRAW_TYPE draw_type[]={DRAW_LINE,DRAW_ARROW,DRAW_ARROW};
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetInteger(i,PLOT_DRAW_TYPE,draw_type[i]);
//--- Коды меток
   ::PlotIndexSetInteger(1,PLOT_ARROW,ARROW_BUY);
   ::PlotIndexSetInteger(2,PLOT_ARROW,ARROW_SELL);
//--- Индекс элемента, от которого начинается расчёт
   for(int i=0; i<indicator_plots; i++)
      ::PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,period_rsi);
//--- Количество горизонтальных уровней индикатора
   ::IndicatorSetInteger(INDICATOR_LEVELS,2);
//--- Значения горизонтальных уровней индикатора
   up_level   =100-SignalLevel;
   down_level =SignalLevel;
   ::IndicatorSetDouble(INDICATOR_LEVELVALUE,0,down_level);
   ::IndicatorSetDouble(INDICATOR_LEVELVALUE,1,up_level);
//--- Стиль линии
   ::IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DOT);
   ::IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DOT);
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
//| Обнуление индикаторных буферов                                   |
//+------------------------------------------------------------------+
void ZeroIndicatorBuffers(void)
  {
   ::ArrayInitialize(rsi_buffer,0);
   ::ArrayInitialize(buy_buffer,0);
   ::ArrayInitialize(sell_buffer,0);
  }
//+------------------------------------------------------------------+
//| Предварительные расчёты                                          |
//+------------------------------------------------------------------+
void PreliminaryCalculations(const int prev_calculated,const double &price[])
  {
   double diff=0;
//---
   start_pos=prev_calculated-1;
   if(start_pos<=period_rsi)
     {
      //--- Первое значение индикатора не рассчитывается
      rsi_buffer[0]=0.0;
      pos_buffer[0]=0.0;
      neg_buffer[0]=0.0;
      //---
      double sum_p=0.0;
      double sum_n=0.0;
      //---
      for(int i=1; i<=period_rsi; i++)
        {
         rsi_buffer[i]=0.0;
         pos_buffer[i]=0.0;
         neg_buffer[i]=0.0;
         //---
         diff=price[i]-price[i-1];
         sum_p+=(diff>0? diff : 0);
         sum_n+=(diff<0? -diff : 0);
        }
      //--- Расчёт первого значения 
      pos_buffer[period_rsi] =sum_p/period_rsi;
      neg_buffer[period_rsi] =sum_n/period_rsi;
      //---
      if(neg_buffer[period_rsi]!=0.0)
         rsi_buffer[period_rsi]=100.0-(100.0/(1.0+pos_buffer[period_rsi]/neg_buffer[period_rsi]));
      else
        {
         if(pos_buffer[period_rsi]!=0.0)
            rsi_buffer[period_rsi]=100.0;
         else
            rsi_buffer[period_rsi]=50.0;
        }
      //--- Начальная позиция для расчётов
      start_pos=period_rsi+1;
     }
  }
//+------------------------------------------------------------------+
//| Рассчитывает индикатор RSI                                       |
//+------------------------------------------------------------------+
void CalculateRSI(const int i,const double &price[])
  {
   double diff=price[i]-price[i-1];
//---
   pos_buffer[i] =(pos_buffer[i-1]*(period_rsi-1)+(diff>0.0? diff : 0.0))/period_rsi;
   neg_buffer[i] =(neg_buffer[i-1]*(period_rsi-1)+(diff<0.0? -diff : 0.0))/period_rsi;
//---
   if(neg_buffer[i]!=0.0)
      rsi_buffer[i]=100.0-100.0/(1+pos_buffer[i]/neg_buffer[i]);
   else
     {
      rsi_buffer[i]=(pos_buffer[i]!=0.0)? 100.0 : 50.0;
     }
  }
//+------------------------------------------------------------------+
//| Рассчитывает сигналы индикатора                                  |
//+------------------------------------------------------------------+
void CalculateSignals(const int i)
  {
   bool condition1 =false;
   bool condition2 =false;
//--- Пробой внутрь канала
   if(BreakMode==BREAK_IN || BreakMode==BREAK_IN_REVERSE)
     {
      condition1 =rsi_buffer[i-1]<down_level && rsi_buffer[i]>down_level;
      condition2 =rsi_buffer[i-1]>up_level && rsi_buffer[i]<up_level;
     }
   else
     {
      condition1 =rsi_buffer[i-1]<up_level && rsi_buffer[i]>up_level;
      condition2 =rsi_buffer[i-1]>down_level && rsi_buffer[i]<down_level;
     }
//--- Отображаем сигналы, если условия исполнились
   if(BreakMode==BREAK_IN || BreakMode==BREAK_OUT)
     {
      buy_buffer[i]  =(condition1)? rsi_buffer[i] : 0;
      sell_buffer[i] =(condition2)? rsi_buffer[i] : 0;
     }
   else
     {
      buy_buffer[i]  =(condition2)? rsi_buffer[i] : 0;
      sell_buffer[i] =(condition1)? rsi_buffer[i] : 0;
     }
  }
//+------------------------------------------------------------------+
