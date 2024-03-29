//+------------------------------------------------------------------+
//|                                                       50% V1.mq4 |
//|                                  Copyright © 2016, Maxim Romanov |
//|                                        e-Mail: 223231@rambler.ru |
//+------------------------------------------------------------------+
// *- minbars - from 0 to infinity - integers
// *- maxbars - from 0 to infinity - integers.
// *- minbars<=maxbars
// *- Step - from 1, any integers not conflicting
//    with minbars and maxbars. Because if minbars=2, maxbars = 50 and Step= 60, 'step' is meaningless.
// *- K - can be fractional from 0.1 to N. This is a ratio defining number of positions that can be opened.
//   For example, the range of 100 bars, К=2. This means that 200 positions can be opened. 
//   Here the ordersend error may occur if the broker does not allow opening more than 100 positions, 
//   while we need 200. The error should be fixed.
// *- openperc -  1-100, integers
// *- Closeperc - 1-100, integers
// *- depo - set the deposit for work. If 0, use the real deposit. The value may be fractional, but I use integers
// *- riskPerc - deposit percentage to calculate the lot can exceed 100 and be less than 1. It can also be fractional
// *- CloseProfit - positive number from 0 to N, can be fractional
// *- Spred - integer from 0 to N
// *- SL - integer. 0 - not used. If the value is too high, 
//    a broker will not accept leading to an error. A check is needed to avoid errors
// *- Tp - integer. 0 - not used.
// *Since the tester is multi-currency, only the first pair is used for the tester. If the instrument
//  in the tester does not match the one set in the first pair, the error occurs. 
//  Thus, the pair coming first should be set on the real chart. 
//  The error should be replaced with the check. The mismatch message is to be displayed. 
//+------------------------------------------------------------------+
#property copyright "v.1.0 Copyright © 2016, Maxim Romanov"
#property version "1.0"
#property link      "https://www.mql5.com/en/users/223231"
#property link      "https://www.linkedin.com/in/%D0%BC%D0%B0%D0%BA%D1%81%D0%B8%D0%BC-%D1%80%D0%BE%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2-05475610b/"
#property link      "e-Mail: 223231@rambler.ru"
#property strict

extern string  s11="General settings";
extern ENUM_TIMEFRAMES TF = PERIOD_H4;
extern double  MinEquity=1;  
extern double  GlobalEquity=100; 
extern int     MaxSeries=9; 
extern int     Slip=30;
extern int     Magic=88922;
extern bool    ECN=true;
extern int     Max_Orders=200;
extern bool    Rus_Lat=false;

extern string  s1="Instrument settings 1";
extern string  sym1="GBPUSD";
extern int     MinBars1=100;    
extern int     MaxBars1=100;   
extern int     Step1=2;        
extern double  K1=2;         
extern int     OpenPerc1=57;   
extern int     ClosePerc1=50;  
extern int     RiskPerc1=1;   
extern double  Depo1=0;      
extern double  CloseProfit1=100;
extern int     Spred1=100;
extern int     SL1=0;
extern int     TP1=0;

extern string  s2="Instrument settings 2";
extern string  sym2="USDCAD";
extern int     MinBars2=100;   
extern int     MaxBars2=100;   
extern int     Step2=2;       
extern double  K2=2;         
extern int     OpenPerc2=57;   
extern int     ClosePerc2=50;  
extern int     RiskPerc2=1;   
extern double  Depo2=0;        
extern double  CloseProfit2=100;
extern int     Spred2=100;
extern int     SL2=0;
extern int     TP2=0;

extern string  s3="Instrument settings 3";
extern string  sym3="AUDUSD";
extern int     MinBars3=100;    
extern int     MaxBars3=100;  
extern int     Step3=2;       
extern double  K3=2;        
extern int     OpenPerc3=56;   
extern int     ClosePerc3=50;  
extern int     RiskPerc3=1;   
extern double  Depo3=0;         
extern double  CloseProfit3=100;
extern int     Spred3=100;
extern int     SL3=0;
extern int     TP3=0;

extern string  s4="Instrument settings 4";
extern string  sym4="USDCHF";
extern int     MinBars4=100;    
extern int     MaxBars4=100;   
extern int     Step4=2;        
extern double  K4=2;         
extern int     OpenPerc4=58;  
extern int     ClosePerc4=50;  
extern int     RiskPerc4=1;  
extern double  Depo4=0;         
extern double  CloseProfit4=100;
extern int     Spred4=100;
extern int     SL4=0;
extern int     TP4=0;

extern string  s5="Instrument settings 5";
extern string  sym5="AUDJPY";
extern int     MinBars5=100;    
extern int     MaxBars5=100;   
extern int     Step5=2;       
extern double  K5=2;         
extern int     OpenPerc5=56;   
extern int     ClosePerc5=50;  
extern int     RiskPerc5=1;   
extern double  Depo5=0;         
extern double  CloseProfit5=100;
extern int     Spred5=120;
extern int     SL5=0;
extern int     TP5=0;

extern string  s6="Instrument settings 6";
extern string  sym6="AUDNZD";
extern int     MinBars6=100;    
extern int     MaxBars6=100;   
extern int     Step6=2;       
extern double  K6=2;         
extern int     OpenPerc6=60;   
extern int     ClosePerc6=50;  
extern int     RiskPerc6=1;   
extern double  Depo6=0;         
extern double  CloseProfit6=100;
extern int     Spred6=180;
extern int     SL6=0;
extern int     TP6=0;

extern string  s7="Instrument settings 7";
extern string  sym7="CADJPY";
extern int     MinBars7=100;    
extern int     MaxBars7=100;   
extern int     Step7=2;        
extern double  K7=2;         
extern int     OpenPerc7=60;   
extern int     ClosePerc7=50;  
extern int     RiskPerc7=1;   
extern double  Depo7=0;        
extern double  CloseProfit7=100;
extern int     Spred7=140;
extern int     SL7=0;
extern int     TP7=0;

extern string  s8="Instrument settings 8";
extern string  sym8="CHFJPY";
extern int     MinBars8=100;    
extern int     MaxBars8=100;   
extern int     Step8=2;       
extern double  K8=2;         
extern int     OpenPerc8=60;   
extern int     ClosePerc8=50;  
extern int     RiskPerc8=1;   
extern double  Depo8=0;         
extern double  CloseProfit8=100;
extern int     Spred8=180;
extern int     SL8=0;
extern int     TP8=0;

extern string  s9="Instrument settings 9";
extern string  sym9="EURCHF";
extern int     MinBars9=100;    
extern int     MaxBars9=100;  
extern int     Step9=2;        
extern double  K9=2;         
extern int     OpenPerc9=56;   
extern int     ClosePerc9=50; 
extern int     RiskPerc9=1;   
extern double  Depo9=0;         
extern double  CloseProfit9=100;
extern int     Spred9=100;
extern int     SL9=0;
extern int     TP9=0;

extern string  s10="Instrument settings 10";
extern string  sym10="EURGBP";
extern int     MinBars10=100;    
extern int     MaxBars10=100;   
extern int     Step10=2;        
extern double  K10=2;         
extern int     OpenPerc10=58;   
extern int     ClosePerc10=50;  
extern int     RiskPerc10=1;   
extern double  Depo10=0;         
extern double  CloseProfit10=100;
extern int     Spred10=100;
extern int     SL10=0;
extern int     TP10=0;
//-----------------------------------------------
int      n, N, S, R, E, i, j;
bool     start_=true,UpB,stop=false;
double   Lot,MaxPerc,MaxOpenPerc,Bal,UpBars, DnBars,SetEquity;
datetime time,TimeN;
string   Sym,sym[11],Magic_str;

int      MinBars, MaxBars, Step,OpenPerc,ClosePerc,RiskPerc,Spred,SL,TP,Series,ord,All_ord;
double   K,Depo,CloseProfit,SeriesProfit;
int      minbars[11], maxbars[11], step[11],openperc[11],closeperc[11],riskperc[11],spred[11],sl[11],tp[11];
double   k[11],depo[11],closeprofit[11];
bool     OK;
string   com_err="";
double   min_l, max_l;
int      max_kol_ord;
int      Glob_err;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   if (IsTesting())sym1=Symbol();
   //..........................................
   Init_All_var();
   OK=Check_var();
   if (!OK)return(0);
   //......................
   Glob_err=0;
   com_err="";
   //......................
   min_l=MarketInfo(Symbol(),MODE_MINLOT);
   max_l=MarketInfo(Symbol(),MODE_MAXLOT);
   //......................
   Magic_str=IntegerToString(Magic);
   
   if(IsTesting()) GlobalVariablesDeleteAll(Magic_str);
   if(!GlobalVariableCheck(Magic_str+"SetEquity")) GlobalVariableSet(Magic_str+"SetEquity",AccountBalance());
   for(i=1;i<11;i++)
     if(sym[i]!="" && !GlobalVariableCheck(Magic_str+sym[i]+"Start")) GlobalVariableSet(Magic_str+sym[i]+"Start",1);

   return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   if (!OK)return(0);
   //.........................
   if (Glob_err>0)
   {
      Comment(com_err);
      if (Glob_err>1)
      {
         Comment(com_err+RusLat_me(Rus_Lat,"Серьёзная ошибка! Эксперт остановлен!","A serious mistake! Expert stopped!"));
         return(0);
      }
   }
   //.........................
   time=(datetime)GlobalVariableGet(Magic_str+"Time");
   SetEquity=GlobalVariableGet(Magic_str+"SetEquity");
   if(AccountEquity()<MinEquity) 
   {
      CloseAll2();
      stop=true;
   }
   if(AccountEquity()-SetEquity>GlobalEquity && GlobalEquity>0) CloseAll2();
   
   Series=0;
   for(j=1;j<11;j++)
   {
      if(sym[j]=="") continue;
      if(GlobalVariableGet(Magic_str+sym[j]+"Close")==1 && MarketInfo(sym[j],MODE_ASK)-MarketInfo(sym[j],MODE_BID)<spred[j]*MarketInfo(sym[j],MODE_POINT)) 
      {
         Print("Closing in achieving the desired spread "+sym[j]);
         CloseAll(sym[j]);
      }
      
      if(GlobalVariableGet(Magic_str+sym[j]+"Start")==0) Series++;
   }
   //-----------------------------------------------
   All_ord=0;
   for(i=0;i<OrdersTotal();i++)
      if(OrderSelect(i,SELECT_BY_POS) && OrderMagicNumber()==Magic)All_ord++; 
   //-----------------------------------------------
   if(time!=iTime(sym[1],TF,0)) //New bar
   {
      time=iTime(sym[1],TF,0);
      GlobalVariableSet(Magic_str+"Time",time);
      for(j=1;j<11;j++)
      {
         //overwrite variables from arrays
         Get_mas(j,Sym,MinBars,MaxBars,Step,K,OpenPerc,ClosePerc,RiskPerc,Depo,CloseProfit,Spred,SL,TP);
         
         if(IsTesting() && j>1) continue;
         if(Sym=="") continue;
            //read global variables
         Get_glob(start_,UpB,UpBars,DnBars,N,S,R,E,MaxPerc,Lot,TimeN);
         
         if(Series>=MaxSeries && start_) continue;
         if(GlobalVariableGet(Magic_str+sym[j]+"Close")==1) continue;
         
         SeriesProfit=0;
         ord=0;
               //define the series profit and calculate the number of open orders
         for(i=0;i<OrdersTotal();i++)
            if(OrderSelect(i,SELECT_BY_POS) && OrderMagicNumber()==Magic && OrderSymbol()==Sym) 
            {
               Modify_ord(OrderTicket(),OrderType(), OrderOpenPrice());
               SeriesProfit+=OrderProfit()+OrderSwap()+OrderCommission();
               ord++;
            }

         if(start_ && !stop)
         {
            UpBars=0; DnBars=0; N=0; S=0; R=0; E=0; MaxPerc=0; n=0; MaxOpenPerc=0;
            double prc=0,upb=0,dnb=0;
            
            for(i=1;i<=MaxBars;i++)
            {
               if(iOpen(Sym,0,i)>iClose(Sym,0,i)) {dnb++;n++;}
               if(iOpen(Sym,0,i)<iClose(Sym,0,i)) {upb++;n++;}
               if (n==0)n=1;
               if(i>=MinBars && MathMod(i-MinBars,Step)==0) //Find the bar with the maximum excess
               {
                  if(upb>dnb) UpB=true; else UpB=false;
                  if(UpB) prc=upb/n*100.0; else prc=dnb/n*100.0;
                  if(prc>MaxPerc) MaxPerc=prc;
                  if(MaxPerc>=OpenPerc && MaxPerc>MaxOpenPerc) 
                  {
                     MaxOpenPerc=MaxPerc;
                     N=n;
                     DnBars=dnb;
                     UpBars=upb;
                  }
               }
            }
            if(N==0) 
            {
               DnBars=dnb;
               UpBars=upb;
               if(IsTesting()) Info();
            }
         }
         //................................
         if(N>0 && start_ && !stop) //Calculate the initial parameters
         {
            start_=false;
            Series++;
            TimeN=iTime(Sym,0,0);
            //.........................
            S=(int)MathAbs(UpBars-DnBars); //Excess in bars
            R=(int)MathRound(1.0*(S+N)*K);  //total bars necessary for the equilibrium
            E=R-N;      //Maximum possible number of bars leading to the equilibrium
            //...............................
            if(Depo==0) 
               Lot=NormalizeDouble(AccountBalance()/100*RiskPerc/1000/E,2);
            else  
               Lot=NormalizeDouble(Depo/100*RiskPerc/1000/E,2);
            if(Lot<MarketInfo(Sym,MODE_MINLOT)) Lot=MarketInfo(Sym,MODE_MINLOT);
            if(Lot>MarketInfo(Sym,MODE_MAXLOT)) Lot=MarketInfo(Sym,MODE_MAXLOT);
            //............................
            Open_ord();
            //............................
            if(IsTesting()) Info();
            GlobalSave();
            continue;
         }
         if(start_) continue;
         
         if(!stop)
         {
            if(iOpen(Sym,0,1)>iClose(Sym,0,1)) DnBars++;
            if(iOpen(Sym,0,1)<iClose(Sym,0,1)) UpBars++;
            if(UpB) 
               MaxPerc=UpBars/(UpBars+DnBars)*100;
            else
               MaxPerc=DnBars/(UpBars+DnBars)*100;
   
            if(MaxPerc<=ClosePerc && UpBars+DnBars-N+1>=S) 
            {
               CloseAll(Sym); 
               Print("Closing in achieving the desired percentage "+Sym);
               continue;
            }
            if(iBarShift(Sym,0,TimeN)>=E) 
            {
               CloseAll(Sym); 
               Print("Closure when the maximum number of positions "+Sym);
               continue;
            }
            if(SeriesProfit>Lot*ord*CloseProfit)  
            {
               CloseAll(Sym); 
               Print("Closing in achieving the established profit "+Sym);
               continue;
            }
            //.........................................
            if (iBarShift(Sym,0,TimeN)<E)Open_ord();
         }
              
         if(IsTesting()) Info();
         
         //Save the variables
         GlobalSave();
      }
      stop=false;
   }
//----
   return(0);
}
//---------------------------------
void Open_ord()
{
   if (Max_Orders>0 && All_ord>=Max_Orders)
   {
      IsError(9000,"",com_err,Rus_Lat); // many orders
      Glob_err=1;
      return;
   }
   double stp=0,prf=0,pr=0;
   int tip=0;
   color clr=0;
   
   RefreshRates();
   int stop_level=(int)MarketInfo(Sym,MODE_STOPLEVEL);
   double poi=MarketInfo(Sym,MODE_POINT);
   int tkt=0;
   
   if(UpB) 
   {
      tip=OP_SELL;
      pr=MarketInfo(Sym,MODE_BID);
      
      if(SL>0)
      {
         stp=pr+SL*poi;
         if (ND(stp-pr)<ND(stop_level*poi))stp=0;
      }
      
      if(TP>0)
      {
         prf=pr-TP*poi;
         if (ND(pr-prf)<ND(stop_level*poi))prf=0;
      }
      
      clr=clrRed;
   }
   else
   {
      tip=OP_BUY;
      pr=MarketInfo(Sym,MODE_ASK);
      
      if(SL>0)
      {
         stp=pr-SL*poi;
         if (ND(pr-stp)<ND(stop_level*poi))stp=0;
      }
      
      if(TP>0)
      {
         prf=pr+TP*poi;
         if (ND(prf-pr)<ND(stop_level*poi))prf=0;
      }
      
      clr=clrBlue;
   }
   if (AccountFreeMarginCheck(Symbol(), tip, Lot)>0)
      tkt=ust_order(Sym,tip,Lot,pr,Slip,ECN?0:stp,ECN?0:prf,"",Magic,0,clr);
   else
   {
      IsError(134, "", com_err, Rus_Lat); // insufficient funds
      Glob_err=2;
   }
}
//---------------------------------------------------------------
void Modify_ord(int tkt, int tip, double pr)
{
   double stp=0,prf=0;
   color clr=0;
   double poi=MarketInfo(Sym,MODE_POINT);
   double bid=MarketInfo(Sym,MODE_BID);
   double ask=MarketInfo(Sym,MODE_ASK);
   int stop_level=(int)MarketInfo(Sym,MODE_STOPLEVEL);
   
   RefreshRates();
   if(tip==OP_SELL) 
   {
      if(SL>0)
      {
         stp=pr+SL*poi;
         if (ND(stp-bid)<ND(stop_level*poi))stp=OrderStopLoss();
      }
      if(TP>0)
      {
         prf=pr-TP*poi;
         if (ND(bid-prf)<ND(stop_level*poi))prf=OrderTakeProfit();
      }
      clr=clrRed;
   }
   else
   {
      if(SL>0)
      {
         stp=pr-SL*poi;
         if (ND(ask-stp)<ND(stop_level*poi))stp=OrderStopLoss();
      }
      if(TP>0)
      {
         prf=pr+TP*poi;
         if (ND(prf-ask)<ND(stop_level*poi))prf=OrderTakeProfit();
      }
      clr=clrBlue;
   }
   if(stp>0 || prf>0)
      if ((stp>0 && ND(OrderStopLoss())!=ND(stp)) || (prf>0 && ND(OrderTakeProfit())!=ND(prf)))
      {
         bool M=OrderModify(tkt,OrderOpenPrice(),stp,prf,0,clr);
         if (!M)Glob_err=IsError(GetLastError(),Sym+" Modify "+tip_str(tip)+": pr="+DoubleToStr(OrderOpenPrice(),Digits)+" sl="+DoubleToStr(stp,Digits)+" tp="+DoubleToStr(prf,Digits),com_err,Rus_Lat);
      }
}
//---------------------------------------------------------------
double ND(double r)
{
   return(NormalizeDouble(r,Digits));
}
//+------------------------------------------------------------------+
//| Close all orders on a selected pair                              |
//+------------------------------------------------------------------+
int CloseAll(string sym_)
{
   if(MarketInfo(sym_,MODE_ASK)-MarketInfo(sym_,MODE_BID)>=spred[j]*MarketInfo(sym_,MODE_POINT)) //Check spread when closing
     {GlobalVariableSet(Magic_str+sym_+"Close",1);return(0);}
     
   for(i=0;i<OrdersTotal();i++)
     if(OrderSelect(i,SELECT_BY_POS) && OrderMagicNumber()==Magic && OrderSymbol()==sym_)
     {
        bool C=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slip);
        i--;
     }
       
   start_=true;
   GlobalVariableSet(Magic_str+sym_+"Start",1);
   GlobalVariableSet(Magic_str+sym_+"Close",0);

   return(0);
}
//+------------------------------------------------------------------+
//| Close all orders on all pairs                                    |
//+------------------------------------------------------------------+
int CloseAll2()
{
   for(i=0;i<OrdersTotal();i++)
     if(OrderSelect(i,SELECT_BY_POS) && OrderMagicNumber()==Magic)
     {
        bool C=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slip);
        i--;
     }
       
   for(i=1;i<11;i++)
     if(sym[i]!="") GlobalVariableSet(Magic_str+sym[i]+"Start",1);
   
   GlobalVariableSet(Magic_str+"SetEquity",AccountBalance());

   return(0);
}
//+------------------------------------------------------------------+
//| Info panel                                                       |
//+------------------------------------------------------------------+
int Info()
{
   double prf;
   SeriesProfit=0;
   ord=0;
   for(i=0;i<OrdersTotal();i++)
     if(OrderSelect(i,SELECT_BY_POS) && OrderMagicNumber()==Magic && OrderSymbol()==Sym) 
       {SeriesProfit+=OrderProfit()+OrderSwap()+OrderCommission();ord++;}
       
   if(Lot*ord>0) prf=NormalizeDouble((SeriesProfit)/(Lot*ord),2);
   
   Comment(Glob_err>0?com_err:"",
            "UpBars = ",UpBars,
            "\nDownBars = ",DnBars,
            "\nPercent = ",NormalizeDouble(MaxPerc,2),"%",
            "\nMinBars = ",S,
            "\nMaxBars = ",E,
            "\nCurrentBar = ",OrdersTotal(),
            "\nProfit/Lot = ",prf
          );

   return(0);
  }
//+------------------------------------------------------------------+
//| Save global variables                                            |
//+------------------------------------------------------------------+
int GlobalSave()
{
   if(start_) 
      GlobalVariableSet(Magic_str+Sym+"Start",1); 
   else 
      GlobalVariableSet(Magic_str+Sym+"Start",0);
   if(UpB) 
      GlobalVariableSet(Magic_str+Sym+"UpB",1); 
   else 
      GlobalVariableSet(Magic_str+Sym+"UpB",0);
   GlobalVariableSet(Magic_str+Sym+"UpBars",UpBars);
   GlobalVariableSet(Magic_str+Sym+"DnBars",DnBars);
   GlobalVariableSet(Magic_str+Sym+"N",N);
   GlobalVariableSet(Magic_str+Sym+"S",S);
   GlobalVariableSet(Magic_str+Sym+"R",R);
   GlobalVariableSet(Magic_str+Sym+"E",E);
   GlobalVariableSet(Magic_str+Sym+"MaxPerc",MaxPerc);
   GlobalVariableSet(Magic_str+Sym+"Lot",Lot);
   GlobalVariableSet(Magic_str+Sym+"TimeN",TimeN);

   return(0);
}
///////////////////////////////////////////////////////////////////
void Get_mas(int m, string& s,int& MinBars_,int& MaxBars_,int& Step_,double& K_,int& OpenPerc_,int& ClosePerc_,
              int& RiskPerc_,double& Depo_,double& CloseProfit_,int& Spred_,int& SL_,int& TP_)
{
   s=sym[j];
   MinBars_=minbars[j];    
   MaxBars_=maxbars[j];   
   Step_=step[j];        
   K_=k[j];         
   OpenPerc_=openperc[j];   
   ClosePerc_=closeperc[j];
   RiskPerc_=riskperc[j];
   Depo_=depo[j];  
   CloseProfit_=closeprofit[j];
   Spred_=spred[j];    
   SL_=sl[j];
   TP_=tp[j];
}
//----------------------------
void Get_glob(bool& st,bool& UpB_,double& UpBars_,double& DnBars_,int& N_,int& S_,int& R_,int& E_,
              double& MaxPerc_, double& Lot_, datetime& TimeN_)
{
   if(GlobalVariableGet(Magic_str+Sym+"Start")==0) 
      st=false; 
   else 
      st=true;
   if(GlobalVariableGet(Magic_str+Sym+"UpB")==0) 
      UpB_=false; 
   else 
      UpB_=true;
   UpBars_=GlobalVariableGet(Magic_str+Sym+"UpBars");
   DnBars_=GlobalVariableGet(Magic_str+Sym+"DnBars");
   N_=(int)GlobalVariableGet(Magic_str+Sym+"N");
   S_=(int)GlobalVariableGet(Magic_str+Sym+"S");
   R_=(int)GlobalVariableGet(Magic_str+Sym+"R");
   E_=(int)GlobalVariableGet(Magic_str+Sym+"E");
   MaxPerc_=GlobalVariableGet(Magic_str+Sym+"MaxPerc");
   Lot_=GlobalVariableGet(Magic_str+Sym+"Lot");
   TimeN_=(datetime)GlobalVariableGet(Magic_str+Sym+"TimeN");
}
//+------------------------------------------------------------------+
void Init_All_var()
{
   Init_var(1, sym1, MinBars1, MaxBars1, Step1, K1, OpenPerc1, ClosePerc1, RiskPerc1, Depo1, CloseProfit1, Spred1, SL1, TP1);
   if (IsTesting())return;
   Init_var(2, sym2, MinBars2, MaxBars2, Step2, K2, OpenPerc2, ClosePerc2, RiskPerc2, Depo2, CloseProfit2, Spred2, SL2, TP2);
   Init_var(3, sym3, MinBars3, MaxBars3, Step3, K3, OpenPerc3, ClosePerc3, RiskPerc3, Depo3, CloseProfit3, Spred3, SL3, TP3);
   Init_var(4, sym4, MinBars4, MaxBars4, Step4, K4, OpenPerc4, ClosePerc4, RiskPerc4, Depo4, CloseProfit4, Spred4, SL4, TP4);
   Init_var(5, sym5, MinBars5, MaxBars5, Step5, K5, OpenPerc5, ClosePerc5, RiskPerc5, Depo5, CloseProfit5, Spred5, SL5, TP5);
   Init_var(6, sym6, MinBars6, MaxBars6, Step6, K6, OpenPerc6, ClosePerc6, RiskPerc6, Depo6, CloseProfit6, Spred6, SL6, TP6);
   Init_var(7, sym7, MinBars7, MaxBars7, Step7, K7, OpenPerc7, ClosePerc7, RiskPerc7, Depo7, CloseProfit7, Spred7, SL7, TP7);
   Init_var(8, sym8, MinBars8, MaxBars8, Step8, K8, OpenPerc8, ClosePerc8, RiskPerc8, Depo8, CloseProfit8, Spred8, SL8, TP8);
   Init_var(9, sym9, MinBars9, MaxBars9, Step9, K9, OpenPerc9, ClosePerc9, RiskPerc9, Depo9, CloseProfit9, Spred9, SL9, TP9);
   Init_var(10,sym10,MinBars10,MaxBars10,Step10,K10,OpenPerc10,ClosePerc10,RiskPerc10,Depo10,CloseProfit10,Spred10,SL10,TP10);
}
//---------------------------------------
void Init_var(int m,string s,int MinBars_,int MaxBars_,int Step_,double K_,int OpenPerc_,int ClosePerc_,
              int RiskPerc_,double Depo_,double CloseProfit_,int Spred_,int SL_,int TP_)
{
   sym[m]=StringTrimLeft(StringTrimRight(s));
   minbars[m]=MinBars_;    
   maxbars[m]=MaxBars_;   
   step[m]=Step_;        
   k[m]=K_;         
   openperc[m]=OpenPerc_;   
   closeperc[m]=ClosePerc_;
   riskperc[m]=RiskPerc_;
   depo[m]=Depo_;  
   closeprofit[m]=CloseProfit_;
   spred[m]=Spred_;       
   sl[m]=SL_;
   tp[m]=TP_;
}
//============================================================================
bool Check_var()
{
   if (!Check_MinEquity())return(0);
   if (!Check_GlobalEquity())return(0);
   if (!Check_MaxSeries())return(0);
   //..........................................
   int m=11;
   if (IsTesting())m=2;
   if (!Check_All_sym(m))return(0);
   if (!Check_sym1())return(0);
   if (!Check_MinBars_MaxBars(m))return(0);
   if (!Check_Step(m))return(0);
   if (!Check_Step_MinBars_MaxBars(m))return(0);
   if (!Check_K(m))return(0);
   if (!Check_OpenPerc(m))return(0);
   if (!Check_ClosePerc(m))return(0);
   if (!Check_RiskPerc(m))return(0);
   if (!Check_Depo(m))return(0);
   if (!Check_CloseProfit(m))return(0);
   if (!Check_Spred(m))return(0);
   if (!Check_SL(m))return(0);
   if (!Check_TP(m))return(0);
   Comment("");
   
   return(1);
}
//-------------------- 
bool Check_MinEquity()
{
   if (!Check_positive(MinEquity,"MinEquity")) return(0);
   return(1);
}
//--------------------
bool Check_GlobalEquity()
{
   if (!Check_positive(GlobalEquity,"GlobalEquity")) return(0);
   return(1);
}
//--------------------
bool Check_MaxSeries()
{
   bool out=1;
   if (MaxSeries<=0 || MaxSeries>10)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная MaxSeries должна быть в пределах 1...10. Стоп!";
      else
         s="Variable MaxSeries should be in the range 1 ... 10. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------
bool Check_All_sym(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_sym(q,sym[q])) return(0);
   return(1);
}
//--------------------
bool Check_sym(int q,string symbol)
{
   if (symbol=="")return(1);
   //.................
      // search for an entered symbol in the terminal
   int  kol_symb=SymbolsTotal(false); // select all symbols
   for(int p=0;p<kol_symb;p++)
      if (SymbolName(p,false)==symbol)return(1); // symbol found
   //..............................
         // symbol not found
   string s="";
   if (Rus_Lat)
      s="sym"+IntegerToString(q)+"="+symbol+" не найден в списке допустимых символов. Стоп!";
   else
      s="sym"+IntegerToString(q)+"="+symbol+" not found in the list of valid symbols. Stop!";
   Comment(s);
      
   return(0);
}
//--------------------
bool Check_sym1()
{
   bool out=1;
   if (sym1!=Symbol())
   {
      string s="";
      if (Rus_Lat)
         s="Советник должен быть установлен на символ="+sym1+". Стоп!";
      else
         s="Expert must be installed on the symbol="+sym1+". Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------
bool Check_MinBars_MaxBars(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_2_var(q,minbars[q],maxbars[q],"MinBars","MaxBars")) return(0);
   return(1);
}
//---------------------------
bool Check_2_var(int q, int m1,int m2,string s_m1,string s_m2)
{
   if (!Check_positive_or_zero(q,m1,s_m1))return(0);
   if (!Check_positive_or_zero(q,m2,s_m2))return(0);
   if (!Check_less_or_equal(q,m1,s_m1,m2,s_m2))return(0);
   return(1);
}
//-----------------------------------
bool Check_Step(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_more_or_equal_1(q,step[q],"Step")) return(0);
   return(1);
}
//---------------------------
bool Check_Step_MinBars_MaxBars(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_within_interval(q,step[q],minbars[q],maxbars[q],"Step")) return(0);
   return(1);
}
//---------------------------
bool Check_K(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_more_or_equal_01_double(q,k[q],"K")) return(0);
   return(1);
}
//------------------------------
bool Check_OpenPerc(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_percent(q,openperc[q],"OpenPerc")) return(0);
   return(1);
}
//---------------------------
bool Check_ClosePerc(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_percent(q,closeperc[q],"ClosePerc")) return(0);
   return(1);
}
//---------------------------
bool Check_RiskPerc(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_positive_double(q,riskperc[q],"RiskPerc")) return(0);
   return(1);
}
//---------------------------
bool Check_Depo(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_positive_or_zero_double(q,depo[q],"Depo")) return(0);
   return(1);
}
//------------------------------
bool Check_CloseProfit(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_positive_or_zero_double(q,closeprofit[q],"CloseProfit")) return(0);
   return(1);
}
//------------------------------
bool Check_Spred(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_positive_or_zero(q,spred[q],"Spred")) return(0);
   return(1);
}
//------------------------------
bool Check_SL(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_positive_or_zero(q,sl[q],"SL")) return(0);
   return(1);
}
//------------------------------
bool Check_TP(int m)
{
   for(int q=1;q<m;q++)
      if (!Check_positive_or_zero(q,tp[q],"TP")) return(0);
   return(1);
}
//------------------------------
bool Check_percent(int q, int m1,string s_m1)
{
   bool out=1;
   if (m1<1 || m1>100)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m1+IntegerToString(q)+" должна быть от 1 до 100. Стоп!";
      else
         s=s_m1+IntegerToString(q)+" variable must be from 1 to 100. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_positive_or_zero(int q,int m,string s_m)
{
   bool out=1;
   if (m<0)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+IntegerToString(q)+" должна быть больше или равна нулю. Стоп!";
      else
         s=s_m+IntegerToString(q)+" variable must be greater than or equal to zero. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_positive_or_zero_double(int q,double m,string s_m)
{
   bool out=1;
   if (m<0.0)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+IntegerToString(q)+" должна быть больше или равна нулю. Стоп!";
      else
         s=s_m+IntegerToString(q)+" variable must be greater than or equal to zero. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_positive(double m,string s_m)
{
   bool out=1;
   if (NormalizeDouble(m,2)<=0.0)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+" должна быть больше ноля. Стоп!";
      else
         s=s_m+" variable must be greater than zero. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_positive(int m,string s_m)
{
   bool out=1;
   if (NormalizeDouble(m,2)<=0.0)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+" должна быть больше ноля. Стоп!";
      else
         s=s_m+" variable must be greater than zero. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_positive_double(int q,double m,string s_m)
{
   bool out=1;
   if (NormalizeDouble(m,2)<=0.0)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+IntegerToString(q)+" должна быть больше ноля. Стоп!";
      else
         s=s_m+IntegerToString(q)+" variable must be greater than zero. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_less_or_equal(int q,int m1,string s_m1,int m2,string s_m2)
{
   bool out=1;
   if (m1>m2)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m1+IntegerToString(q)+" должна быть меньше или равна пременной "+s_m2+IntegerToString(q)+". Стоп!";
      else
         s=s_m1+IntegerToString(q)+" variable must be less than or equal to the variable "+s_m2+IntegerToString(q)+". Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_more_or_equal_1(int q,int m,string s_m)
{
   bool out=1;
   if (m<1)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+IntegerToString(q)+" должна быть больше или равна единице. Стоп!";
      else
         s=s_m+IntegerToString(q)+" variable must be greater than or equal to 1. Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_more_or_equal_01_double(int q,double m,string s_m)
{
   bool out=1;
   if (m<0.1)
   {
      string s="";
      if (Rus_Lat)
         s="Переменная "+s_m+IntegerToString(q)+" должна быть больше или равна 0.1   Стоп!";
      else
         s=s_m+IntegerToString(q)+" variable must be greater than or equal to 0.1   Stop!";
      Comment(s);
      out=0;
   }
   return(out);
}
//--------------------------
bool Check_within_interval(int q,int m1,int m2,int m3,string s_m1)
{
   bool out=1;
   if (m3>m2)
      if (m1>m3-m2)
      {
         string s="";
         if (Rus_Lat)
            s="Переменная "+s_m1+IntegerToString(q)+"="+IntegerToString(m1)+
              " не имеет смысла для MinBars"+IntegerToString(q)+"="+IntegerToString(m2)+
              " и MaxBars"+IntegerToString(q)+"="+IntegerToString(m3)+". Стоп!";
         else
            s="Variable "+s_m1+IntegerToString(q)+"="+IntegerToString(m1)+
              " does not make sense for MinBars"+IntegerToString(q)+"="+IntegerToString(m2)+
              " and MaxBars"+IntegerToString(q)+"="+IntegerToString(m3)+". Stop!";
         Comment(s);
         out=0;
      }
   return(out);
}
//--------------------------
int ust_order(string sym_,int Tip, double lot1, double pr, int slippage, double sl_, double tp_, string com2, int mag, color col=clrNONE, int dt=0)
{
   double tek_lot;
   double ust_lot=lot1;
   int tik=0;
   while (ust_lot>0)
   {
      tek_lot=Ogran_max_lot(ust_lot);
      tik = OrderSend(sym_, Tip, tek_lot, pr, slippage, sl_, tp_, com2, mag, dt, col);
      if (tik<0)break;
      ust_lot-=tek_lot;
   }
   if (tik<0)
      Glob_err=IsError(GetLastError(),sym_+" Open "+tip_str(Tip)+": pr="+DoubleToStr(pr,Digits)+" sl="+DoubleToStr(sl_,Digits)+" tp="+DoubleToStr(tp_,Digits),com_err,Rus_Lat);

   return(tik);
}
//-----------------------------------------------
double Ogran_min_lot(double lot1)
{
   if (lot1 < min_l)lot1 = min_l;
   return(lot1);
}
//---------------------------------------------------------------
double Ogran_max_lot(double lot1)
{
   if (lot1 > max_l)lot1 = max_l;
   return(lot1);
}
//---------------------------------------------------------------
string tip_str (int tip)
{
   switch(tip)
   {
      case 0: return("Buy");
      case 1: return("Sell");
      case 2: return("BuyLimit");
      case 3: return("SellLimit");
      case 4: return("BuyStop");
      case 5: return("SellStop");
   }
   return("?");
}
//-----------------------------------------------
int IsError(int ierr, string input_string, string& out_com_er, bool inf_rus=true)  
{
   int glob_cod_err=0;
   if(ierr > 1)
   {
      string s1_="",s2_="";
      glob_cod_err=error_code_me(ierr,s1,s2);
      out_com_er=input_string+ " error = "+ IntegerToString(ierr)+ "; desc = "+ RusLat_me(inf_rus, s1, s2)+"\n";
   }
      
   return(glob_cod_err);
}
//-----------------------------------------------
string RusLat_me(bool inf_rus, string sR, string sL)
{
   if (inf_rus)return(sR);
   return(sL);
}
//-----------------------------------------------
int error_code_me(int code,  string& s1_, string& s2_)
{
   s1_="";s2_="";
   switch(code)
   {
      case	1	   :s1_="Нет ошибки, но результат неизвестен";s2_="No error returned, but the result is unknown";return(1);
      case	2	   :s1_="Общая ошибка";s2_="Common error";return(1);
      case	3	   :s1_="Неправильные параметры";s2_="Invalid trade parameters";return(1);
      case	4	   :s1_="Торговый сервер занят";s2_="Trade server is busy";return(1);
      case	5	   :s1_="Старая версия клиентского терминала";s2_="Old version of the client terminal";return(2); 
      case	6	   :s1_="Нет связи с торговым сервером";s2_="No connection with trade server";return(1);
      case	7	   :s1_="Недостаточно прав";s2_="Not enough rights";return(2);
      case	8	   :s1_="Слишком частые запросы";s2_="Too frequent requests";return(1);
      case	9	   :s1_="Недопустимая операция, нарушающая функционирование сервера";s2_="Malfunctional trade operation";return(1);
      case	64	   :s1_="Счет заблокирован";s2_="Account disabled";return(2);
      case	65	   :s1_="Неправильный номер счета";s2_="Invalid account";return(2);
      case	128	:s1_="Истек срок ожидания совершения сделки";s2_="Trade timeout";return(1);
      case	129	:s1_="Неправильная цена";s2_="Invalid price";return(1);
      case	130	:s1_="Неправильные стопы";s2_="Invalid stops";return(1);
      case	131	:s1_="Неправильный объем";s2_="Invalid trade volume";return(1);
      case	132	:s1_="Рынок закрыт";s2_="Market is closed";return(2);
      case	133	:s1_="Торговля запрещена";s2_="Trade is disabled";return(2);
      case	134	:s1_="Недостаточно денег для совершения операции";s2_="Not enough money";return(2);
      case	135	:s1_="Цена изменилась";s2_="Price changed";return(1);
      case	136	:s1_="Нет цен";s2_="Off quotes";return(1);
      case	137	:s1_="Брокер занят";s2_="Broker is busy";return(1);
      case	138	:s1_="Новые цены";s2_="Requote";return(1);
      case	139	:s1_="Ордер заблокирован и уже обрабатывается";s2_="Order is locked";return(1);
      case	140	:s1_="Разрешена только покупка";s2_="Buy orders only allowed";return(1);
      case	141	:s1_="Слишком много запросов";s2_="Too many requests";return(1);
      case	145	:s1_="Модификация запрещена, так как ордер слишком близок к рынку";s2_="Modification denied because order is too close to market";return(1);
      case	146	:s1_="Подсистема торговли занята";s2_="Trade context is busy";return(1);
      case	147	:s1_="Использование даты истечения ордера запрещено брокером";s2_="Expirations are denied by broker";return(1);
      case	148	:s1_="Количество открытых и отложенных ордеров достигло предела, установленного брокером";s2_="The amount of open and pending orders has reached the limit set by the broker";return(1);
      case	149	:s1_="Попытка открыть противоположный ордер в случае, если хеджирование запрещено";s2_="An attempt to open an order opposite to the existing one when hedging is disabled";return(1);
      case	150	:s1_="Попытка закрыть позицию по инструменту в противоречии с правилом FIFO";s2_="An attempt to close an order contravening the FIFO rule";return(1);
      case	4000	:s1_="Нет ошибки";s2_="No error returned";return(1);
      case	4001	:s1_="Неправильный указатель функции";s2_="Wrong function pointer";return(2);
      case	4002	:s1_="Индекс массива - вне диапазона";s2_="Array index is out of range";return(2);
      case	4003	:s1_="Нет памяти для стека функций";s2_="No memory for function call stack";return(2);
      case	4004	:s1_="Переполнение стека после рекурсивного вызова";s2_="Recursive stack overflow";return(2);
      case	4005	:s1_="На стеке нет памяти для передачи параметров";s2_="Not enough stack for parameter";return(2);
      case	4006	:s1_="Нет памяти для строкового параметра";s2_="No memory for parameter string";return(2);
      case	4007	:s1_="Нет памяти для временной строки";s2_="No memory for temp string";return(2);
      case	4008	:s1_="Неинициализированная строка";s2_="Not initialized string";return(2);
      case	4009	:s1_="Неинициализированная строка в массиве";s2_="Not initialized string in array";return(2);
      case	4010	:s1_="Нет памяти для строкового массива";s2_="No memory for array string";return(2);
      case	4011	:s1_="Слишком длинная строка";s2_="Too long string";return(2);
      case	4012	:s1_="Остаток от деления на ноль";s2_="Remainder from zero divide";return(2);
      case	4013	:s1_="Деление на ноль";s2_="Zero divide";return(2);
      case	4014	:s1_="Неизвестная команда";s2_="Unknown command";return(2);
      case	4015	:s1_="Неправильный переход";s2_="Wrong jump (never generated error)";return(2);
      case	4016	:s1_="Неинициализированный массив";s2_="Not initialized array";return(2);
      case	4017	:s1_="Вызовы DLL не разрешены";s2_="DLL calls are not allowed";return(2);
      case	4018	:s1_="Невозможно загрузить библиотеку";s2_="Cannot load library";return(2);
      case	4019	:s1_="Невозможно вызвать функцию";s2_="Cannot call function";return(2);
      case	4020	:s1_="Вызовы внешних библиотечных функций не разрешены";s2_="Expert function calls are not allowed";return(2);
      case	4021	:s1_="Недостаточно памяти для строки, возвращаемой из функции";s2_="Not enough memory for temp string returned from function";return(2);
      case	4022	:s1_="Система занята";s2_="System is busy (never generated error)";return(1);
      case	4023	:s1_="Критическая ошибка вызова DLL-функции";s2_="DLL-function call critical error";return(2);
      case	4024	:s1_="Внутренняя ошибка";s2_="Internal error";return(1);
      case	4025	:s1_="Нет памяти";s2_="Out of memory";return(2);
      case	4026	:s1_="Неверный указатель";s2_="Invalid pointer";return(2);
      case	4027	:s1_="Слишком много параметров форматирования строки";s2_="Too many formatters in the format function";return(1);
      case	4028	:s1_="Число параметров превышает число параметров форматирования строки";s2_="Parameters count exceeds formatters count";return(1);
      case	4029	:s1_="Неверный массив";s2_="Invalid array";return(2);
      case	4030	:s1_="График не отвечает";s2_="No reply from chart";return(1);
      case	4050	:s1_="Неправильное количество параметров функции";s2_="Invalid function parameters count";return(2);
      case	4051	:s1_="Недопустимое значение параметра функции";s2_="Invalid function parameter value";return(2);
      case	4052	:s1_="Внутренняя ошибка строковой функции";s2_="String function internal error";return(1);
      case	4053	:s1_="Ошибка массива";s2_="Some array error";return(1);
      case	4054	:s1_="Неправильное использование массива-таймсерии";s2_="Incorrect series array using";return(1);
      case	4055	:s1_="Ошибка пользовательского индикатора";s2_="Custom indicator error";return(1);
      case	4056	:s1_="Массивы несовместимы";s2_="Arrays are incompatible";return(1);
      case	4057	:s1_="Ошибка обработки глобальных переменных";s2_="Global variables processing error";return(1);
      case	4058	:s1_="Глобальная переменная не обнаружена";s2_="Global variable not found";return(1);
      case	4059	:s1_="Функция не разрешена в тестовом режиме";s2_="Function is not allowed in testing mode";return(1);
      case	4060	:s1_="Функция не разрешена";s2_="Function is not allowed for call";return(2);
      case	4061	:s1_="Ошибка отправки почты";s2_="Send mail error";return(1);
      case	4062	:s1_="Ожидается параметр типа string";s2_="String parameter expected";return(1);
      case	4063	:s1_="Ожидается параметр типа integer";s2_="Integer parameter expected";return(1);
      case	4064	:s1_="Ожидается параметр типа double";s2_="Double parameter expected";return(1);
      case	4065	:s1_="В качестве параметра ожидается массив";s2_="Array as parameter expected";return(1);
      case	4066	:s1_="Запрошенные исторические данные в состоянии обновления";s2_="Requested history data is in updating state";return(1);
      case	4067	:s1_="Ошибка при выполнении торговой операции";s2_="Internal trade error";return(1);
      case	4068	:s1_="Ресурс не найден";s2_="Resource not found";return(1);
      case	4069	:s1_="Ресурс не поддерживается";s2_="Resource not supported";return(1);
      case	4070	:s1_="Дубликат ресурса";s2_="Duplicate resource";return(1);
      case	4071	:s1_="Ошибка инициализации пользовательского индикатора";s2_="Custom indicator cannot initialize";return(1);
      case	4072	:s1_="Ошибка загрузки пользовательского индикатора";s2_="Cannot load custom indicator";return(1);
      case	4099	:s1_="Конец файла";s2_="End of file";return(1);
      case	4100	:s1_="Ошибка при работе с файлом";s2_="Some file error";return(1);
      case	4101	:s1_="Неправильное имя файла";s2_="Wrong file name";return(1);
      case	4102	:s1_="Слишком много открытых файлов";s2_="Too many opened files";return(1);
      case	4103	:s1_="Невозможно открыть файл";s2_="Cannot open file";return(1);
      case	4104	:s1_="Несовместимый режим доступа к файлу";s2_="Incompatible access to a file";return(1);
      case	4105	:s1_="Ни один ордер не выбран";s2_="No order selected";return(1);
      case	4106	:s1_="Неизвестный символ";s2_="Unknown symbol";return(2);
      case	4107	:s1_="Неправильный параметр цены для торговой функции";s2_="Invalid price";return(2);
      case	4108	:s1_="Неверный номер тикета";s2_="Invalid ticket";return(2);
      case	4109	:s1_="Торговля не разрешена. Необходимо включить опцию 'Разрешить советнику торговать' в свойствах эксперта";s2_="Trade is not allowed. Enable checkbox 'Allow live trading' in the Expert Advisor properties";return(2);
      case	4110	:s1_="Ордера на покупку не разрешены. Необходимо проверить свойства эксперта";s2_="Longs are not allowed. Check the Expert Advisor properties";return(1);
      case	4111	:s1_="Ордера на продажу не разрешены. Необходимо проверить свойства эксперта";s2_="Shorts are not allowed. Check the Expert Advisor properties";return(1);
      case	4112	:s1_="Автоматическая торговля с помощью экспертов/скриптов запрещена на стороне сервера";s2_="Automated trading by Expert Advisors/Scripts disabled by trade server";return(2);
      case	4200	:s1_="Объект уже существует";s2_="Object already exists";return(1);
      case	4201	:s1_="Запрошено неизвестное свойство объекта";s2_="Unknown object property";return(1);
      case	4202	:s1_="Объект не существует";s2_="Object does not exist";return(1);
      case	4203	:s1_="Неизвестный тип объекта";s2_="Unknown object type";return(1);
      case	4204	:s1_="Нет имени объекта";s2_="No object name";return(1);
      case	4205	:s1_="Ошибка координат объекта";s2_="Object coordinates error";return(1);
      case	4206	:s1_="Не найдено указанное подокно";s2_="No specified subwindow";return(1);
      case	4207	:s1_="Ошибка при работе с объектом";s2_="Graphical object error";return(1);
      case	4210	:s1_="Неизвестное свойство графика";s2_="Unknown chart property";return(1);
      case	4211	:s1_="График не найден";s2_="Chart not found";return(1);
      case	4212	:s1_="Не найдено подокно графика";s2_="Chart subwindow not found";return(1);
      case	4213	:s1_="Индикатор не найден";s2_="Chart indicator not found";return(1);
      case	4220	:s1_="Ошибка выбора инструмента";s2_="Symbol select error";return(1);
      case	4250	:s1_="Ошибка отправки push-уведомления";s2_="Notification error";return(1);
      case	4251	:s1_="Ошибка параметров push-уведомления";s2_="Notification parameter error";return(1);
      case	4252	:s1_="Уведомления запрещены";s2_="Notifications disabled";return(1);
      case	4253	:s1_="Слишком частые запросы отсылки push-уведомлений";s2_="Notification send too frequent";return(1);
      case	5001	:s1_="Слишком много открытых файлов";s2_="Too many opened files";return(1);
      case	5002	:s1_="Неверное имя файла";s2_="Wrong file name";return(1);
      case	5003	:s1_="Слишком длинное имя файла";s2_="Too long file name";return(1);
      case	5004	:s1_="Ошибка открытия файла";s2_="Cannot open file";return(1);
      case	5005	:s1_="Ошибка размещения буфера текстового файла";s2_="Text file buffer allocation error";return(1);
      case	5006	:s1_="Ошибка удаления файла";s2_="Cannot delete file";return(1);
      case	5007	:s1_="Неверный хендл файла (файл закрыт или не был открыт)";s2_="Invalid file handle (file closed or was not opened)";return(1);
      case	5008	:s1_="Неверный хендл файла (индекс хендла отсутствует в таблице)";s2_="Wrong file handle (handle index is out of handle table)";return(1);
      case	5009	:s1_="Файл должен быть открыт с флагом FILE_WRITE";s2_="File must be opened with FILE_WRITE flag";return(1);
      case	5010	:s1_="Файл должен быть открыт с флагом FILE_READ";s2_="File must be opened with FILE_READ flag";return(1);
      case	5011	:s1_="Файл должен быть открыт с флагом FILE_BIN";s2_="File must be opened with FILE_BIN flag";return(1);
      case	5012	:s1_="Файл должен быть открыт с флагом FILE_TXT";s2_="File must be opened with FILE_TXT flag";return(1);
      case	5013	:s1_="Файл должен быть открыт с флагом FILE_TXT или FILE_CSV";s2_="File must be opened with FILE_TXT or FILE_CSV flag";return(1);
      case	5014	:s1_="Файл должен быть открыт с флагом FILE_CSV";s2_="File must be opened with FILE_CSV flag";return(1);
      case	5015	:s1_="Ошибка чтения файла";s2_="File read error";return(1);
      case	5016	:s1_="Ошибка записи файла";s2_="File write error";return(1);
      case	5017	:s1_="Размер строки должен быть указан для двоичных файлов";s2_="String size must be specified for binary file";return(1);
      case	5018	:s1_="Неверный тип файла (для строковых массивов-TXT, для всех других-BIN)";s2_="Incompatible file (for string arrays-TXT, for others-BIN)";return(1);
      case	5019	:s1_="Файл является директорией";s2_="File is directory not file";return(1);
      case	5020	:s1_="Файл не существует";s2_="File does not exist";return(1);
      case	5021	:s1_="Файл не может быть перезаписан";s2_="File cannot be rewritten";return(1);
      case	5022	:s1_="Неверное имя директории";s2_="Wrong directory name";return(1);
      case	5023	:s1_="Директория не существует";s2_="Directory does not exist";return(1);
      case	5024	:s1_="Указанный файл не является директорией";s2_="Specified file is not directory";return(1);
      case	5025	:s1_="Ошибка удаления директории";s2_="Cannot delete directory";return(1);
      case	5026	:s1_="Ошибка очистки директории";s2_="Cannot clean directory";return(1);
      case	5027	:s1_="Ошибка изменения размера массива";s2_="Array resize error";return(1);
      case	5028	:s1_="Ошибка изменения размера строки";s2_="String resize error";return(1);
      case	5029	:s1_="Структура содержит строки или динамические массивы";s2_="Structure contains strings or dynamic arrays";return(1);
      case	5200	:s1_="URL не прошел проверку";s2_="Invalid URL";return(1);
      case	5201	:s1_="Не удалось подключиться к указанному URL";s2_="Failed to connect to specified URL";return(1);
      case	5202	:s1_="Превышен таймаут получения данных";s2_="Timeout exceeded";return(1);
      case	5203	:s1_="Ошибка в результате выполнения HTTP запроса";s2_="HTTP request failed";return(1);
      case	9000	:s1_="Количество открытых ордеров достигло предела";s2_="The amount of open orders has reached the limit";return(1);
      default     :s1_="Неизвестная ошибка";s2_="unknown error";return(1);
   }
   return(0);
}
//==============================================================
