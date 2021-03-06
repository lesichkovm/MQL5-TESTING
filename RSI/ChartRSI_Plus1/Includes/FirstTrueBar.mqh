//+------------------------------------------------------------------+
//|                                                 FirstTrueBar.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Класс для определения истинного бара                             |
//+------------------------------------------------------------------+
class CFirstTrueBar
  {
private:
   //--- Время истинного бара
   datetime          m_limit_time;
   //--- Номер истинного бара
   int               m_limit_bar;
   //---
public:
                     CFirstTrueBar(void);
                    ~CFirstTrueBar(void);
   //--- Возвращает (1) время и (2) номер истинного бара
   datetime          LimitTime(void) const { return(m_limit_time); }
   int               LimitBar(void)  const { return(m_limit_bar);  }
   //--- Определяет первый истинный бар
   bool              DetermineFirstTrueBar(void);
   //--- Проверка бара
   //bool              CheckFirstTrueBar(const int bar_index);
   //---
private:
   //--- Ищет первый истинный бар текущего периода
   void              GetFirstTrueBarTime(const datetime &time[]);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFirstTrueBar::CFirstTrueBar(void) : m_limit_time(NULL),
                                     m_limit_bar(WRONG_VALUE)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFirstTrueBar::~CFirstTrueBar(void)
  {
  }
//+------------------------------------------------------------------+
//| Определяет первый истинный бар                                   |
//+------------------------------------------------------------------+
bool CFirstTrueBar::DetermineFirstTrueBar(void)
  {
//--- Массив времени баров
   datetime time[];
//--- Получим общее количество баров символа
   int available_bars=::Bars(_Symbol,_Period);
//--- Скопируем массив времени баров. Если не получилось, попробуем еще раз.
   if(::CopyTime(_Symbol,_Period,0,available_bars,time)<available_bars)
      return(false);
//--- Получим время первого истинного бара, который соответствует текущему таймфрейму
   GetFirstTrueBarTime(time);
   return(true);
  }
//+------------------------------------------------------------------+
//| Ищет первый истинный бар текущего периода                        |
//+------------------------------------------------------------------+
void CFirstTrueBar::GetFirstTrueBarTime(const datetime &time[])
  {
//--- Получим размер массива
   int array_size=::ArraySize(time);
   ::ArraySetAsSeries(time,false);
//--- Поочередно проверяем каждый бар
   for(int i=1; i<array_size; i++)
     {
      //--- Если бар соответствует текущему таймфрейму
      if(time[i]-time[i-1]==::PeriodSeconds())
        {
         //--- Запомним и остановим цикл
         m_limit_time =time[i-1];
         m_limit_bar  =i-1;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Проверка первого истинного бара для отрисовки                    |
//+------------------------------------------------------------------+
//bool CFirstTrueBar::CheckFirstTrueBar(const int bar_index)
//  {
//   return(bar_index>=m_limit_bar);
//  }
//+------------------------------------------------------------------+
