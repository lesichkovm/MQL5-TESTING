//--- input parameters

input int      InputCountBars    = 1200;  // Count of bars
input bool     InpVerification   = false; // Verification

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   enum ENUM_SERIES_TYPE
     {
      Bull=1,  // ↑
      Bear=-1, // ↓
     };
//+------------------------------------------------------------------+
//| arr_series[][0]:    series type                                  |
//| arr_series[][1]:    count of series                              |
//+------------------------------------------------------------------+
   double arr_series[][2];
   MqlRates rates[];
   int copied=CopyRates(Symbol(),0,0,InputCountBars,rates);
   if(copied==InputCountBars)
     {
      for(int i=0;i<copied;i++)
        {
         //--- here we define type of series
         static int  prev_series_type     = 0;
         int         current_series_type  = 0;
         static int  count_series         = 0;
         if(rates[i].open<rates[i].close)
            current_series_type=Bull;
         else if(rates[i].open>rates[i].close)
            current_series_type=Bear;
         else
            continue;
         //--- count of series
         if(current_series_type==prev_series_type || prev_series_type==0)
            count_series++;
         else // generate the name of the series (only if the bar type has changed)
           {
            int name_series=current_series_type*count_series;
            count_series=1;
            //--- search for this series in an array and enter data
            bool IsFound=false;
            int size=ArrayRange(arr_series,0);
            for(int j=0;j<size;j++)
              {
               //+------------------------------------------------------------------+
               //| arr_series[][0]:    series type                                  |
               //| arr_series[][1]:    count of series                              |
               //+------------------------------------------------------------------+
               if(arr_series[j][0]==name_series)
                 {
                  IsFound=true;
                  arr_series[j][1]=arr_series[j][1]+1;
                 }
              }
            if(!IsFound)
              {
               ArrayResize(arr_series,size+1);
               arr_series[size][0]=name_series;
               arr_series[size][1]=1;
              }
           }
         prev_series_type=current_series_type;
        }
     }
   else
     {
      Print("Failed to get history data for the symbol ",Symbol(),". Bars copied ",copied," of ",InputCountBars);
      return;
     }
//---
   ArraySort(arr_series);
//--- verification
   if(InpVerification)
     {
      string out="";
      string format="open = %G, high = %G, low = %G, close = %G, volume = %d";
      for(int i=0;i<copied;i++)
        {
         out=IntegerToString(i)+":"+TimeToString(rates[i].time);
         out=out+" "+StringFormat(format,
                                  rates[i].open,
                                  rates[i].high,
                                  rates[i].low,
                                  rates[i].close,
                                  rates[i].tick_volume);
         if(rates[i].open<rates[i].close)
            out=out+" "+"Bull";
         else if(rates[i].open>rates[i].close)
            out=out+" "+"Bear";
         Print(out);
        }
      Print("//| arr_series[][0]:    series type                                  |");
      Print("//| arr_series[][1]:    count of series                              |");
      ArrayPrint(arr_series,0);
     }
//---
  
  }
//+------------------------------------------------------------------+
