
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

//Declaration
CPositionInfo     myPosition;  
CSymbolInfo mySymbol;
CAccountInfo myAccount;
CHistoryOrderInfo myHistoryOrderInfo;
CTrade myTrade;
CDealInfo myDealInfo;

//User input parameters
static double tradeLots=1;
static double lastMinutePrice=0;
static double mvLastMinutePrice=0;//Moving Average
static int mvTimes=25;
static int compareStatus=0;
static int TRADE_SIGNAL_BUY=1;
static int TRADE_SIGNAL_SELL=0;
static int TRADE_SIGNAL_NONE=-1;
static int SAVING_TIME=0;
static double LOSS_MAX=-7;//
static int start_wait_minute =0;
bool INIT_SIGNAL =false;
bool SLEEP_SIGNAL =false;
int timeMinuteCount =0;
//+----------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   bool check=checkInitTrade();
   if(!check)
     {  
      printf("NOT FOUND");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   int type=110;
    bool close = true;
  
  if(timeMinuteCount >=start_wait_minute){ 
   if(!INIT_SIGNAL){
    initStart();
    INIT_SIGNAL = true;
   }
   if(INIT_SIGNAL){
   double minuteProfit = getEveryMinuteProfit();
  
    if(minuteProfit <=LOSS_MAX ){
       ulong ticket=PositionGetTicket(0);
       myTrade.PositionClose(ticket,0); 
       printf("CLOSE POSITION"+DoubleToString(minuteProfit,5));
     close = false;
    }
   if(close){
     int status=getChangeStatus();
   if(status==1 || status==0)
     {
      type=openPosition(status);
     }
   }  
  }
}
 priceChange();
   if(type==120 || !close)
     {
    
     }
}
//+------------------------------------------------------------------+
int  openPosition(int status)
  {
   bool isHavePosition=PositionSelect(_Symbol);
   int changeStatus=status;
   if(!isHavePosition)
     {
      if(changeStatus==1)
        {
         myTrade.Buy(tradeLots,_Symbol);
         printf("买入成功:"+TimeToString(TimeCurrent(),TIME_MINUTES));
           }else if(changeStatus==0){
         myTrade.Sell(tradeLots,_Symbol);
         printf("卖空成功:"+TimeToString(TimeCurrent(),TIME_MINUTES));
           }else if(changeStatus==-1){
       //  printf("没有出现交叉");
           } else{
         printf("数据异常");
        }
        } else{//手中有一仓，坐等平仓了 先计算利润 
      double positionProfit=getPositionProfit();
      if(positionProfit>=10)
        {
         ulong ticket=PositionGetTicket(0);
         myTrade.PositionClose(ticket);
         printf("平仓成功,利润为："+DoubleToString(positionProfit,5));
         return 120;//平仓之后休息一下
        }
     }
   return 110;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPositionProfit()
  {
   int total=PositionsTotal();
   if(total>=1)
     {
      ulong ticket=PositionGetTicket(0);
      myPosition.SelectByTicket(ticket);
   //  double  moneyTotal=myPosition.Volume() *myPosition.PriceOpen()*1000;//这一仓花费的金额
      return myPosition.Profit();
        }else{
      return 0;
     }
//printf("proficPercent:"+profit/100);
  }
//检查当前是否可以交易（仅仅用在初始化的时候）
bool checkInitTrade()
  {
//查看当前交易品种
   if(!mySymbol.Name("EURUSD"))
     {
      printf("当前品种不是EURUSD,不进行交易！！！");
      return false;
     }
//查看当前账号
//long  accountId = 7345113 ;
   long  accountId=7345113;
   if(!myAccount.Login()==accountId)
     {
      printf("当前登录账号不对,不能进行交易！！！");
  //    return false;
     }
//查看当前交易模式
   if(!myAccount.TradeMode()==ACCOUNT_TRADE_MODE_DEMO)
     {
      printf("当前账号交易模式不是模拟账户,不进行交易！！！");
      return false;
     }
  if(!myAccount.TradeAllowed() || !myAccount.TradeExpert() || !mySymbol.IsSynchronized())
     {
      printf("账户异常,不能交易！！！");
      return false;
     }
   int ordersTotal=OrdersTotal();//当前挂单量
   if(ordersTotal>0)
     {
      printf("当前账户有未完成的订单，不能继续交易！！");
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//初始化数据 在初始化的时候调用
void initStart()
  {
//实时价格
   int nowMinutePrice=iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE);
//每分钟 mvTimes 均线
   int mvMinutePrice=iMA(Symbol(),PERIOD_M1,mvTimes,0,MODE_SMA,PRICE_CLOSE);
   double mvMinutePriceList[];//分钟价格
   double nowMinutePriceList[];//时时价格
   ArraySetAsSeries(mvMinutePriceList,true);
   ArraySetAsSeries(nowMinutePriceList,true);
   CopyBuffer(mvMinutePrice,0,0,2,mvMinutePriceList);
   CopyBuffer(nowMinutePrice,0,0,2,nowMinutePriceList);
//1为 上一分钟价格  0 为时时价格
   mvLastMinutePrice= mvMinutePriceList[1];
   lastMinutePrice = nowMinutePriceList[1];                                 
 
  }
int getChangeStatus()
  {

   int iMAPriceIndex=iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE);
   double nowPriceList[];
   ArraySetAsSeries(nowPriceList,true);
   CopyBuffer(iMAPriceIndex,0,0,2,nowPriceList);
   double nowPrice=nowPriceList[1];
   int iMA25PriceIndex=iMA(Symbol(),PERIOD_M1,mvTimes,0,MODE_SMA,PRICE_CLOSE);
   double mvNowPriceList[];
   ArraySetAsSeries(mvNowPriceList,true);
   CopyBuffer(iMA25PriceIndex,0,0,2,mvNowPriceList);
   double mvNowPrice=mvNowPriceList[1];
// printf("lastMinutePrice:"+lastMinutePrice);
// printf("nowPrice:"+nowPrice);
   if(lastMinutePrice!=nowPrice && mvLastMinutePrice!=mvNowPrice)
     {
      if(((lastMinutePrice-mvLastMinutePrice>0) && (nowPrice-mvNowPrice<0)) || ((lastMinutePrice-mvLastMinutePrice)<0 && (nowPrice-mvNowPrice)>0))
        {
         
         if(nowPrice-mvNowPrice>0)
           {
           
            return TRADE_SIGNAL_BUY;
              }else if(nowPrice<mvNowPrice){
             
            return TRADE_SIGNAL_SELL;
           }
           }else{
         
         return TRADE_SIGNAL_NONE;
        }
     }
   return TRADE_SIGNAL_NONE;
  }

void priceChange()
  {
   int iMAPriceIndex=iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE);
   double nowPriceList[];
   ArraySetAsSeries(nowPriceList,true);
   CopyBuffer(iMAPriceIndex,0,0,2,nowPriceList);
   double nowPrice=nowPriceList[1];

   int iMA25PriceIndex=iMA(Symbol(),PERIOD_M1,mvTimes,0,MODE_SMA,PRICE_CLOSE);
   double mvNowPriceList[];
   ArraySetAsSeries(mvNowPriceList,true);
   CopyBuffer(iMA25PriceIndex,0,0,2,mvNowPriceList);
   double mvNowPrice=mvNowPriceList[1];
//printf("nowPrice:"+nowPrice);
//printf("mvNowPrice:"+mvNowPrice);
   if(mvNowPrice!=mvLastMinutePrice && lastMinutePrice!=nowPrice)
     {
      timeMinuteCount++;
    
      lastMinutePrice=nowPrice;
      mvLastMinutePrice=mvNowPrice;
      
     }
  }

double   getEveryMinuteProfit()
  {
  double minuteProfit = 0;
/
   int iMAPriceIndex=iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE);
   double nowPriceList[];
   ArraySetAsSeries(nowPriceList,true);
   CopyBuffer(iMAPriceIndex,0,0,2,nowPriceList);
   double nowPrice=nowPriceList[1];
   int iMA25PriceIndex=iMA(Symbol(),PERIOD_M1,25,0,MODE_SMA,PRICE_CLOSE);
   double mvNowPriceList[];
   ArraySetAsSeries(mvNowPriceList,true);
   CopyBuffer(iMA25PriceIndex,0,0,2,mvNowPriceList);
   double mvNowPrice=mvNowPriceList[1];
   if(mvNowPrice!=mvLastMinutePrice && lastMinutePrice!=nowPrice)
     {
    return getPositionProfit();
      }   
     return minuteProfit;
 }