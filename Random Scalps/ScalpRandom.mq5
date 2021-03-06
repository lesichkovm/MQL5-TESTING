
#define MAGIC 999

input double rateTP = 1;   //Take Profit Rate
input double rateSL = 10;  //Stop Loss Rate
input double Lots = 1;     //Lots
input uint Spread = 100;    //Spread Filter

enum TYPE_TRADE
{
   TRADE_SELL = 0,
   TRADE_BUY = 1
};

void OnStart()
{
   MqlTradeRequest tReq = {0};
   MqlTradeResult tRes = {0};
   int tType = -1, symIndex, symDigits, symSpread;
   double symPoint;
   string symName;
   MathSrand(GetTickCount());
   symIndex = MathRand() % SymbolsTotal(false);   
   symName = SymbolName(symIndex, false);
   if(SymbolInfoInteger(symName, SYMBOL_SELECT) == false) SymbolSelect(symName, true);
   Sleep(50);
   MathSrand(GetTickCount());
   ZeroMemory(tReq);
   ZeroMemory(tRes);
   symPoint = SymbolInfoDouble(symName, SYMBOL_POINT);
   symDigits = SymbolInfoInteger(symName, SYMBOL_DIGITS);
   symSpread = SymbolInfoInteger(symName, SYMBOL_SPREAD);
   if(symSpread > Spread)
   {
      Print("ERROR: high spread. " + symName);
      return;
   }
   tType = int(MathRand() % 2);
   tReq.symbol = symName;
   tReq.volume = Lots;
   tReq.action = TRADE_ACTION_DEAL;
   tReq.deviation = 5;
   tReq.magic = MAGIC;
   
   switch(tType)
   {
      case TRADE_SELL: 
         tReq.type = ORDER_TYPE_SELL; 
         tReq.price = SymbolInfoDouble(symName, SYMBOL_BID); 
         tReq.tp = tReq.price - NormalizeDouble(symSpread * symPoint * rateTP, symDigits);
         tReq.sl = tReq.price + NormalizeDouble(symSpread * symPoint * rateSL, symDigits);
         break;
      case TRADE_BUY: 
         tReq.type = ORDER_TYPE_BUY; 
         tReq.price = SymbolInfoDouble(symName, SYMBOL_ASK); 
         tReq.tp = tReq.price + NormalizeDouble(symSpread * symPoint * rateTP, symDigits);
         tReq.sl = tReq.price - NormalizeDouble(symSpread * symPoint * rateSL, symDigits);
         break;
      default: Print("ERROR: order type. " + GetLastError()); break;
   }
   
   if(!OrderSend(tReq, tRes))
   {
      Print("ERROR: order send. "+ symName  + " / " + GetLastError());         
      return;      
   }
}

/*This script opens random positions at market price on all marketwatch symbols having spread below specified value. Volume, take-profit and stop-loss levels are determined by user inputs.

USAGE

Right-Click marketwatch and Show All symbols.
Wait symbols to update their bid/ask values.
Open a chart.
Double-Click or Drag-Drop ScalpAll script on a chart.
Enter inputs.
Take-profit and stop-loss levels are calculated by multiplying input values with current spread.
Spread filter neglects symbols having high spread which is unsuitable for scalping.
New positions will be opened by clicking OK.
To close positions use CloseScalps script. To close only profited positions, set close profit positions input to true. otherwise all scalp positions will be closed.

WARNING
Use only on demo account.
Positions of some symbols may not be opened due to market conditions. Check experts tab.
Magic number 999 is unique for this script. Pay attention for conflicts.
Close last position by manually if it's not closed by script.
*/