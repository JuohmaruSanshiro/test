//+------------------------------------------------------------------+
//|                                                EA_AfterWorkX.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include<Trade\Trade.mqh>

CTrade  trade;
int      EA_Magic=12345;   // EA Magic Number

//--- input parameters EURUSD 15M  01/01/12 DD 11.72% ProfitFactor 3.37
//--- input parameters EURUSD 15M  01/01/17 DD 17.00% ProfitFactor 4.36
//--- input parameters EURUSD 15M  01/01/21 DD 17.66% ProfitFactor 3.99

input int      StopLoss=500;        // Stop Loss     420
input int      TakeProfit=130;      // Take Profit   140
input int      TakeProfit2=120;     // Take Profit   130
input int      openBuy=5;          // allow openBuy  12 
input int      openSell=20;         // allow openSell 16

input int      ADX_Period=21;       // ADX Period             23
input int      MA_Period=104;        // Moving Average Period  98
      int      MA2_Period=100;      // MA long Period         100
input double   Adx_Min=53.24;       // Minimum ADX Value      50.82

input double   Lot=0.01;            // Lots to Trade  0.01

input int      prior_bar=2;         // prior bar      2
input int      num_modify=1;        // number modify  1
input double   profit_loss=-8;      // profit loss    10
input double   fix_sl=1100;          // fix stoploss   700
input int      tailing_tp=1100;     // tailing tp     2000
//input double   gap=0.00300;

//--- Other parameters
ulong TicketBuy1;
ulong TicketSell0;
ulong retcode1;
ulong retcode2;
bool send1;
bool send0;
double equity;

int adxHandle;  // handle for our ADX indicator
int maHandle;   // handle for our Moving Average indicator
int ma2Handle;  // handle for RSI indicator
double plusDI[],minusDI[],adxVal[]; // Dynamic arrays to hold the values of +DI, -DI and ADX values for each bars
double maVal[]; // Dynamic array to hold the values of Moving Average for each bars
double ma2Val[];// Dynamic array to hold the values of MA2
double p_close; // Variable to store the close value of a bar
int SL, TP;     // To be used for Stop Loss & Take Profit values
double RL1, SL1, RL2, SL2, RL3, SL3, RL4, SL4, RL5, SL5;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{ 
   //--- Add indicator ***

   //--- Get handle for ADX indicator +DIแนวโน้มแข็งแรง  -DIแนวโน้มอ่อนแรง
   adxHandle = iADX(_Symbol,0,ADX_Period);
   //--- Get the handle for Moving Average indicator
   maHandle = iMA(_Symbol,_Period,MA_Period,0,MODE_EMA,PRICE_CLOSE);
   //--- Get the handle for RSI
   ma2Handle = iMA(_Symbol,_Period,MA2_Period,0,MODE_EMA,PRICE_CLOSE);

   //--- What if handle returns Invalid Handle
   if(adxHandle<0 || maHandle<0 || ma2Handle<0)
   {
      Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
      return(-1);
   }

   //--- Let us handle currency pairs with 5 or 3 digit prices instead of 4
   SL = StopLoss;
   TP = TakeProfit;
   if(_Digits==5 || _Digits==3)
   {
      SL = SL*10;
      TP = TP*10;
   }       
   //---
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);   
   IndicatorRelease(ma2Handle);
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Do we have enough bars to work with
   if(Bars(_Symbol,_Period) < 60) // if total bars is less than 60 bars
   {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
   }  
     
   // We will use the static Old_Time variable to serve the bar time.
   // At each OnTick execution we will check the current bar time with the saved one.
   // If the bar time isn't equal to the saved time, it indicates that we have a new tick.

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar = false;

   // copying the last bar time to the element New_Time[0]
   int copied = CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied > 0) // ok, the data has been copied successfully
   {
      if(Old_Time != New_Time[0]) // if old time isn't equal to new bar time
      {
         IsNewBar = true;   // if it isn't a first call, the new bar has appeared
         if(MQL5InfoInteger(MQL5_DEBUGGING)) 
            Print("We have new bar here ",New_Time[0]," old time was ",Old_Time);
         Old_Time = New_Time[0];  // saving bar time
      }
   }
   else
   {
      Alert("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
      return;
   }

   //--- EA should only check for new trade if we have a new bar
   if(IsNewBar == false)
   {
      return;
   }

   //--- Define some MQL5 Structures we will use for our trade
   MqlTick latest_price;      // To be used for getting recent/latest price quotes
   MqlTradeRequest mrequest;  // To be used for sending our trade requests
   MqlTradeResult mresult;    // To be used to get our trade results
   MqlRates mrate[];          // To be used to store the prices, volumes and spread of each bar
   MqlRates mrateH4[];          // To be used to store the prices, volumes and spread of each bar
   ZeroMemory(mrequest);      // Initialization of mrequest structure

   //--- Let's make sure our arrays values for the Rates, ADX Values and MA values 
   //---  is store serially similar to the timeseries array

   // the rates arrays
   ArraySetAsSeries(mrate,true);
   // the rates arrays
   ArraySetAsSeries(mrateH4,true);
   // the ADX DI+values array
   ArraySetAsSeries(plusDI,true);
   // the ADX DI-values array
   ArraySetAsSeries(minusDI,true);
   // the ADX values arrays
   ArraySetAsSeries(adxVal,true);
   // the MA values arrays
   ArraySetAsSeries(maVal,true);   
   // the RSI values arrays
   ArraySetAsSeries(ma2Val,true);
   
   //--- Get the last price quote using the MQL5 MqlTick Structure
   if(!SymbolInfoTick(_Symbol,latest_price))
   {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
   }

   //--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,mrate) < 0)
   {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return;
   }
   //--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,PERIOD_H4,0,3,mrateH4) < 0)
   {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return;
   }
   
   //--- Copy the new values of our indicators to buffers (arrays) using the handle
   if(CopyBuffer(adxHandle,0,0,3,adxVal)<0 || CopyBuffer(adxHandle,1,0,3,plusDI)<0 || CopyBuffer(adxHandle,2,0,3,minusDI)<0)
   {
      Alert("Error copying ADX indicator Buffers - error:",GetLastError(),"!!");
      ResetLastError();
      return;
   }
   if(CopyBuffer(maHandle,0,0,3,maVal)<0)
   {
      Alert("Error copying Moving Average indicator buffer - error:",GetLastError());
      ResetLastError();
      return;
   }
   if(CopyBuffer(ma2Handle,0,0,3,ma2Val)<0)
   {
      Alert("Error copy MA2 indicator buffer - error:",GetLastError());
      ResetLastError();
      return;
   }   
   //--- we have no errors, so continue
   //--- Do we have positions opened already?
   bool Can_buy = false;  // variable to hold the result of Buy opened position
   bool Can_sell = false; // variables to hold the result of Sell opened position

   //if(PositionSelect(_Symbol) == true) // we have an opened position
   //{
      int count_buy = CountOrderBuy();
      int count_sell = CountOrderSell();
      if(count_buy < openBuy)
      {
         Can_buy=true;  //It is some Buy position
      }
      if(count_sell < openSell)
      {
         Can_sell=true; // It is some Sell position
      }
      //Print("count_buy ",count_buy," Can_buy ",Can_buy," count_sell ",count_sell," Can_sell ",Can_sell);
   //}

   // Copy the bar close price for the previous bar prior to the current bar, that is Bar 1
   p_close = mrate[1].close;  // bar 1 close price    
   int Highest = iHighest(_Symbol,PERIOD_MN1,MODE_HIGH,prior_bar,0); 
   if(Highest == -1)
      PrintFormat("iHighest() call error. Error code=%d",GetLastError());
   int Lowest = iLowest(_Symbol,PERIOD_MN1, MODE_LOW,prior_bar,0);
   if(Lowest == -1)
      PrintFormat("iHighest() call error. Error code=%d",GetLastError());
   double High = iHigh(_Symbol, PERIOD_MN1, prior_bar );
   double Low  =  iLow(_Symbol, PERIOD_MN1, prior_bar );
   //Print("HL=",Highest," ",High," ",Lowest," ",Low);
   
//START////////////////////////////////START////////////////////////////////////////   
   // Case1 pass resistance/support line (confirm) and follow trend, open order1
   // Case2 pass resistance/support line (confirm) but invest trend, open order2
   // Case3 not pass resistance/support line but follow trend, open order3
   // Case4 not pass resistance/support line and invert trend, not order
   // Case5 new resistance line
   // Case6 new support line

   bool Case1 = false;
   bool Case2 = false;
   bool Case3 = false;
   bool Case4 = false;
   bool Case5 = false;
   bool Case6 = false;
   bool up_trend = (maVal[0] > ma2Val[0]) && (maVal[1] > ma2Val[1]); 
   bool down_trend = (maVal[0] < ma2Val[0]) && (maVal[1] < ma2Val[1]); 
   
   // Case1 
   //Print(" m1 ",mrate[1].close," m2 ",mrate[2].close);
   // Pass Resistance Line1, Breakout
   if((mrateH4[2].open > RL1 || mrateH4[2].close > RL1) && mrateH4[1].open > RL1 && mrateH4[1].close > mrateH4[1].open)
   {
      if((mrateH4[2].open > RL2 || mrateH4[2].close > RL2) && mrateH4[1].open > RL2 && mrateH4[1].close > mrateH4[1].open)
      {
         Print("Pass RL2 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," RL2=",RL2);
         RL1 = RL3;
         RL2 = RL4;
         RL3 = NULL;
         RL4 = NULL;    
         RL5 = NULL;
      }
      else 
      { 
         Print("Pass RL1 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," RL1=",RL1);
         RL1 = RL2;  
         RL2 = RL3;
         RL3 = RL4;
         RL4 = RL5;      
         RL5 = NULL;
      }
      if(RL1-mrateH4[1].close > TakeProfit*_Point)// && countSL()>=countRL())// SL3!=NULL)
         Case1 = true;   // Case1   
         
      long cid=ChartID();
      if(!ObjectDelete(cid, "RL1"))
         Print("Error delete object:", GetLastError()); 
      if(!ObjectDelete(cid, "RL2"))
         Print("Error delete object:", GetLastError());               
      if(!ObjectDelete(cid, "RL3"))
         Print("Error delete object:", GetLastError());      
      if(!ObjectCreate(cid, "RL1", OBJ_HLINE, 0, 0, RL1))
         Print("Error create object: ", GetLastError());      
      if(!ObjectCreate(cid, "RL2", OBJ_HLINE, 0, 0, RL2))
         Print("Error create object: ", GetLastError());
      if(!ObjectCreate(cid, "RL3", OBJ_HLINE, 0, 0, RL3))
         Print("Error create object: ", GetLastError());
      //--- set line color 
      ObjectSetInteger(cid,"RL1",OBJPROP_COLOR,clrYellow); 
      ObjectSetInteger(cid,"RL2",OBJPROP_COLOR,clrYellow);      
      ObjectSetInteger(cid,"RL3",OBJPROP_COLOR,clrYellow);  
      ChartRedraw(cid);       
   }
   // Case3
   // Not Pass Resistance Line1
   if((mrateH4[2].open > RL1 || mrateH4[2].close > RL1) && mrateH4[1].open > RL1 && mrateH4[1].close < mrateH4[1].open)
   {
      if((mrateH4[2].open > RL2 || mrateH4[2].close > RL2) && mrateH4[1].open > RL2 && mrateH4[1].close < mrateH4[1].open)
      {
         Print("Not Pass RL2 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," RL2=",RL2);
         RL1 = RL3;  
         RL2 = RL4;
         RL3 = NULL;
         RL4 = NULL;      
         RL5 = NULL;        
      }
      else
      {
         Print("Not Pass RL1 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," RL1=",RL1);
         RL1 = RL2;  
         RL2 = RL3;
         RL3 = RL4;
         RL4 = RL5;         
         RL5 = NULL;        
      }
      if(mrateH4[1].close-SL1 > TakeProfit2*_Point && down_trend)// && countRL()>countSL()) //SL3!=NULL)
         Case3 = true;  // Case3

      long cid=ChartID();
      if(!ObjectDelete(cid, "RL1"))
         Print("Error delete object:", GetLastError()); 
      if(!ObjectDelete(cid, "RL2"))
         Print("Error delete object:", GetLastError());               
      if(!ObjectDelete(cid, "RL3"))
         Print("Error delete object:", GetLastError());      
      if(!ObjectCreate(cid, "RL1", OBJ_HLINE, 0, 0, RL1))
         Print("Error create object: ", GetLastError());      
      if(!ObjectCreate(cid, "RL2", OBJ_HLINE, 0, 0, RL2))
         Print("Error create object: ", GetLastError());
      if(!ObjectCreate(cid, "RL3", OBJ_HLINE, 0, 0, RL3))
         Print("Error create object: ", GetLastError());
      //--- set line color 
      ObjectSetInteger(cid,"RL1",OBJPROP_COLOR,clrYellow); 
      ObjectSetInteger(cid,"RL2",OBJPROP_COLOR,clrYellow);      
      ObjectSetInteger(cid,"RL3",OBJPROP_COLOR,clrYellow);  
      ChartRedraw(cid);        
   }
   // Case5
   // Draw Resistance Line1 and Line2 
   if(mrateH4[2].open < mrateH4[2].close && mrateH4[1].open > mrateH4[1].close)
   {
      Print("mrateH42=", mrateH4[2].close, " mrateH41=", mrateH4[1].open);
      Print("mrateH42=", NormalizeDouble(mrateH4[2].close,4), " mrateH41=", NormalizeDouble(mrateH4[1].open,4));
      //if(NormalizeDouble(mrateH4[2].close,4) == NormalizeDouble(mrateH4[1].open,4))
      if(fabs(mrateH4[2].close-mrateH4[1].open) < 0.00010)   
      {
         RL5 = RL4;
         RL4 = RL3;   
         RL3 = RL2;
         RL2 = RL1;      
         RL1 = NormalizeDouble(mrateH4[1].open,4);
         Print("RL1=",RL1," RL2=",RL2," RL3=",RL3," RL4=",RL4);

         if(SL1 == NULL && down_trend)
            Case5 = true; // Case3
         
         long cid=ChartID();
         if(!ObjectDelete(cid, "RL1"))
            Print("Error delete object:", GetLastError()); 
         if(!ObjectDelete(cid, "RL2"))
            Print("Error delete object:", GetLastError());               
         if(!ObjectDelete(cid, "RL3"))
            Print("Error delete object:", GetLastError());      
         if(!ObjectCreate(cid, "RL1", OBJ_HLINE, 0, 0, RL1))
            Print("Error create object: ", GetLastError());      
         if(!ObjectCreate(cid, "RL2", OBJ_HLINE, 0, 0, RL2))
            Print("Error create object: ", GetLastError());
         if(!ObjectCreate(cid, "RL3", OBJ_HLINE, 0, 0, RL3))
            Print("Error create object: ", GetLastError());
         //--- set line color 
         ObjectSetInteger(cid,"RL1",OBJPROP_COLOR,clrYellow); 
         ObjectSetInteger(cid,"RL2",OBJPROP_COLOR,clrYellow);      
         ObjectSetInteger(cid,"RL3",OBJPROP_COLOR,clrYellow);  
         ChartRedraw(cid);   
      }
    
   }
/////////////////////////////////////////////////////////////////////////////////////   
   // Case2
   // Pass Support Line1, Breakout
   if((mrateH4[2].open < SL1 || mrateH4[2].close < SL1) && mrateH4[1].open < SL1 && mrateH4[1].open > mrateH4[1].close)
   { 
      if((mrateH4[2].open < SL2 || mrateH4[2].close < SL2) && mrateH4[1].open < SL2 && mrateH4[1].open > mrateH4[1].close)
      { 
         Print("Pass SL2 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," SL2=",SL2);
         SL1 = SL3;
         SL2 = SL4;
         SL3 = NULL;
         SL4 = NULL;
         SL5 = NULL;
      }
      else
      {
         Print("Pass SL1 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," SL1=",SL1);
         SL1 = SL2;
         SL2 = SL3;
         SL3 = SL4;
         SL4 = SL5;      
         SL5 = NULL;
      }
      if(mrateH4[1].close-SL1 > TakeProfit*_Point)// && countRL()>=countSL())// RL3!=NULL)
         Case2 = true;  // Case2

      long cid=ChartID();
      if(!ObjectDelete(cid, "SL1"))
         Print("Error delete object:", GetLastError()); 
      if(!ObjectDelete(cid, "SL2"))
         Print("Error delete object:", GetLastError());               
      if(!ObjectDelete(cid, "SL3"))
         Print("Error delete object:", GetLastError());      
      if(!ObjectCreate(cid, "SL1", OBJ_HLINE, 0, 0, SL1))
         Print("Error create object: ", GetLastError());      
      if(!ObjectCreate(cid, "SL2", OBJ_HLINE, 0, 0, SL2))
         Print("Error create object: ", GetLastError());
      if(!ObjectCreate(cid, "SL3", OBJ_HLINE, 0, 0, SL3))
         Print("Error create object: ", GetLastError());
      //--- set line color 
      ObjectSetInteger(cid,"SL1",OBJPROP_COLOR,clrMagenta); 
      ObjectSetInteger(cid,"SL2",OBJPROP_COLOR,clrMagenta);      
      ObjectSetInteger(cid,"SL3",OBJPROP_COLOR,clrMagenta);  
      ChartRedraw(cid);  
   }
   // Case4
   // Not Pass Support Line1
   if((mrateH4[2].open < SL1 || mrateH4[2].close < SL1) && mrateH4[1].open < SL1 && mrateH4[1].open < mrateH4[1].close )
   {
      if((mrateH4[2].open < SL2 || mrateH4[2].close < SL2) && mrateH4[1].open < SL2 && mrateH4[1].open < mrateH4[1].close )
      {
         Print("Not Pass SL2 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," SL2=",SL2);
         SL1 = SL3;
         SL2 = SL4;
         SL3 = NULL;
         SL4 = NULL;     
         SL5 = NULL;   
      }
      else
      {
         Print("Not Pass SL1 m2.close=",mrateH4[2].close," m1.close=",mrateH4[1].close," SL1=",SL1);
         SL1 = SL2;
         SL2 = SL3;
         SL3 = SL4;
         SL4 = SL5;      
         SL5 = NULL;   
      }
      if(RL1-mrateH4[1].close > TakeProfit2*_Point && up_trend)// && countSL()>countRL())// RL3!=NULL)
         Case4 = true;  // case4

      long cid=ChartID();
      if(!ObjectDelete(cid, "SL1"))
         Print("Error delete object:", GetLastError()); 
      if(!ObjectDelete(cid, "SL2"))
         Print("Error delete object:", GetLastError());               
      if(!ObjectDelete(cid, "SL3"))
         Print("Error delete object:", GetLastError());      
      if(!ObjectCreate(cid, "SL1", OBJ_HLINE, 0, 0, SL1))
         Print("Error create object: ", GetLastError());      
      if(!ObjectCreate(cid, "SL2", OBJ_HLINE, 0, 0, SL2))
         Print("Error create object: ", GetLastError());
      if(!ObjectCreate(cid, "SL3", OBJ_HLINE, 0, 0, SL3))
         Print("Error create object: ", GetLastError());
      //--- set line color 
      ObjectSetInteger(cid,"SL1",OBJPROP_COLOR,clrMagenta); 
      ObjectSetInteger(cid,"SL2",OBJPROP_COLOR,clrMagenta);      
      ObjectSetInteger(cid,"SL3",OBJPROP_COLOR,clrMagenta);  
      ChartRedraw(cid);             
   }
   // Case6
   // Draw Support Line1 and Line2
   if(mrateH4[2].open > mrateH4[2].close && mrateH4[1].open < mrateH4[1].close)
   {
      Print("mrateH42=", mrateH4[2].close, " mrateH41=", mrateH4[1].open);
      Print("mrateH42=", NormalizeDouble(mrateH4[2].close,4), " mrateH41=", NormalizeDouble(mrateH4[1].open,4));
      //if(NormalizeDouble(mrateH4[2].close,4) == NormalizeDouble(mrateH4[1].open,4))
      if(fabs(mrateH4[2].close-mrateH4[1].open) < 0.00010)     
      {
         SL5 = SL4;
         SL4 = SL3;   
         SL3 = SL2;
         SL2 = SL1;
         SL1 = NormalizeDouble(mrateH4[1].open,4);
         Print("SL1=",SL1," SL2=",SL2," SL3=",SL3," SL4=",SL4); 

         if(RL1 == NULL && up_trend)
            Case6 = true; // Case6

         long cid=ChartID();
         if(!ObjectDelete(cid, "SL1"))
            Print("Error delete object:", GetLastError()); 
         if(!ObjectDelete(cid, "SL2"))
            Print("Error delete object:", GetLastError());               
         if(!ObjectDelete(cid, "SL3"))
            Print("Error delete object:", GetLastError());      
         if(!ObjectCreate(cid, "SL1", OBJ_HLINE, 0, 0, SL1))
            Print("Error create object: ", GetLastError());      
         if(!ObjectCreate(cid, "SL2", OBJ_HLINE, 0, 0, SL2))
            Print("Error create object: ", GetLastError());
         if(!ObjectCreate(cid, "SL3", OBJ_HLINE, 0, 0, SL3))
            Print("Error create object: ", GetLastError());
         //--- set line color 
         ObjectSetInteger(cid,"SL1",OBJPROP_COLOR,clrMagenta); 
         ObjectSetInteger(cid,"SL2",OBJPROP_COLOR,clrMagenta);      
         ObjectSetInteger(cid,"SL3",OBJPROP_COLOR,clrMagenta);  
         ChartRedraw(cid);      

      }     
   }
//END//////////////////////////END///////////////////////////////////////   
   
   
   
   
   /*
       1. Check for a long/Buy Setup : MA-8 increasing upwards, 
       previous price close above it, ADX > 22, +DI > -DI
   */ 
   //--- Declare bool type variables to hold our Buy Conditions
   bool Buy_Condition_1 = (maVal[0] > maVal[1]) && (maVal[1] > maVal[2]); // MA-8 Increasing upwards
   bool Buy_Condition_2 = (p_close > maVal[1]);         // previuos price closed above MA-8
   bool Buy_Condition_3 = (adxVal[0] > Adx_Min);        // Current ADX value greater than minimum value (22)
   bool Buy_Condition_4 = (plusDI[0] > minusDI[0]);     // +DI greater than -DI
   bool Buy_Condition_5 = (iHigh(_Symbol,_Period,1) > iHigh(_Symbol,_Period,2));
   bool Buy_Condition_6 = (latest_price.ask < High);
   //bool Buy_Condition_6 = (ma2Val[0] > ma2Val[1]) && (ma2Val[1] > ma2Val[2]);
   //bool Buy_Condition_7 = (AccountInfoDouble(ACCOUNT_EQUITY)-AccountInfoDouble(ACCOUNT_BALANCE)) < -dd_buy;
   bool Buy_Condition_8 = (AccountInfoDouble(ACCOUNT_EQUITY)*100/AccountInfoDouble(ACCOUNT_BALANCE) > 90);
   bool Buy_Condition_9 = (AccountInfoDouble(ACCOUNT_EQUITY)*100/AccountInfoDouble(ACCOUNT_BALANCE) < 80);

   //--- Putting all together   
   //---------Logic Entry Buy1
   if((Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4 
   && Buy_Condition_5 && Buy_Condition_8 && Buy_Condition_6 && Can_buy))
   {
         // any opened Buy position?
         if(Can_buy)
         {
            //Print("We already have enough Buy Position!!!");
            //return;    // Don't open a new Buy Position
         } 
         //----------False Signal Protection ***

         //----------------------------------       
         //----------Calculate Equity Risk **********
         equity = AccountInfoDouble(ACCOUNT_EQUITY);
         double lot = NormalizeDouble(equity/200000,2);
         if(lot < Lot) 
           lot = Lot;
         //-----------------------------------   
         ZeroMemory(mrequest);
         mrequest.action = TRADE_ACTION_DEAL;                                   // immediate order execution
         mrequest.price = NormalizeDouble(latest_price.ask,_Digits);            // latest ask price
         mrequest.sl = NormalizeDouble(latest_price.ask - SL * _Point,_Digits); // Stop Loss            
         if(up_trend && RL3 != NULL)
            mrequest.tp = RL3;
         if(down_trend && RL1 != NULL)
            mrequest.tp = RL1;
         else           
            mrequest.tp = NormalizeDouble(latest_price.ask + TP * _Point,_Digits); // Take Profit             
         mrequest.symbol = _Symbol;                                             // currency pair
         mrequest.volume = lot;                                                 // number of lots to trade
         mrequest.magic = EA_Magic;                                             // Order Magic Number
         mrequest.type = ORDER_TYPE_BUY;                                        // Buy Order
         mrequest.type_filling = ORDER_FILLING_IOC;                             // Order execution type
         mrequest.deviation=100;                                                // Deviation from current price
         //--- send order
         //send1=OrderSend(mrequest,mresult);
         send1=trade.PositionOpen(mrequest.symbol,mrequest.type,mrequest.volume,mrequest.price,mrequest.sl,mrequest.tp);
         TicketBuy1 = trade.ResultDeal();
         retcode1 = trade.ResultRetcode();
         // get the result code
         //if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
         if(retcode1==10009 || retcode1==10008) //Request is completed or order placed
         {
            Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
            CloseSell();
         }
         else
         {
            Alert("The Buy order request could not be completed -error:",GetLastError());
            ResetLastError();           
            return;
         }
   } 
   //--------------------------------------
  
   /*
       2. Check for a Short/Sell Setup : MA-8 decreasing downwards, 
       previous price close below it, ADX > 22, -DI > +DI
   */

   //--- Declare bool type variables to hold our Sell Conditions
   bool Sell_Condition_1 = (maVal[0] < maVal[1]) && (maVal[1] < maVal[2]);  // MA-8 decreasing downwards
   bool Sell_Condition_2 = (p_close < maVal[1]);          // Previous price closed below MA-8
   bool Sell_Condition_3 = (adxVal[0] > Adx_Min);         // Current ADX value greater than minimum (22)
   bool Sell_Condition_4 = (plusDI[0] < minusDI[0]);      // -DI greater than +DI
   bool Sell_Condition_5 = (iLow(_Symbol,_Period,1) < iLow(_Symbol,_Period,2));
   bool Sell_Condition_6 = (latest_price.bid > Low);
   //bool Sell_Condition_6 = (ma2Val[0] < ma2Val[1]) && (ma2Val[1] < ma2Val[2]);
   //bool Sell_Condition_7 = (AccountInfoDouble(ACCOUNT_EQUITY)-AccountInfoDouble(ACCOUNT_BALANCE)) < -dd_sell;
   bool Sell_Condition_8 = (AccountInfoDouble(ACCOUNT_EQUITY)*100/AccountInfoDouble(ACCOUNT_BALANCE) > 90);
   bool Sell_Condition_9 = (AccountInfoDouble(ACCOUNT_EQUITY)*100/AccountInfoDouble(ACCOUNT_BALANCE) < 80);

   //--- Putting all together
   if((Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4 
   && Sell_Condition_5 && Sell_Condition_8 && Sell_Condition_6 && Can_sell))
   {    
         // any opened Sell position?
         if(Can_sell)
         {
            //Print("We already have enough Sell position!!!");
            //return;    // Don't open a new Sell Position
         }       
         //----------False Signal Protection ***

         //----------------------------------       
         //----------Calculate Equity, Drawdown Risk **********
         equity = AccountInfoDouble(ACCOUNT_EQUITY);
         double lot = NormalizeDouble(equity/200000,2);
         if(lot < Lot) 
            lot = Lot;
         //-----------------------------------  
         ZeroMemory(mrequest);
         mrequest.action=TRADE_ACTION_DEAL;                                     // immediate order execution
         mrequest.price = NormalizeDouble(latest_price.bid,_Digits);            // latest Bid price
         mrequest.sl = NormalizeDouble(latest_price.bid + SL * _Point,_Digits); // Stop Loss   
         if(down_trend && SL3 != NULL)
            mrequest.tp = SL3;    
         if(down_trend && SL1 != NULL)
            mrequest.tp = SL1;                
         else
            mrequest.tp = NormalizeDouble(latest_price.bid - TP * _Point,_Digits); // Take Profit         
         mrequest.symbol = _Symbol;                                             // currency pair
         mrequest.volume = lot;                                                 // number of lots to trade
         mrequest.magic = EA_Magic;                                             // Order Magic Number
         mrequest.type= ORDER_TYPE_SELL;                                        // Sell Order
         mrequest.type_filling = ORDER_FILLING_IOC;                             // Order execution type
         mrequest.deviation=100;                                                // Deviation from current price
         //--- send order
         //send0=OrderSend(mrequest,mresult);
         send0=trade.PositionOpen(mrequest.symbol,mrequest.type,mrequest.volume,mrequest.price,mrequest.sl,mrequest.tp);
         TicketSell0 = trade.ResultDeal();
         retcode1 = trade.ResultRetcode();
         // get the result code
         if(retcode1==10009 || retcode1==10008) //Request is completed or order placed
         {
            Alert("A Sell order has been successfully placed with Ticket#:",mresult.order,"!!");
            CloseBuy();
         }
         else
         {
            Alert("The Sell order request could not be completed -error:",GetLastError());
            ResetLastError();
            return;
         }
   }    

   
   //---------Logic Exit Buy1
/*   
   if(Case3)
   {
      CloseBuy();
   } 
*/   
   //----------Modify SL, TP, Trailing stop
/*   
   if(Buy_Condition_5)
   {
       double sl = NormalizeDouble(latest_price.ask - SL*_Point,_Digits);
       double tp = NormalizeDouble(latest_price.ask + TP*_Point,_Digits);
       trade.PositionModify(TicketBuy1, sl, tp);
   }  
*/ 
   if((Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_5))
   {
      double sl = NormalizeDouble(latest_price.bid - SL*_Point,_Digits);
      double tp = NormalizeDouble(latest_price.bid + TP*_Point,_Digits);         

      if(SL1==NULL)
         sl = NormalizeDouble(latest_price.ask - SL * _Point,_Digits); // Stop Loss    
      else
         sl = SL1;          

      if(RL1==NULL)
         tp = NormalizeDouble(latest_price.ask + TP * _Point,_Digits); // Take Profit         
      else if(up_trend)
         tp = RL2;  // follow trend
      else
         tp = RL1;  // invert trend

      for(int i=0;i<num_modify && i<=PositionsTotal()-1;i++)
      {
         ulong tb = PositionGetTicket(i);
         double psl = PositionGetDouble(POSITION_SL);
         double ptp = PositionGetDouble(POSITION_TP);
         //Print("modify ",PositionGetDouble(POSITION_SL)," ",PositionGetDouble(POSITION_PROFIT)," ",sl-gap);
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetDouble(POSITION_PROFIT)<profit_loss)
         //&& sl-gap < PositionGetDouble(POSITION_SL) && PositionGetSymbol(i)==_Symbol )
         {      
            //retcode2 = trade.PositionModify(tb,latest_price.bid-fix_sl*_Point,tp);
            retcode2 = trade.PositionModify(tb,sl,tp);
            if(retcode2) //Request is completed or order placed
            {
               Print("modify success");
            }
            else
            {
               Print("modify error:",GetLastError());
               ResetLastError();
               return;
            }
         }
      }
      TrailingStop(tailing_tp);
   }
   
   //-----------------------   
   
   //---------Logic Exit Sell0
/*  
   if(Case4)
   {
      CloseSell();
   }  
*/   
   //----------Modify SL, TP, Trailing stop
/*   
   if(Sell_Condition_5)
   {
       double sl = NormalizeDouble(latest_price.bid + SL*_Point,_Digits);
       double tp = NormalizeDouble(latest_price.bid - TP*_Point,_Digits);
       trade.PositionModify(TicketSell0,sl,tp);
   }
*/
   if((Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_5))
   {
      double sl = NormalizeDouble(latest_price.ask + SL*_Point,_Digits);
      double tp = NormalizeDouble(latest_price.ask - TP*_Point,_Digits);         

      if(RL1==NULL)
         sl = NormalizeDouble(latest_price.bid + SL * _Point,_Digits); // Stop Loss
      else
         sl = RL1;     

      if(SL1==NULL)
         tp = NormalizeDouble(latest_price.bid - TP * _Point,_Digits); // Take Profit         
      else if(down_trend)
         tp = SL2;  // follow trend
      else
         tp = SL1;  // invert trend      
            
      for(int i=0;i<num_modify && i<=PositionsTotal()-1;i++)
      {
         ulong ts = PositionGetTicket(i);
         double psl = PositionGetDouble(POSITION_SL);
         double ptp = PositionGetDouble(POSITION_TP);         
         //Print("modify ",PositionGetDouble(POSITION_SL)," ",PositionGetDouble(POSITION_PROFIT)," ",sl+gap);
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetDouble(POSITION_PROFIT)<profit_loss)
         //&& sl+gap > PositionGetDouble(POSITION_SL) && PositionGetSymbol(i)==_Symbol)          
         {
            //retcode2 = trade.PositionModify(ts,latest_price.ask+fix_sl*_Point,tp);
            retcode2 = trade.PositionModify(ts,sl,tp);
            if(retcode2) //Request is completed or order placed
            {
               Print("modify success");
            }
            else
            {
               Print("modify error:",GetLastError());
               ResetLastError();
               return;
            }
         }
      }
      TrailingStop(tailing_tp);
   }

   //TrailingStop(tailing_tp);
   //--------------------------     
   //------------------------------------
   return;   
}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
   //---
   double ret=0.0;
   //---

   //---
   return(ret);   
}
//+------------------------------------------------------------------+

void TrailingStop(int tl)
{
   CTrade cEATrade;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {     
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      PositionSelectByTicket(PositionGetTicket(i));
      if(PositionGetSymbol(i) == _Symbol)
      {
         {
            double a = PositionGetDouble(POSITION_SL);
            double b = bid+tl*_Point;
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && (ask-tl*_Point > PositionGetDouble(POSITION_SL) 
            || PositionGetDouble(POSITION_SL) == 0 ))
            {
               cEATrade.PositionModify(_Symbol, ask-tl*_Point, 0);
            }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && (bid+tl*_Point < PositionGetDouble(POSITION_SL) 
            || PositionGetDouble(POSITION_SL) == 0 ))
            {
               cEATrade.PositionModify(_Symbol, bid+tl*_Point, 0);
            } 
         }
      }
   }   
}

int CountOrder()
{
   int Count=0;
   int i=PositionsTotal()-1;
   for(;i>=0;i--)
   {
       PositionSelectByTicket(PositionGetTicket(i));
       if( PositionGetSymbol(i)==_Symbol)
       Count++;
   }
   return(Count);
}

int CountOrderBuy()
{
   int Count=0;
   int i=PositionsTotal()-1;
   for(;i>=0;i--)
   {
       PositionSelectByTicket(PositionGetTicket(i));
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetSymbol(i)==_Symbol)
       Count++;
   }
   return(Count);
}

int CountOrderSell()
{
   int Count=0;
   int i=PositionsTotal()-1;
   for(;i>=0;i--)
   {
       PositionSelectByTicket(PositionGetTicket(i));
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetSymbol(i)==_Symbol)
       Count++;
   }
   return(Count);
}

void CloseBuy()
{
   CTrade cEATrade;
   int i=PositionsTotal()-1;
   for(;i>=0;i--)
   {
       PositionSelectByTicket(PositionGetTicket(i));
       if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetSymbol(i)==_Symbol)
       cEATrade.PositionClose(PositionGetTicket(i));
   }
}
void CloseSell()
{
   CTrade cEATrade;  
   int i=PositionsTotal()-1;
   for(;i>=0;i--)
   {
      PositionSelectByTicket(PositionGetTicket(i));
      if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetSymbol(i)==_Symbol)
      cEATrade.PositionClose(PositionGetTicket(i));
   }
}
void CloseLast()
{
   CTrade cEATrade;
   cEATrade.PositionClose(PositionGetTicket(PositionsTotal()-1));
}