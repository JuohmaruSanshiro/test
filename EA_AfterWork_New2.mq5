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

//--- input parameters GOLD 4H  01/01/12 DD 13.11% ProfitFactor 4.51
//--- input parameters GOLD 4H  01/01/17 DD 14.71% ProfitFactor 4.96
//--- input parameters GOLD 4H  01/01/21 DD 16.56% ProfitFactor 8.45
/*
input int      StopLoss=290;        
input int      TakeProfit=1830;      
input int      TakeProfit2=760;      
input int      MA_Period=25;       
input int      MA2_Period=39;      
input int      prior_bar=5;        
*/
//--- input parameters EURUSD 4H  01/01/12 DD 10.38% ProfitFactor 1.35
//--- input parameters EURUSD 4H  01/01/17 DD 6.31% ProfitFactor 1.79
//--- input parameters EURUSD 4H  01/01/21 DD 4.25% ProfitFactor 1.57   
input int      StopLoss=85;        
input int      TakeProfit=95;      
input int      TakeProfit2=85;      
input int      MA_Period=11;       
input int      MA2_Period=23;      
input int      prior_bar=4;         


input double   Lot=0.01;            

//--- Other parameters
ulong TicketBuy1;
ulong TicketSell0;
ulong retcode1;
ulong retcode2;
bool send1;
bool send0;
double equity;

int maHandle;   // handle for our Moving Average indicator
int ma2Handle;  // handle for RSI indicator
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
   maHandle = iMA(_Symbol,PERIOD_D1,MA_Period,0,MODE_EMA,PRICE_CLOSE);
   //--- Get the handle for RSI
   ma2Handle = iMA(_Symbol,PERIOD_D1,MA2_Period,0,MODE_EMA,PRICE_CLOSE);

   //--- Let us handle currency pairs with 5 or 3 digit prices instead of 4
   SL = StopLoss;
   TP = TakeProfit;
   if(_Digits==5 || _Digits==3)
   {
      SL = SL*10;
      TP = TP*10;
   }   
   if(_Digits==2)
   {
      SL = SL*100;
      TP = TP*100;
   }       
   //---
   MqlRates mprice[];          // To be used to store the prices, volumes and spread of each bar   
   //--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,PERIOD_H4,0,31,mprice) < 0)
   {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return(-1);
   }   
   Print("Size ",ArraySize(mprice));
   Print(" 30 ",mprice[30].close," 29 ",mprice[29].close," 2 ",mprice[2].close," 1 ",mprice[1].close);
   for(int i=1; i<29; i++)
   {
      if((mprice[i].open > RL2 || mprice[i].close > RL2) && mprice[i+1].open > RL2 && RL2 != NULL)
      {
         Print("Pass RL2 m2.close=",mprice[i].close," m1.close=",mprice[i+1].close," RL1=",RL1);
         RL1 = RL3;
         RL2 = RL4;
         RL3 = NULL;
         RL4 = NULL;
         RL5 = NULL;
         Print("RL1=",RL1," RL2=",RL2," RL3=",RL3," RL4=",RL4);   
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
      if((mprice[i].open > RL1 || mprice[i].close > RL1) && mprice[i+1].open > RL1 && RL1 != NULL)
      {
         Print("Pass RL1 m2.close=",mprice[i].close," m1.close=",mprice[i+1].close," RL1=",RL1);
         RL1 = RL2;  
         RL2 = RL3;
         RL3 = RL4;
         RL4 = RL5;
         RL5 = NULL;
         Print("RL1=",RL1," RL2=",RL2," RL3=",RL3," RL4=",RL4);   
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
      if(mprice[i].close > mprice[i].open && mprice[i+1].close < mprice[i+1].open)
      {
         Print("mprice2=", mprice[i].close, " mprice1=", mprice[i+1].open);
         Print("mprice2=", NormalizeDouble(mprice[i].close,4), " mprice1=", NormalizeDouble(mprice[i+1].open,4));
         //if(NormalizeDouble(mprice[i+1].open,4) == NormalizeDouble(mprice[i].close,4))
         if(fabs(mprice[i+1].open-mprice[i].close) < 10*_Point)
         {
            RL5 = RL4;
            RL4 = RL3;   
            RL3 = RL2;
            RL2 = RL1;      
            RL1 = NormalizeDouble(mprice[i+1].open,4);
            Print("RL1=",RL1," RL2=",RL2," RL3=",RL3," RL4=",RL4);

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

      if((mprice[i].open < SL2 || mprice[i].close < SL2) && mprice[i+1].open < SL2 && SL2 != NULL)
      { 
         SL1 = SL3;
         SL2 = SL4;
         SL3 = NULL;      
         SL4 = NULL;   
         SL5 = NULL;
         Print("SL1=",SL1," SL2=",SL2," SL3=",SL3," SL4=",SL4);
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
      if((mprice[i].open < SL1 || mprice[i].close < SL1) && mprice[i+1].open < SL1 && SL1 != NULL)
      { 
         Print("Pass Support m2.close=",mprice[i].close," m1.close=",mprice[i+1].close," SL1=",SL1);
         SL1 = SL2;
         SL2 = SL3;
         SL3 = SL4;
         SL4 = SL5;    
         SL5 = NULL;  
         Print("SL1=",SL1," SL2=",SL2," SL3=",SL3," SL4=",SL4);

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
      if(mprice[i].close < mprice[i].open && mprice[i+1].close > mprice[i+1].open)
      {
         Print("mprice2=", mprice[i].close, " mprice1=", mprice[i+1].open);
         Print("mprice2=", NormalizeDouble(mprice[i].close,4), " mprice1=", NormalizeDouble(mprice[i+1].open,4));
         //if(NormalizeDouble(mprice[i+1].open,4) == NormalizeDouble(mprice[i].close,4))
         if(fabs(mprice[i+1].open-mprice[i].close) < 10*_Point)
         {
            SL5 = SL4;
            SL4 = SL3;   
            SL3 = SL2;
            SL2 = SL1;
            SL1 = NormalizeDouble(mprice[i+1].open,4);
            Print("SL1=",SL1," SL2=",SL2," SL3=",SL3," SL4=",SL4); 
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
      
   }    
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---
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
   ZeroMemory(mrequest);      // Initialization of mrequest structure

   //--- Let's make sure our arrays values for the Rates, ADX Values and MA values 
   //---  is store serially similar to the timeseries array

   // the rates arrays
   ArraySetAsSeries(mrate,true);
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
   if(CopyRates(_Symbol,PERIOD_H4,0,3,mrate) < 0)
   {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return;
   }

   //--- Copy the new values of our indicators to buffers (arrays) using the handle
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
   bool Buy_opened = false;  // variable to hold the result of Buy opened position
   bool Sell_opened = false; // variables to hold the result of Sell opened position

   // Copy the bar close price for the previous bar prior to the current bar, that is Bar 1
   p_close = mrate[1].close;  // bar 1 close price    
   int Highest = iHighest(_Symbol,PERIOD_W1,MODE_HIGH,prior_bar,0); 
   if(Highest == -1)
      PrintFormat("iHighest() call error. Error code=%d",GetLastError());
   int Lowest = iLowest(_Symbol,PERIOD_W1, MODE_LOW,prior_bar,0);
   if(Lowest == -1)
      PrintFormat("iHighest() call error. Error code=%d",GetLastError());
   double High = iHigh(_Symbol, PERIOD_W1, prior_bar );
   double Low  =  iLow(_Symbol, PERIOD_W1, prior_bar );

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
   // Pass Resistance Line1, Breakout
   //Print(" m1 ",mrate[1].close," m2 ",mrate[2].close);
   if((mrate[2].open > RL1 || mrate[2].close > RL1) && mrate[1].open > RL1 && mrate[1].close > mrate[1].open)
   {
      if((mrate[2].open > RL2 || mrate[2].close > RL2) && mrate[1].open > RL2 && mrate[1].close > mrate[1].open)
      {
         Print("Pass RL2 m2.close=",mrate[2].close," m1.close=",mrate[1].close," RL2=",RL2);
         RL1 = RL3;
         RL2 = RL4;
         RL3 = NULL;
         RL4 = NULL;    
         RL5 = NULL;
      }
      else 
      { 
         Print("Pass RL1 m2.close=",mrate[2].close," m1.close=",mrate[1].close," RL1=",RL1);
         RL1 = RL2;  
         RL2 = RL3;
         RL3 = RL4;
         RL4 = RL5;      
         RL5 = NULL;
      }
      if(RL1-mrate[1].close > TakeProfit*_Point)// && countSL()>=countRL())// SL3!=NULL)
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
   if((mrate[2].open > RL1 || mrate[2].close > RL1) && mrate[1].open > RL1 && mrate[1].close < mrate[1].open)
   {
      if((mrate[2].open > RL2 || mrate[2].close > RL2) && mrate[1].open > RL2 && mrate[1].close < mrate[1].open)
      {
         Print("Not Pass RL2 m2.close=",mrate[2].close," m1.close=",mrate[1].close," RL2=",RL2);
         RL1 = RL3;  
         RL2 = RL4;
         RL3 = NULL;
         RL4 = NULL;  
         RL5 = NULL;    
      }
      else
      {
         Print("Not Pass RL1 m2.close=",mrate[2].close," m1.close=",mrate[1].close," RL1=",RL1);
         RL1 = RL2;  
         RL2 = RL3;
         RL3 = RL4;
         RL4 = RL5; 
         RL5 = NULL;        
      }
      if(mrate[1].close-SL1 > TakeProfit2*_Point && down_trend)// && countRL()>countSL()) //SL3!=NULL)
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
   if(mrate[2].open < mrate[2].close && mrate[1].open > mrate[1].close)
   {
      Print("mrate2=", mrate[2].close, " mrate1=", mrate[1].open);
      Print("mrate2=", NormalizeDouble(mrate[2].close,4), " mrate1=", NormalizeDouble(mrate[1].open,4));
      //if(NormalizeDouble(mrate[2].close,_Digits-1) == NormalizeDouble(mrate[1].open,_Digits-1))
      if(fabs(mrate[2].close-mrate[1].open) < 10*_Point)   
      {
         RL5 = RL4;
         RL4 = RL3;   
         RL3 = RL2;
         RL2 = RL1;      
         RL1 = NormalizeDouble(mrate[1].open,4);
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
   if((mrate[2].open < SL1 || mrate[2].close < SL1) && mrate[1].open < SL1 && mrate[1].open > mrate[1].close)
   { 
      if((mrate[2].open < SL2 || mrate[2].close < SL2) && mrate[1].open < SL2 && mrate[1].open > mrate[1].close)
      { 
         Print("Pass SL2 m2.close=",mrate[2].close," m1.close=",mrate[1].close," SL2=",SL2);
         SL1 = SL3;
         SL2 = SL4;
         SL3 = NULL;
         SL4 = NULL;
         SL5 = NULL;
      }
      else
      {
         Print("Pass SL1 m2.close=",mrate[2].close," m1.close=",mrate[1].close," SL1=",SL1);
         SL1 = SL2;
         SL2 = SL3;
         SL3 = SL4;
         SL4 = SL5;  
         SL5 = NULL;    
      }
      if(mrate[1].close-SL1 > TakeProfit*_Point)// && countRL()>=countSL())// RL3!=NULL)
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
   if((mrate[2].open < SL1 || mrate[2].close < SL1) && mrate[1].open < SL1 && mrate[1].open < mrate[1].close )
   {
      if((mrate[2].open < SL2 || mrate[2].close < SL2) && mrate[1].open < SL2 && mrate[1].open < mrate[1].close )
      {
         Print("Not Pass SL2 m2.close=",mrate[2].close," m1.close=",mrate[1].close," SL2=",SL2);
         SL1 = SL3;
         SL2 = SL4;
         SL3 = NULL;
         SL4 = NULL;  
         SL5 = NULL;   
      }
      else
      {
         Print("Not Pass SL1 m2.close=",mrate[2].close," m1.close=",mrate[1].close," SL1=",SL1);
         SL1 = SL2;
         SL2 = SL3;
         SL3 = SL4;
         SL4 = SL5;    
         SL5 = NULL;  
      }
      if(RL1-mrate[1].close > TakeProfit2*_Point && up_trend)// && countSL()>countRL())// RL3!=NULL)
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
   if(mrate[2].open > mrate[2].close && mrate[1].open < mrate[1].close)
   {
      Print("mrate2=", mrate[2].close, " mrate1=", mrate[1].open);
      Print("mrate2=", NormalizeDouble(mrate[2].close,4), " mrate1=", NormalizeDouble(mrate[1].open,4));
      //if(NormalizeDouble(mrate[2].close,_Digits-1) == NormalizeDouble(mrate[1].open,_Digits-1))
      if(fabs(mrate[2].close-mrate[1].open) < 10*_Point)     
      {
         SL5 = SL4;
         SL4 = SL3;   
         SL3 = SL2;
         SL2 = SL1;
         SL1 = NormalizeDouble(mrate[1].open,4);
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
   
   
   //--- Declare bool type variables to hold our Buy Conditions
   bool Buy_Condition_1 = (maVal[0] > maVal[1]) && (maVal[1] > maVal[2]); // MA-8 Increasing upwards
   bool Buy_Condition_2 = (p_close > maVal[1]);         // previuos price closed above MA-8
   bool Buy_Condition_5 = (iHigh(_Symbol,_Period,1) > iHigh(_Symbol,_Period,2));
   bool Buy_Condition_6 = (latest_price.ask < High);

   //--- Putting all together   
   //---------Logic Entry Buy1
   if((Case1 || Case4) && Buy_Condition_5 && Buy_Condition_6)
   {
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
         if(SL1!=NULL)
            mrequest.sl = SL1;          
         mrequest.tp = NormalizeDouble(latest_price.ask + TP * _Point,_Digits); // Take Profit         
         if(RL1!=NULL)
            mrequest.tp = RL1;  // invert trend
         if(up_trend)
            mrequest.tp = RL2;  // follow trend
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
   //--- Declare bool type variables to hold our Sell Conditions
   bool Sell_Condition_1 = (maVal[0] < maVal[1]) && (maVal[1] < maVal[2]);  // MA-8 decreasing downwards
   bool Sell_Condition_2 = (p_close < maVal[1]);          // Previous price closed below MA-8
   bool Sell_Condition_5 = (iLow(_Symbol,_Period,1) < iLow(_Symbol,_Period,2));
   bool Sell_Condition_6 = (latest_price.bid > Low);

   //--- Putting all together
   if((Case2 || Case3) && Sell_Condition_5 && Sell_Condition_6)
   {    
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
         if(RL1!=NULL)
            mrequest.sl = RL1;     
         mrequest.tp = NormalizeDouble(latest_price.bid - TP * _Point,_Digits); // Take Profit         
         if(SL1!=NULL)
            mrequest.tp = SL1;  // invert trend
         if(down_trend)
            mrequest.tp = SL2;  // follow trend
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
/*
   //if(Case2 || Case3 || Case5)
   if(Case5)
   {
       // MODIFY ORDER SELL
      ulong tb = PositionGetTicket(0);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
      {
         if(RL1==NULL)
            mrequest.sl = NormalizeDouble(latest_price.bid + SL * _Point,_Digits); // Stop Loss
         else
            mrequest.sl = RL1+0.00010;     
         if(SL1==NULL)
            mrequest.tp = NormalizeDouble(latest_price.bid - TP * _Point,_Digits); // Take Profit         
         else if(down_trend)
            mrequest.tp = SL2;  // follow trend
         else
            mrequest.tp = SL1;  // invert trend      
         retcode2 = trade.PositionModify(tb,mrequest.sl,mrequest.tp);
         if(retcode2)
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
   //if(Case1 || Case4 || Case6)
   if(Case6)
   {
      // MODIFY ORDER BUY
      ulong tb = PositionGetTicket(0);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
      {
         if(SL1==NULL)
            mrequest.sl = NormalizeDouble(latest_price.ask - SL * _Point,_Digits); // Stop Loss    
         else
            mrequest.sl = SL1-0.00010;          
         if(RL1==NULL)
            mrequest.tp = NormalizeDouble(latest_price.ask + TP * _Point,_Digits); // Take Profit         
         else if(up_trend)
            mrequest.tp = RL2;  // follow trend
         else
            mrequest.tp = RL1;  // invert trend
         retcode2 = trade.PositionModify(tb,mrequest.sl,mrequest.tp);
         if(retcode2)
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
*/
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

int countRL()
{
   int count=0;
   if(RL1==NULL)
      count=0;
   else if(RL2==NULL)
      count=1;
   else if(RL3==NULL)
      count=2;
   else if(RL4==NULL)
      count=3;
   else if(RL5==NULL)
      count=4;
   else
      count=5;
   return(count);
}

int countSL()
{
   int count=0;
   if(SL1==NULL)
      count=0;
   else if(SL2==NULL)
      count=1;
   else if(SL3==NULL)
      count=2;
   else if(SL4==NULL)
      count=3;
   else if(SL5==NULL)
      count=4;
   else
      count=5;
   return(count);
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