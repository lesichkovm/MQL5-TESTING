#include<Trade\Trade.mqh>

CTrade trade;

//--input parameters

input int DirectionalPips=10;
input int TakeProfitPips=20;
input int StopLossPips=20;
input double LotSize=0.10;
input int MaximumPositions=10;



void OnTick()
  {
  
  string Trend="";
  string signal="";
  
  double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
  double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  
  //empty array for the prices
  MqlRates PriceInfo[];
  
  ArraySetAsSeries(PriceInfo,true);
  
  int PriceData=CopyRates(_Symbol,_Period,0,10,PriceInfo);
  
  
  //Status of the current to gauge the direction
  
   double Difference= PriceInfo[9].close- PriceInfo[0].close;


  //Trend direction According to the zero reference point
  
  if(Difference>0)
  Trend="Uptrend";
  if(Difference<0)
  Trend="Downtrend";
  
  if(Trend=="Uptrend" && Difference>=DirectionalPips*_Point)
  signal="buy";
  if(Trend=="Downtrend" && Difference<=-DirectionalPips*_Point)
  signal="sell";
  
  
   //Sell and buy conditions met
 if(signal=="sell" && PositionsTotal()<1)
 trade.Sell(LotSize,NULL,Bid,(Bid+TakeProfitPips*_Point),(Bid-StopLossPips*_Point),"Sell condition met");
 
 
 //Buy Condition
 if(signal=="buy" && PositionsTotal()<1)
  trade.Buy(LotSize,NULL,Ask,(Ask+TakeProfitPips*_Point),(Ask-StopLossPips*_Point),"Buy condition met");
  
  //Postions management 
  if(PositionsTotal()<MaximumPositions)
  trade.Close()
     
  }
